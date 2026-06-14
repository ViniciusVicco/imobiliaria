# Spec 4.0 - Broker/Admin Properties CRUD

## Status
- Implementada em primeira versao funcional.
- Backend protegido implementado e registrado em `backend/src/modules/properties/protected-properties.routes.ts`.
- Flutter broker/admin implementado com fluxo `Widget -> Controller -> UseCase -> Repository -> Datasource -> RestClient`.
- Firebase removido do bootstrap Flutter e das dependencias declaradas do app.
- Validacao concluida: `npm.cmd run build` em `backend/`.
- Validacao pendente: `flutter analyze`, `flutter test`, `dart format` e `flutter pub get` travaram por timeout da toolchain Dart/Flutter nesta maquina.

## Estado atual implementado
- Broker lista apenas os proprios imoveis em `/broker/properties`.
- Broker cria imovel proprio com `status=published`.
- Broker edita apenas imovel proprio.
- Broker altera status para `published`, `inactive`, `sold` ou `draft`.
- Admin lista e edita imoveis de todos em `/admin/properties`.
- Admin altera status de qualquer imovel.
- Admin pode preservar/alterar `brokerId` apenas para corretor ativo.
- Persistencia de midia ocorre em transacao, substituindo `property_media` na edicao.
- `isNewDevelopment=true` salva `propertyAgeYears=0` e garante `na-planta` em `tagSlugs`.
- Busca/detalhe publico continuam retornando apenas `status=published`.
- Busca/detalhe publico retornam `brokerContact` com fallback institucional.
- Tela `/broker` mostra CTA para `Meus imoveis`.
- Tela `/broker/properties` tem tabs `Anunciados`, `Vendas` e `Excluidos`, grid, criacao/edicao por dialog e acoes de status.
- Tela `/admin/properties` foi adicionada ao `AdminLayout`, com filtro por status, busca textual, edicao e acoes de status.

## Contexto
O painel do corretor precisa sair do placeholder e permitir que corretores gerenciem os imoveis que anunciam. O admin tambem deve conseguir gerenciar imoveis de todos os corretores.

O banco atual ja possui a base necessaria para esta v1:
- `properties.broker_id` vincula o imovel ao corretor.
- `properties.cover_url` guarda a imagem de capa.
- `properties.status` controla `draft`, `published`, `sold` e `inactive`.
- `property_media` guarda imagens e video por URL.

Nesta fase, nao havera upload real de arquivos. Fotos e video serao informados por URL manual e salvos no PostgreSQL.

## Decisoes fechadas
- Midia v1: URL manual, sem multipart/storage.
- Novo imovel criado por corretor entra como `published`.
- Admin pode listar, editar, inativar e marcar venda de qualquer imovel.
- Corretor pode listar, criar, editar, inativar e marcar venda apenas dos proprios imoveis.
- Remover significa mudar `status` para `inactive`, sem exclusao fisica.
- Sinalizar venda significa mudar `status` para `sold`.
- Publico continua vendo apenas `status=published`.
- CTA publico de WhatsApp deve usar telefone do corretor responsavel; se ausente, usar fallback institucional.

## Escopo
Em escopo:
- Criar endpoints protegidos de CRUD de imoveis para corretor.
- Criar endpoints protegidos de gerenciamento global de imoveis para admin.
- Criar grid operacional de imoveis no painel do corretor.
- Criar formulario de criacao e edicao de imovel.
- Criar acoes de editar, remover/inativar e sinalizar venda.
- Salvar foto de capa, galeria de fotos por URL e video/apresentacao por URL.
- Atualizar API publica para retornar contato WhatsApp do corretor quando existir.

Fora de escopo:
- Upload real de imagens/videos.
- Compressao ou processamento de midia.
- Aba completa de excluidos, alem do status e filtro preparado.
- Fluxo de aprovacao editorial por admin.
- Leads/CRM.
- Auditoria de alteracoes.

## Rotas backend
Todas as rotas usam base `/api/v1`.

### Broker properties
Exigem `requireActiveBroker`.

```txt
GET /broker/properties
POST /broker/properties
GET /broker/properties/:id
PATCH /broker/properties/:id
PATCH /broker/properties/:id/status
```

Regras:
- Corretor so acessa imoveis com `broker_id` igual ao usuario autenticado.
- `brokerId` nunca vem do frontend.
- Ao criar, backend fixa `brokerId=request.authenticatedUser.id`.
- Ao criar, backend fixa `status=published`.
- Ao tentar acessar imovel de outro corretor, retornar `404 PROPERTY_NOT_FOUND`.

### Admin properties
Exigem `requireActiveAdmin`.

```txt
GET /admin/properties
GET /admin/properties/:id
PATCH /admin/properties/:id
PATCH /admin/properties/:id/status
```

Regras:
- Admin lista e edita qualquer imovel.
- Admin pode filtrar por `brokerId`, `status`, `query`, `page` e `pageSize`.
- Admin pode atribuir ou alterar `brokerId` apenas para usuario existente com `role=broker` e `isActive=true`.

## Contratos de API
### Listar imoveis do corretor
```txt
GET /api/v1/broker/properties?status=published&page=1&pageSize=24
Authorization: Bearer <accessToken>
```

Resposta:
```json
{
  "items": [
    {
      "id": "property_id",
      "title": "Casa em condominio",
      "segment": "residential",
      "propertyType": "Casa em condominio",
      "city": "Palmas",
      "neighborhood": "Plano Diretor Sul",
      "subNeighborhood": "706 Sul",
      "coverUrl": "https://...",
      "tags": ["pronto-para-morar"],
      "areaM2": 180,
      "bedrooms": 3,
      "bathrooms": 3,
      "garageSpaces": 2,
      "propertyAgeYears": 4,
      "price": 1200000,
      "status": "published",
      "updatedAt": "2026-06-11T00:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 24,
    "total": 1,
    "totalPages": 1
  }
}
```

### Criar/editar imovel
```txt
POST /api/v1/broker/properties
PATCH /api/v1/broker/properties/:id
Authorization: Bearer <accessToken>
```

Body:
```json
{
  "title": "Casa em condominio",
  "description": "Descricao comercial do imovel.",
  "segment": "residential",
  "propertyType": "Casa em condominio",
  "city": "Palmas",
  "neighborhood": "Plano Diretor Sul",
  "subNeighborhood": "706 Sul",
  "coverUrl": "https://cdn.site/capa.jpg",
  "imageUrls": [
    "https://cdn.site/foto-1.jpg",
    "https://cdn.site/foto-2.jpg",
    "https://cdn.site/foto-3.jpg",
    "https://cdn.site/foto-4.jpg"
  ],
  "videoUrl": "https://youtube.com/watch?v=abc",
  "areaM2": 180,
  "bedrooms": 3,
  "bathrooms": 3,
  "garageSpaces": 2,
  "propertyAgeYears": 4,
  "price": 1200000,
  "tagSlugs": ["pronto-para-morar"],
  "isFeatured": false,
  "isNewDevelopment": false
}
```

Regras de validacao:
- `title`, `segment`, `propertyType`, `city`, `neighborhood`, `coverUrl`, `areaM2`, `price`, `bathrooms` e `garageSpaces` sao obrigatorios.
- `neighborhood` nao pode ser vazio.
- `imageUrls` deve ter minimo 4 e maximo 12 URLs.
- `coverUrl` deve estar preenchido; recomendado que seja uma das imagens de `imageUrls`.
- `videoUrl` e opcional; quando preenchido, deve ser URL valida.
- `price`, `areaM2`, `bedrooms`, `bathrooms`, `garageSpaces` e `propertyAgeYears` devem ser inteiros.
- `bedrooms`, `bathrooms` e `garageSpaces` devem ficar entre 0 e 5.
- `propertyAgeYears` deve ficar entre 0 e 50.
- Se `isNewDevelopment=true`, backend salva `propertyAgeYears=0` e garante `na-planta` em `tagSlugs`.
- Se `isNewDevelopment=false`, backend usa `propertyAgeYears` informado.
- `tagSlugs` deve conter apenas tags conhecidas e ativas em `property_tags`.
- Criacao de broker fixa `status=published`.
- Edicao nao pode alterar `brokerId` pela rota broker.

Persistencia de midia:
- `properties.cover_url` recebe `coverUrl`.
- Cada item de `imageUrls` vira registro em `property_media` com `type=image` e `sort_order` sequencial.
- `videoUrl`, quando preenchido, vira registro em `property_media` com `type=video`.
- Na edicao, substituir o conjunto de `property_media` do imovel dentro de transacao.

### Alterar status
```txt
PATCH /api/v1/broker/properties/:id/status
Authorization: Bearer <accessToken>
```

Body:
```json
{
  "status": "sold"
}
```

Status permitidos:
- `published`: anunciado/publico.
- `inactive`: removido/inativado.
- `sold`: venda sinalizada.
- `draft`: reservado para uso futuro.

Regras:
- `inactive` remove o imovel da visualizacao publica.
- `sold` remove o imovel da visualizacao publica e move para `Minhas vendas`.
- Nenhuma troca de status exclui fisicamente o registro.

## API publica
Atualizar listagem/detalhe publico para incluir contato do corretor quando existir.

Exemplo:
```json
{
  "brokerContact": {
    "name": "Nome do Corretor",
    "phone": "(63) 99999-9999",
    "whatsapp": "(63) 99999-9999"
  }
}
```

Regras:
- Busca, home e detalhe publico continuam filtrando apenas `status=published`.
- Se imovel nao tiver corretor ou corretor nao tiver telefone, usar WhatsApp institucional de `brand_content`.
- Publico nao recebe email do corretor nesta v1.

## UX Flutter
### Rotas
```txt
/broker
/broker/properties
/admin/properties
```

Observacao da implementacao v1:
- Criacao e edicao foram implementadas como dialog/modal dentro de `/broker/properties` e `/admin/properties`.
- Rotas dedicadas `/broker/properties/new` e `/broker/properties/:id/edit` ficam reservadas para uma evolucao futura, caso o fluxo precise de URLs compartilhaveis para formulario.

### Broker home
- Mostrar resumo simples.
- CTA principal: `Meus imoveis`.
- Opcional: contadores de anunciados, vendidos e inativos.

### Meus imoveis
- Grid de cards dos imoveis do corretor.
- Tabs/filtros:
  - `Anunciados`: `published`.
  - `Minhas vendas`: `sold`.
  - `Excluidos`: `inactive`, preparado para fase futura.
- Card:
  - imagem de capa;
  - titulo;
  - bairro/cidade;
  - preco;
  - status;
  - acoes flutuando sobre a imagem:
    - editar;
    - remover;
    - sinalizar venda.
- Confirmar antes de remover ou sinalizar venda.
- Depois de remover/vender, atualizar lista e tirar da aba atual.

### Formulario de criacao/edicao
Campos:
- titulo;
- descricao;
- segmento;
- tipo do imovel;
- cidade, default visual `Palmas`;
- bairro;
- sub-bairro/quadra;
- foto de capa URL;
- 4 a 12 URLs de fotos;
- URL de video/apresentacao;
- valor com mascara/exemplo;
- metros quadrados como inteiro;
- quartos, banheiros e vagas com slider 0 a 5;
- idade do imovel com slider 0 a 50;
- checkbox `Imovel na planta`;
- tags.

Comportamento:
- Se `Imovel na planta` estiver marcado, idade fica desabilitada e valor enviado e `0`.
- O formulario nao pede telefone do CTA; o telefone vem do corretor autenticado.
- Erros de backend devem aparecer proximos do formulario ou em snackbar.

## Arquitetura Flutter
Seguir fluxo atual:
```txt
Widget -> Controller -> UseCase -> Repository -> Datasource -> RestClient
```

Novas camadas:
- `domain/broker/entities/broker_property_entity.dart`
- use cases para listar, criar, editar e alterar status.
- datasource/repository de broker properties.
- presentation em `main/pages/broker/`.
- endpoints em `data/api/broker_properties_endpoints.dart`.

Admin pode reutilizar entidades/use cases ou ter camada propria `admin/properties`, desde que mantenha endpoints e autorizacao separados.

Implementacao v1:
- Entidades e models ficam em `lib/app/domain/broker` e `lib/app/data/broker`.
- Broker e admin reutilizam entidades/modelos.
- Broker e admin usam use cases separados para manter endpoints e autorizacao distintos.
- Componentes visuais compartilhados ficam em `lib/app/presentation/main/pages/broker/widgets/property_management_widgets.dart`.

## Riscos e edge cases
- URL de imagem quebrada: UI mostra placeholder e permite edicao.
- Menos de 4 fotos: backend rejeita com mensagem clara.
- Mais de 12 fotos: backend rejeita.
- Corretor tenta editar imovel de outro corretor: backend retorna `404`.
- Admin edita imovel sem corretor: permitido apenas se mantiver sem corretor em `draft` ou atribuir broker ativo.
- Imovel vendido/inativo nao aparece em busca, home ou detalhe publico.
- Valores monetarios digitados com mascara devem virar inteiro em centavos ou reais. Decisao v1: manter inteiro em reais, como schema atual.
- Video invalido: se preenchido, backend rejeita URL invalida.
- WhatsApp ausente no corretor: fallback institucional.

## Requisitos funcionais
1. Broker ativo acessa `/broker`.
2. Broker acessa `/broker/properties` e ve apenas os proprios imoveis.
3. Broker cria imovel publicado com capa e 4 a 12 fotos.
4. Broker edita todas as informacoes permitidas do proprio imovel.
5. Broker remove imovel e o status vira `inactive`.
6. Broker sinaliza venda e o status vira `sold`.
7. Imovel `inactive` ou `sold` some da busca publica imediatamente.
8. Admin acessa `/admin/properties` e gerencia todos os imoveis.
9. Publico clica no CTA WhatsApp e e direcionado ao telefone do corretor responsavel.

## Requisitos nao funcionais
1. Backend continua sendo a fonte de verdade de permissao.
2. `brokerId`, `role` e status sensiveis nao sao confiados ao frontend.
3. Operacoes de edicao de imovel e midia devem ocorrer em transacao.
4. UI deve ser responsiva e sem overflow em cards e formularios.
5. Nenhuma exclusao fisica de imovel ocorre nesta v1.

## Criterios de aceite
1. Dado broker logado, quando abre `Meus imoveis`, entao ve apenas imoveis com seu `brokerId`.
2. Dado broker cria imovel valido, quando salva, entao o imovel entra como `published`.
3. Dado broker tenta salvar com 3 fotos, entao recebe erro.
4. Dado broker tenta editar imovel de outro corretor, entao recebe `404`.
5. Dado broker remove imovel, quando busca publica roda, entao o imovel nao aparece.
6. Dado broker sinaliza venda, quando abre `Minhas vendas`, entao o imovel aparece la.
7. Dado admin logado, quando abre `/admin/properties`, entao ve imoveis de todos.
8. Dado publico ve detalhe publicado, quando clica no WhatsApp, entao usa telefone do corretor ou fallback institucional.

## Testes obrigatorios
### Backend
- Broker cria imovel publicado com 4 imagens.
- Broker nao cria com menos de 4 imagens.
- Broker nao cria com mais de 12 imagens.
- Broker lista apenas seus imoveis.
- Broker nao acessa imovel de outro broker.
- Broker edita proprio imovel.
- Broker muda status para `inactive`.
- Broker muda status para `sold`.
- Admin lista e edita qualquer imovel.
- Busca publica nao retorna `inactive`, `sold` ou `draft`.
- Detalhe publico de imovel vendido/inativo retorna `404`.

### Flutter
- Grid renderiza cards com acoes flutuando sobre capa.
- Formulario valida campos obrigatorios.
- Sliders respeitam limites definidos.
- Checkbox `na planta` zera/desabilita idade.
- Criacao bem-sucedida atualiza grid.
- Edicao bem-sucedida reflete dados alterados.
- Remover tira o card de `Anunciados`.
- Sinalizar venda move para `Minhas vendas`.
- Admin acessa gerenciamento global.

## Validacao realizada
- Backend:
  - `npm.cmd run build` passou apos a implementacao.
- Flutter:
  - `flutter analyze` travou por timeout.
  - `dart analyze` com escopo reduzido travou por timeout.
  - `dart format` travou por timeout.
  - `flutter test` travou por timeout.
  - `flutter pub get` travou por timeout, mas removeu referencias Firebase de `pubspec.lock` e registrants gerados.

## Pendencias tecnicas
- Rodar novamente `flutter pub get` quando a toolchain Dart/Flutter voltar a responder, para garantir lockfile e arquivos gerados consistentes.
- Rodar `dart format` nos arquivos Dart adicionados/alterados.
- Rodar `flutter analyze` e corrigir eventuais diagnosticos.
- Adicionar testes automatizados backend e Flutter conforme a lista obrigatoria acima.
- Avaliar criacao das rotas dedicadas de formulario se a equipe quiser URLs compartilhaveis para novo/editar imovel.

## Ordem recomendada de entrega
1. Implementar schemas Zod e helpers de normalizacao no backend. [done]
2. Criar rotas broker properties. [done]
3. Criar rotas admin properties. [done]
4. Atualizar respostas publicas com contato do corretor. [done]
5. Criar camada data/domain Flutter para broker properties. [done]
6. Criar grid `Meus imoveis`. [done]
7. Criar formulario de criacao/edicao. [done como dialog/modal]
8. Integrar acoes de remover e sinalizar venda. [done]
9. Criar tela admin properties. [done]
10. Adicionar testes focados. [pending]

## Definition of Done
- Broker gerencia proprios imoveis de ponta a ponta. [implemented]
- Admin gerencia imoveis de todos. [implemented]
- Publico ve apenas imoveis publicados. [implemented]
- Imovel inativado ou vendido some imediatamente da vitrine publica. [implemented no backend]
- CTA publico de WhatsApp usa corretor responsavel ou fallback institucional. [implemented no contrato publico]
- Testes automatizados e validacao Flutter. [pending por timeout da toolchain]
