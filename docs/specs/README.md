# Specs Seletta

Este diretorio organiza as specs por dominio de produto. A numeracao dentro de cada pasta indica a ordem recomendada de leitura e execucao naquele dominio, nao uma numeracao global unica.

## Fonte de verdade atual

### Home
1. `docs/specs/home/01-home-showcase-brand-search.md`
   - Spec vigente da Home.
   - Define showcase, busca compacta, chips locais, Home brand content e destacados.

### Estoque
1. `docs/specs/stock/01-public-property-inventory.md`
   - Catalogo publico em `/estoque`, filtros compartilhados, faixa de preco e paginacao `Carregar mais`.
   - `/search` permanece como alias de compatibilidade.

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
2. `docs/specs/admin/02-admin-broker-capabilities.md`
   - Matriz objetiva do que Admin e Broker podem fazer.
   - Lista rotas Flutter, endpoints e use cases por perfil.

### Broker
1. `docs/specs/broker/01-broker-dashboard-profile.md`
   - Painel principal amigavel do corretor em `/broker`.
   - Define tabs `Meus imoveis` e `Meu perfil`, avatar, dados profissionais e troca de senha.

### Properties
1. `docs/specs/properties/02-unified-property-form.md`
   - Fonte vigente do formulario dedicado e centralizado de propriedades.
   - Status: parcialmente implementada; pagina, controller/store, validacao, drafts tecnicos e midia ja existem.

### Media
1. `docs/specs/media/01-r2-media-upload.md`
   - Upload R2 pelo backend, ciclo de vida de midia e `pending_delete`.
   - Status: backend e integracao Flutter implementados no fluxo de propriedades; falta validar operacao e limpeza automatica.

### Historico
- `docs/specs/_archive/Home/01-home-showcase-initial-filters.md`
  - Substituida pela Home showcase atual.
- `docs/specs/_archive/Home/02-search-results-api-integration.md`
  - Integracao inicial de resultados, substituida pela spec dedicada de Estoque.
- `docs/specs/_archive/Users/01-firebase-auth-accesses.md`
  - Historico Firebase Auth.
- `docs/specs/_archive/Users/02-firebase-admin-users-crud.md`
  - Historico Firebase/Cloud Functions para CRUD admin.
- `docs/specs/_archive/Properties/01-broker-admin-properties-crud.md`
  - Baseline historico do CRUD de propriedades; supersedida pelo formulario dedicado de `properties/02` e pelo ciclo de midia de `media/01`.

## Duplicidades e decisoes ja resolvidas

1. Home tinha duas specs ativas no mesmo dominio.
   - Resolvido: Home 1.1 foi para `_archive`; Home 1.2 virou `home/01`.

2. Users tinha tres specs com direcoes conflitantes.
   - Resolvido: specs Firebase foram para `_archive`; auth PostgreSQL/JWT virou `backend/02`.

3. A numeracao global antiga se chocava entre dominios (`Spec 1.2` para Home e Users).
   - Resolvido: agora a numeracao e local por pasta.

## Decisoes consolidadas

1. Existem dois fluxos de criacao de usuario, com responsabilidades diferentes.
   - `POST /api/v1/admin/brokers` e o fluxo de produto para convidar corretor: gera senha temporaria e envia e-mail.
   - `POST /api/v1/admin/users` e o CRUD administrativo generico: aceita `role` e senha informada.
   - A UI de gerenciamento de corretores deve usar `admin/brokers`; `admin/users` fica para operacao administrativa generica.

2. Convite de corretor usa senha temporaria gerada no backend e e-mail. O fluxo generico de usuarios pode aceitar senha manual.

3. O formulario centralizado deixou de ser apenas planejado. A implementacao atual cobre o fluxo principal, mas ainda precisa de testes e acabamento operacional.

4. Broker finaliza em `pending_review`; admin finaliza em `published`. `draft` permanece somente como estado tecnico de pre-cadastro.

5. A central admin de pendencias, revisoes, observacoes e notificacoes foi implementada junto ao fluxo do formulario.
   - Pedidos de destaque como workflow independente continuam fora desta entrega.

6. Bairros/sub-bairros precisam de CRUD proprio antes de endurecer filtros e formulario.
   - `levantamentos.md` diz que devem ser gerenciados por CRUD.
   - Ainda nao ha spec dedicada para localidades.

## Ordem recomendada hoje

1. Cobrir com testes o formulario, midia, revisoes e guards de broker/admin.
2. Validar manualmente o fluxo completo com R2 e SMTP configurados.
3. Implementar notificacao de venda para admins ativos.
4. Validar manualmente Home -> Estoque, filtros e paginacao com a API local.
5. Criar spec dedicada para `PropertyLocations` e `Highlights` quando esses blocos forem prioridade.
