# Specs Seletta

Este diretorio organiza as specs por dominio de produto. A numeracao dentro de cada pasta indica a ordem recomendada de leitura e execucao naquele dominio, nao uma numeracao global unica.

## Fonte de verdade atual

### Home
1. `docs/specs/home/01-home-showcase-brand-search.md`
   - Spec vigente da Home.
   - Define showcase, busca compacta, chips locais, Home brand content e destacados.
2. `docs/specs/home/02-search-results-api-integration.md`
   - Proximo corte publico natural.
   - Transforma `/search` de placeholder em resultados via `GET /api/v1/properties/search`.

### Backend
1. `docs/specs/backend/01-node-postgres-platform.md`
   - Visao consolidada do backend Node/Fastify + PostgreSQL.
   - Cobre endpoints publicos, auth, admin users e properties em nivel de plataforma.
2. `docs/specs/backend/02-auth-jwt-postgres-admin-brokers.md`
   - Fonte vigente para autenticacao e autorizacao.
   - Substitui as specs historicas com Firebase.

### Admin
1. `docs/specs/admin/01-admin-lifecycle-brokers.md`
   - Area admin operacional e gerenciamento inicial de corretores.
   - Tem sobreposicao proposital com auth/admin users, mas foca na experiencia administrativa.

### Properties
1. `docs/specs/properties/01-broker-admin-properties-crud.md`
   - CRUD v1 de imoveis para broker/admin.
   - Status: primeira versao funcional implementada, com pendencias de testes e validacao Flutter.
2. `docs/specs/properties/02-unified-property-form.md`
   - Formulario dedicado e centralizado de propriedades.
   - Deve ser revisada contra o estado atual do codigo antes de virar fonte de execucao, pois o repo ja possui arquivos de `property_form_*` e rotas draft/admin.

### Media
1. `docs/specs/media/01-r2-media-upload.md`
   - Upload R2 pelo backend, ciclo de vida de midia e `pending_delete`.
   - Status: primeiro corte backend implementado; integracao Flutter precisa ser confirmada contra o codigo atual.

### Historico
- `docs/specs/_archive/Home/01-home-showcase-initial-filters.md`
  - Substituida pela Home showcase atual.
- `docs/specs/_archive/Users/01-firebase-auth-accesses.md`
  - Historico Firebase Auth.
- `docs/specs/_archive/Users/02-firebase-admin-users-crud.md`
  - Historico Firebase/Cloud Functions para CRUD admin.

## Duplicidades e decisoes ja resolvidas

1. Home tinha duas specs ativas no mesmo dominio.
   - Resolvido: Home 1.1 foi para `_archive`; Home 1.2 virou `home/01`.

2. Users tinha tres specs com direcoes conflitantes.
   - Resolvido: specs Firebase foram para `_archive`; auth PostgreSQL/JWT virou `backend/02`.

3. A numeracao global antiga se chocava entre dominios (`Spec 1.2` para Home e Users).
   - Resolvido: agora a numeracao e local por pasta.

## Pontos que precisam de resposta

1. Qual endpoint deve ser oficial para criar corretor?
   - `backend/02` define `POST /api/v1/admin/users` com `role=broker`.
   - `admin/01` define `POST /api/v1/admin/brokers`, senha temporaria gerada no backend e envio por Gmail SMTP.
   - O codigo atual possui `admin-users.routes.ts` e `admin-brokers.routes.ts`. Precisamos decidir se os dois continuam ou se um vira legado.

2. A criacao de corretor deve aceitar senha manual ou sempre gerar senha temporaria por e-mail?
   - `backend/02` aceita `password` no body.
   - `admin/01` diz que a UI nao exibe senha e o backend envia por Gmail SMTP.

3. O formulario centralizado de propriedades ainda esta "planejado" ou ja deve ser marcado como parcialmente implementado?
   - A spec `properties/02` diz planejada.
   - O codigo ja tem `property_form_page.dart`, `property_form_controller.dart`, rotas new/edit e drafts admin/broker no backend.

4. O fluxo definitivo de publicacao do broker e `pending_review` ou ainda pode publicar direto em alguma tela v1?
   - Specs mais novas apontam `pending_review`.
   - `properties/01` registra que o CRUD v1 criava como `published`.

5. Pedido de destaque e pendencias admin entram antes ou depois do formulario centralizado?
   - As decisoes de produto mencionam destaque com aprovacao.
   - Ainda nao existe uma spec dedicada de `Admin/Pendencias` ou `Highlights`.

6. Bairros/sub-bairros precisam de CRUD proprio antes de endurecer filtros e formulario?
   - `levantamentos.md` diz que devem ser gerenciados por CRUD.
   - Ainda nao ha spec dedicada para localidades.

## Ordem recomendada hoje

1. Fechar as perguntas 1 a 4 para remover conflito entre admin/auth/properties.
2. Atualizar `properties/02` para refletir o que ja existe no codigo.
3. Executar ou revisar `home/02` se `/search` ainda estiver pendente.
4. Criar specs novas para `Admin/Pendencias`, `PropertyLocations` e `Highlights`, se esses blocos forem prioridade.
