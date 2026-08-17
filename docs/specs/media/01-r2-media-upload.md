# Spec 5.0 - Upload de Midia com Cloudflare R2

## Status
- Backend e integracao Flutter implementados no fluxo atual de propriedades.
- Substitui a abordagem v1 de URL manual para imagens de imoveis.
- Backend sera responsavel pelo upload para Cloudflare R2.
- Flutter nao envia direto para R2 nesta fase.
- Esta spec parte das decisoes registradas em `docs/levantamentos.md`.
- Validado:
  - `@aws-sdk/client-s3` instalado.
  - Prisma Client gerado.
  - Migration `20260623120000_r2_media_lifecycle` aplicada localmente.
  - `npm.cmd run build` passou.
- Pendente:
  - Validacao manual com R2 configurado para login, draft, upload, set cover, pending-delete e restore.
  - Cobertura automatizada do ciclo de vida.
  - Confirmar/implementar limpeza automatica das midias em `pending_delete`.

## Contexto
O CRUD de imoveis da Spec 4.0 usa URLs manuais para capa, galeria e video. Isso foi suficiente para uma primeira entrega, mas nao e adequado para uso real por corretores.

A plataforma precisa permitir upload de imagens pelo painel, armazenar os arquivos em Cloudflare R2, associar cada arquivo a um imovel e controlar remocao/restauracao com seguranca.

Tambem precisamos preparar o fluxo incremental de cadastro:
- ao abrir criacao/edicao, o backend pode criar ou garantir um imovel `draft` com `propertyId`;
- as midias passam a ser associadas a esse `propertyId`;
- ao finalizar, o corretor envia o imovel para revisao;
- admin aprova ou rejeita em uma area de pendencias.

## Decisoes fechadas
- Cloudflare R2 sera o storage de midia.
- Upload passa pelo backend.
- Flutter nao usa URL assinada direta para R2 nesta fase.
- O app nao usara o `Token value` da Cloudflare em runtime.
- Runtime do backend usa:
  - `Access Key ID`;
  - `Secret Access Key`;
  - `Account ID`;
  - `Bucket Name`;
  - endpoint R2.
- Video, por enquanto, continua sendo somente YouTube.
- Imagens publicas devem ser servidas por `R2_PUBLIC_BASE_URL`.
- `coverUrl` deve apontar para uma imagem existente e ativa da propria propriedade.
- Remocao de midia sera reversivel por 7 dias.
- Cliente final nunca ve imoveis `draft` ou `pending_review`.
- `google_maps_flutter` fica fora desta spec e sera tratado em spec propria de localizacao.

## Env / Config
Adicionar ao `backend/.env.example`:

```txt
R2_ACCOUNT_ID=""
R2_BUCKET_NAME=""
R2_ACCESS_KEY_ID=""
R2_SECRET_ACCESS_KEY=""
R2_PUBLIC_BASE_URL=""
R2_ENDPOINT="https://<ACCOUNT_ID>.r2.cloudflarestorage.com"
R2_REGION="auto"
R2_MAX_IMAGE_SIZE_MB=10
R2_ALLOWED_IMAGE_MIME_TYPES="image/jpeg,image/png,image/webp"
```

Adicionar ao `backend/src/config/env.ts` com validacao Zod.

### Credenciais Cloudflare
Uso em runtime:
- `Access Key ID` -> `R2_ACCESS_KEY_ID`.
- `Secret Access Key` -> `R2_SECRET_ACCESS_KEY`.
- `Account ID` -> `R2_ACCOUNT_ID`.
- Nome do bucket -> `R2_BUCKET_NAME`.

Nao usar em runtime:
- `Token value`.

Observacao:
- O `Token value` pode ser util para operacoes administrativas ou automacao futura de criacao de credenciais, mas nao deve ficar no `.env` da aplicacao se ja temos `Access Key ID` e `Secret Access Key`.

## Escopo
Em escopo:
- Criar configuracao R2 no backend.
- Criar client R2 centralizado.
- Criar endpoints protegidos de upload/remocao/restauracao.
- Criar migration para ciclo de vida de `property_media`.
- Adicionar `pending_review` em `PropertyStatus`.
- Permitir criacao/garantia de imovel `draft` antes do upload.
- Associar imagens ao imovel por `propertyId`.
- Definir imagem de capa a partir de midia ativa.
- Remover imagem por `pending_delete`.
- Restaurar imagem dentro da janela de 7 dias.
- Criar job/manual endpoint para limpeza de midias pendentes.
- Atualizar respostas de imovel para ignorar midias `pending_delete`.
- Preparar Flutter para rotas definitivas de formulario.

Fora de escopo:
- Upload direto do Flutter para R2 via signed URL.
- Upload de video para R2.
- Processamento, compressao ou redimensionamento de imagens.
- CDN/custom domain definitivo, caso `R2_PUBLIC_BASE_URL` ainda nao exista.
- Localizacao/Google Maps.
- Testes Flutter via `flutter test`/`flutter analyze`, enquanto a toolchain estiver instavel.

## Contratos backend
Todas as rotas usam base `/api/v1`.

### Garantir draft para upload
```txt
POST /broker/properties/draft
Authorization: Bearer <accessToken>
```

Resposta:
```json
{
  "id": "property_id",
  "status": "draft"
}
```

Regras:
- Broker cria `draft` proprio.
- Admin pode criar `draft` global se necessario pela rota admin futura.
- O draft existe para permitir associar midia antes da publicacao.

### Upload de imagem
```txt
POST /media/properties/:propertyId/images
Authorization: Bearer <accessToken>
```

Body v1:
```json
{
  "fileName": "imagem-frente.png",
  "mimeType": "image/png",
  "contentBase64": "base64..."
}
```

Resposta:
```json
{
  "id": "media_id",
  "propertyId": "property_id",
  "url": "https://cdn.seletta.../media/properties/property_id/uuid-imagem-frente.png",
  "type": "image",
  "status": "active",
  "sortOrder": 0,
  "storageKey": "media/properties/property_id/uuid-imagem-frente.png",
  "mimeType": "image/png",
  "sizeBytes": 123456
}
```

Regras:
- Broker so envia imagem para imovel proprio.
- Admin envia imagem para qualquer imovel.
- Backend valida MIME type permitido.
- Backend valida tamanho maximo.
- Backend gera `storageKey`.
- Backend salva arquivo no R2.
- Backend cria registro em `property_media`.

### Definir capa
```txt
PATCH /media/:mediaId/cover
Authorization: Bearer <accessToken>
```

Regras:
- `mediaId` deve ser imagem ativa.
- Midia deve pertencer a propriedade acessivel pelo usuario.
- Atualiza `properties.cover_url` para `media.public_url`.

### Marcar midia para remocao
```txt
PATCH /media/:mediaId/pending-delete
Authorization: Bearer <accessToken>
```

Regras:
- Marca `property_media.status=pending_delete`.
- Preenche `pending_delete_at`.
- UI deixa de exibir imediatamente.
- Arquivo nao e removido fisicamente no momento.

### Restaurar midia
```txt
PATCH /media/:mediaId/restore
Authorization: Bearer <accessToken>
```

Regras:
- Permitido apenas antes da limpeza definitiva.
- Volta `status=active`.
- Limpa `pending_delete_at`.

### Limpeza de midias pendentes
```txt
POST /media/cleanup/pending-delete
Authorization: Bearer <accessToken>
```

Regras:
- Admin pode executar manualmente em ambiente local/dev.
- Futuramente vira job agendado.
- Remove do R2 midias com `pending_delete_at <= now - 7 dias`.
- Marca `deleted_at` ou remove registro, conforme decisao da migration.

## Modelo de dados
Atualizar `PropertyStatus`:

```prisma
enum PropertyStatus {
  draft
  pending_review
  published
  sold
  inactive
}
```

Atualizar `PropertyMedia`:

```prisma
model PropertyMedia {
  id              String      @id
  propertyId      String      @map("property_id")
  url             String
  publicUrl       String?     @map("public_url")
  storageKey      String?     @map("storage_key")
  type            MediaType
  status          MediaStatus @default(active)
  mimeType        String?     @map("mime_type")
  sizeBytes       Int?        @map("size_bytes")
  sortOrder       Int         @default(0) @map("sort_order")
  uploadedBy      String?     @map("uploaded_by")
  pendingDeleteAt DateTime?   @map("pending_delete_at")
  deletedAt       DateTime?   @map("deleted_at")
  createdAt       DateTime    @default(now()) @map("created_at")

  property Property @relation(fields: [propertyId], references: [id], onDelete: Cascade)

  @@index([propertyId, status, sortOrder])
  @@index([pendingDeleteAt])
  @@map("property_media")
}

enum MediaStatus {
  active
  pending_delete
}
```

## Flutter
Criar rotas definitivas:

```txt
/broker/properties/new
/broker/properties/:id/edit
```

Fluxo esperado:
- Ao abrir novo imovel, controller chama use case para garantir `draft`.
- Usuario preenche dados e sobe imagens.
- Upload chama datasource HTTP.
- Imagens aparecem na galeria do formulario.
- Usuario define capa.
- Usuario pode remover/restaurar imagem.
- Ao finalizar, envia para revisao (`pending_review`).
- Admin aprova/rejeita em `Pendencias`.

Camadas previstas:
- `data/media/datasources/media_datasource.dart`
- `data/media/repositories/media_repository.dart`
- `domain/media/entities/property_media_entity.dart`
- `domain/media/usecases/upload_property_image_use_case.dart`
- `domain/media/usecases/set_property_cover_use_case.dart`
- `domain/media/usecases/delete_property_media_use_case.dart`
- `domain/media/usecases/restore_property_media_use_case.dart`
- `presentation/main/pages/broker/property_form_page.dart`

## Admin - Pendencias
Adicionar aba/entrada `Pendencias` no admin.

Deve listar:
- imoveis `pending_review`;
- pedidos de destaque;
- preview do anuncio.

Regras:
- Ao corretor enviar para revisao, todos os admins recebem email SMTP.
- Admin aprova e publica.
- Admin rejeita sem exigir motivo nesta fase.
- Cliente final nao ve `pending_review`.

## Requisitos funcionais
1. Broker abre novo imovel e recebe um `draft` com id.
2. Broker faz upload de imagem via backend.
3. Backend salva imagem no R2.
4. Backend registra midia em `property_media`.
5. Broker define imagem ativa como capa.
6. Broker remove imagem e ela some da UI como `pending_delete`.
7. Broker restaura imagem antes da limpeza.
8. Admin executa ou job processa limpeza apos 7 dias.
9. Broker envia imovel para revisao.
10. Admin ve imovel em `Pendencias`.
11. Admin aprova e publica.
12. Busca publica retorna apenas `published`.

## Requisitos nao funcionais
1. Backend continua sendo a fonte de verdade de permissao.
2. Credenciais R2 nunca ficam no Flutter.
3. `Token value` da Cloudflare nao fica no `.env` da aplicacao.
4. Upload valida MIME type e tamanho.
5. Remocao fisica de arquivos e reversivel por 7 dias.
6. Toolchain Flutter pode continuar fora da validacao automatica ate estabilizar.

## Criterios de aceite
1. Dado broker logado, quando abre novo imovel, entao backend cria/retorna `draft`.
2. Dado broker sobe imagem valida, quando upload termina, entao arquivo existe no R2 e registro existe em `property_media`.
3. Dado broker tenta subir imagem em imovel de outro corretor, entao API retorna erro.
4. Dado admin sobe imagem em qualquer imovel, entao upload e permitido.
5. Dado imagem ativa, quando definida como capa, entao `coverUrl` passa a usar a URL publica da midia.
6. Dado midia marcada como `pending_delete`, quando detalhe/listagem carrega, entao ela nao aparece.
7. Dado midia pendente dentro de 7 dias, quando restaurada, entao volta a aparecer.
8. Dado midia pendente ha mais de 7 dias, quando cleanup roda, entao arquivo e removido do R2.
9. Dado imovel `pending_review`, quando cliente final busca, entao imovel nao aparece.

## Testes obrigatorios
### Backend
- Env R2 valida variaveis obrigatorias.
- Upload rejeita MIME type invalido.
- Upload rejeita arquivo acima do limite.
- Broker nao faz upload em imovel de outro corretor.
- Admin faz upload em qualquer imovel.
- Upload cria objeto R2 e registro no banco.
- Set cover exige midia ativa da mesma propriedade.
- `pending_delete` remove da resposta operacional/publica.
- Restore reativa antes da limpeza.
- Cleanup remove arquivo R2 apos 7 dias.
- Busca publica nao retorna `draft`, `pending_review`, `inactive` ou `sold`.

### Flutter
- Nao depender de `flutter test`, `flutter analyze`, `dart analyze` ou `dart format` por enquanto.
- Validacao manual:
  - abrir novo imovel;
  - upload de imagem;
  - definir capa;
  - remover/restaurar;
  - enviar para revisao;
  - admin aprovar.

## Ordem recomendada de entrega
1. Atualizar env/config R2. [done]
2. Instalar `@aws-sdk/client-s3`. [done]
3. Criar client R2 centralizado. [done]
4. Criar migration de `PropertyStatus` e `PropertyMedia`. [done]
5. Criar endpoint de garantir `draft`. [done]
6. Criar endpoint de upload de imagem. [done]
7. Criar endpoint de definir capa. [done]
8. Criar endpoint de `pending-delete`. [done]
9. Criar endpoint de restore. [done]
10. Criar cleanup manual/job. [done como endpoint admin manual]
11. Atualizar respostas publicas/protegidas para ignorar midias removidas. [done]
12. Criar rotas Flutter de formulario.
13. Integrar upload no formulario.
14. Criar aba admin `Pendencias`.
15. Adicionar validacoes manuais e testes backend.

## Definition of Done
- Backend envia imagens para R2.
- Flutter nao conhece credenciais R2.
- Imagens ficam associadas a `propertyId`.
- Capa vem de midia ativa.
- Remocao e reversivel por 7 dias.
- `pending_review` existe no backend e nao aparece publicamente.
- Admin consegue aprovar publicacao.
- Spec 4.0 deixa de depender de URLs manuais como fluxo final de midia.
