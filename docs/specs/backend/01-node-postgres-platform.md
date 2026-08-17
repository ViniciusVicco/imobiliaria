# Spec 2.0 - Backend Node + PostgreSQL

## Visao De Produto
A plataforma Seletta precisa sair de mocks e dependencias externas de identidade/dominio para uma base relacional com backend proprio, mantendo velocidade de desenvolvimento local e reduzindo custo/complexidade inicial.

A nova direcao e:

```txt
Flutter Web/Mobile
  -> Datasource HTTP
  -> Backend Node
  -> PostgreSQL local/dev/prod
```

Setup local de banco:
```sql
CREATE USER admin_local WITH PASSWORD 'sua_senha_local';
CREATE DATABASE seletta_local OWNER admin_local;
CREATE DATABASE seletta_shadow OWNER admin_local;
```

A autenticacao passa a ser propria do backend. O PostgreSQL guarda usuarios, senha com hash, roles e status ativo; o backend emite e valida JWT Bearer e aplica as regras de negocio por role.

## Objetivos
- Criar API propria para Home, Search, Auth/Profile, Admin Users e propriedades protegidas.
- Usar PostgreSQL local para desenvolvimento rapido e barato.
- Manter a arquitetura Flutter atual: `widget -> controller -> useCase -> repository -> datasource`.
- Trocar fluxos legados de autenticacao/dominio por HTTP API propria.
- Centralizar regras sensiveis no backend.
- Preparar deploy futuro em Cloud Run, Render, Railway, Fly.io ou VPS.

## Estado Atual Implementado
- Backend criado em `backend/` com Node, Fastify, Prisma, Zod e PostgreSQL.
- Banco local validado com `seletta_local` e `seletta_shadow`.
- Prisma migration e seed executados com sucesso.
- Seed populou `brand_content` e 9 registros iniciais em `properties`.
- Segmentos publicos foram consolidados em `residential` e `commercial`.
- `Na planta` e demais destaques comerciais foram movidos para tags (`tag_slugs`) com catalogo `property_tags`.
- VS Code possui tasks/launch:
  - `front-end-local`
  - `back-end-local`
  - compound `local-full-stack`
- Flutter Home foi ligado aos endpoints HTTP via `RestClient`, com fallback para mocks.
- `RestClient`, `RestClientAbstract` e `RestEnv` foram adicionados/exportados no `packages/core`.
- Endpoints da feature Home foram centralizados em `PropertySegmentsEndpoints`.
- CRUD protegido de propriedades, ciclo de vida de midia R2 e perfil do corretor foram adicionados desde a versao inicial desta spec.

## Publicos E Papeis
- Publico: navega Home, busca imoveis e consulta detalhes publicados.
- Broker: acessa area protegida, gerencia seus proprios imoveis.
- Admin: gerencia usuarios e imoveis de todos.

## Principios De API
- Base path: `/api/v1`.
- Respostas JSON.
- Autenticacao por header:

```txt
Authorization: Bearer <access_token>
```

- Rotas publicas nunca retornam dados administrativos.
- Rotas publicas retornam apenas imoveis `published`.
- Admin/Broker devem ser validados no backend, nao apenas no Flutter.
- Erros devem seguir formato consistente:

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Seu perfil nao pode acessar esta area."
  }
}
```

## Modulos Do Backend
### Health
Usado para monitoramento e validacao de ambiente.

### Home
Entrega conteudo da vitrine inicial.

### Search
Entrega busca publica e detalhes publicos.

### Auth/Profile
Resolve sessao atual a partir do JWT Bearer e perfil no PostgreSQL.

### Admin Users
Permite que admins gerenciem corretores e administradores.

### Broker Properties
Cadastro e manutencao de imoveis pelo corretor/admin foram detalhados na spec propria:
`docs/specs/properties/02-unified-property-form.md`.

### Leads
Fase futura para contatos de clientes publicos.

## Endpoints MVP
### Health
#### `GET /api/v1/health`
Publico.

Retorna status da API e conexao com banco.

Resposta:
```json
{
  "status": "ok",
  "database": "ok",
  "version": "1.0.0"
}
```

## Home
### `GET /api/v1/home/brand-content`
Publico.

Entrega missao, sobre, contato e video usados na Home.

Resposta:
```json
{
  "mission": "Conectar pessoas a imoveis em Palmas com clareza, criterio e acompanhamento humano.",
  "about": "A Seletta atua na curadoria de oportunidades residenciais, comerciais e de investimento em Palmas e regiao.",
  "contact": {
    "phone": "(63) 3000-0000",
    "email": "contato@seletta.com.br",
    "whatsapp": "(63) 99997-3336"
  },
  "videoProvider": "youtube",
  "videoTitle": "Conheca a Seletta",
  "videoThumbnailUrl": "https://img.youtube.com/vi/OGEEQ9VEEmc/maxresdefault.jpg",
  "videoUrl": "https://www.youtube.com/watch?v=OGEEQ9VEEmc"
}
```

### `GET /api/v1/home/featured-properties`
Publico.

Query params:
- `limit`: default `6`.

Regra:
- retornar apenas `status=published` e `isFeatured=true`.

Resposta:
```json
{
  "items": [
    {
      "id": "prop_001",
      "title": "Apartamento com varanda gourmet",
      "segment": "residential",
      "propertyType": "Apartamento",
      "tags": ["pronto-para-morar"],
      "city": "Palmas",
      "neighborhood": "Plano Diretor Sul",
      "subNeighborhood": "706 Sul",
      "coverUrl": "https://...",
      "areaM2": 82,
      "bedrooms": 2,
      "bathrooms": 2,
      "garageSpaces": 1,
      "propertyAgeYears": 4,
      "price": 850000
    }
  ]
}
```

## Search
### `GET /api/v1/properties/search`
Publico.

Query params:
- `city`: default `Palmas`.
- `segment`: `residential`, `commercial`.
- `propertyType`.
- `tag`: filtra por slug visual, por exemplo `na-planta`.
- `blockOrNeighborhood`.
- `query`.
- `bedroomsMin`.
- `bathroomsMin`.
- `garageSpacesMin`.
- `priceMin`.
- `priceMax`.
- `page`: default `1`.
- `pageSize`: default `24`.

Regra:
- retornar apenas `status=published`.
- `blockOrNeighborhood` deve buscar em `neighborhood` e `subNeighborhood`.
- `query` deve buscar em titulo e descricao.
- `segment=investments` deve ser aceito temporariamente e normalizado para `tag=na-planta`.
- respostas publicas retornam no maximo 3 tags por imovel.

Resposta:
```json
{
  "items": [],
  "pagination": {
    "page": 1,
    "pageSize": 24,
    "total": 0,
    "totalPages": 0
  }
}
```

### `GET /api/v1/properties/:id`
Publico para imovel publicado.

Regra:
- publico so acessa `status=published`.
- admin pode acessar qualquer status em endpoint admin futuro.

Resposta:
```json
{
  "id": "prop_001",
  "title": "Apartamento com varanda gourmet",
  "description": "",
  "segment": "residential",
  "propertyType": "Apartamento",
  "city": "Palmas",
  "neighborhood": "Plano Diretor Sul",
  "subNeighborhood": "706 Sul",
  "media": [],
  "facts": {
    "areaM2": 82,
    "bedrooms": 2,
    "bathrooms": 2,
    "garageSpaces": 1,
    "propertyAgeYears": 4
  },
  "price": 850000
}
```

## Auth/Profile
### `POST /api/v1/auth/login`
Publico.

Autentica admin/corretor com email e senha local.

Body:
```json
{
  "email": "user@email.com",
  "password": "senha"
}
```

Resposta:
```json
{
  "accessToken": "jwt",
  "user": {
    "id": "user_id",
    "email": "user@email.com",
    "name": "Nome",
    "phone": "",
    "role": "admin",
    "isActive": true
  }
}
```

Regras:
- validar senha contra `password_hash`;
- usuario inativo nao faz login;
- nunca retornar senha ou hash.

### `GET /api/v1/me`
Autenticado.

Resolve o usuario atual a partir do JWT Bearer.

Resposta:
```json
{
  "id": "user_id",
  "email": "user@email.com",
  "name": "Nome",
  "phone": "",
  "role": "admin",
  "isActive": true
}
```

Regras:
- se nao houver token ou token for invalido, retornar `401`.
- se nao houver perfil no PostgreSQL, retornar `404 PROFILE_NOT_FOUND`.
- se `isActive=false`, retornar `403 INACTIVE_USER`.
- role e status usados para autorizacao sempre devem vir do PostgreSQL.

### `POST /api/v1/auth/logout`
Opcional no backend.

Na v1 com JWT Bearer stateless, o logout do Flutter pode descartar o token localmente. Este endpoint fica reservado para auditoria/revogacao futura.

## Admin Users
Todas as rotas exigem admin ativo.

### `GET /api/v1/admin/users`
Lista usuarios administrativos.

Query params:
- `query`: nome/email.
- `role`: `admin` ou `broker`.
- `isActive`: boolean.
- `page`: default `1`.
- `pageSize`: default `20`.

Resposta:
```json
{
  "items": [
    {
      "id": "user_id",
      "name": "Nome",
      "email": "user@email.com",
      "phone": "",
      "role": "broker",
      "isActive": true,
      "createdAt": "2026-05-29T00:00:00.000Z",
      "updatedAt": "2026-05-29T00:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### `POST /api/v1/admin/users`
Cria admin ou corretor.

Body:
```json
{
  "name": "Nome",
  "email": "user@email.com",
  "phone": "",
  "role": "broker",
  "password": "senha-inicial"
}
```

Regras:
- criar perfil no PostgreSQL.
- gerar `password_hash` no backend.
- permitir apenas roles `admin` e `broker`.
- nunca retornar senha ou hash.

### `GET /api/v1/admin/users/:id`
Retorna perfil administrativo por id.

### `PATCH /api/v1/admin/users/:id`
Atualiza nome, telefone, role e status.

Body:
```json
{
  "name": "Nome Atualizado",
  "phone": "",
  "role": "admin",
  "isActive": true
}
```

Regras:
- email fica somente leitura na v1.
- role/status sao atualizados apenas no PostgreSQL.
- bloquear auto-desativacao do proprio admin.
- bloquear desativacao/rebaixamento do ultimo admin ativo.

### `PATCH /api/v1/admin/users/:id/status`
Ativa ou desativa usuario.

Body:
```json
{
  "isActive": false
}
```

### `PATCH /api/v1/admin/users/:id/role`
Altera role.

Body:
```json
{
  "role": "admin"
}
```

### `GET /api/v1/admin/reports/brokers-property-summary`
Admin ativo.

Resume a quantidade de imoveis sob responsabilidade de cada corretor.

Resposta:
```json
{
  "items": [
    {
      "brokerId": "broker_id",
      "brokerName": "Nome",
      "brokerEmail": "broker@email.com",
      "totalProperties": 12,
      "draftProperties": 2,
      "publishedProperties": 8,
      "soldProperties": 1,
      "inactiveProperties": 1
    }
  ]
}
```

## Broker Properties - Spec Propria
Detalhamento oficial: `docs/specs/properties/02-unified-property-form.md`.

### `GET /api/v1/broker/properties`
Broker ativo lista apenas seus imoveis.

### `POST /api/v1/broker/properties`
Broker cria imovel proprio em `published` na v1 definida pela Spec 4.0.

### `GET /api/v1/broker/properties/:id`
Broker acessa apenas imovel com `brokerId`/`broker_id` igual ao proprio usuario autenticado.

### `PATCH /api/v1/broker/properties/:id`
Broker edita apenas imovel proprio.

### `PATCH /api/v1/broker/properties/:id/status`
Broker muda status permitido dentro de seu escopo.

## Admin Properties - Spec Propria
Detalhamento oficial: `docs/specs/properties/02-unified-property-form.md`.

### `GET /api/v1/admin/properties`
Admin lista todos os imoveis.

### `PATCH /api/v1/admin/properties/:id`
Admin edita qualquer imovel.

### `PATCH /api/v1/admin/properties/:id/status`
Admin publica, inativa ou marca como vendido.

## Leads - Futuro
### `POST /api/v1/leads`
Publico.

Body:
```json
{
  "propertyId": "prop_001",
  "name": "Cliente",
  "phone": "(63) 99999-9999",
  "message": "Tenho interesse neste imovel."
}
```

Regras:
- nao cria usuario autenticado.
- pode exigir rate limit/captcha no futuro.

## Modelo Relacional Inicial
### `users`
- `id` primary key.
- `name`.
- `email` unique.
- `phone`.
- `password_hash`.
- `role`.
- `is_active`.
- `created_at`.
- `updated_at`.
- `created_by`.
- `updated_by`.

### `properties`
- `id` primary key.
- `broker_id` foreign key nullable.
- `title`.
- `description`.
- `segment`.
- `property_type`.
- `tag_slugs`: array de slugs visuais, ex: `na-planta`, `alta-rentabilidade`.
- `city`.
- `neighborhood`.
- `sub_neighborhood`.
- `area_m2`.
- `bedrooms`.
- `bathrooms`.
- `garage_spaces`.
- `property_age_years`.
- `price`.
- `status`.
- `is_featured`.
- `created_at`.
- `updated_at`.

### `property_media`
- `id` primary key.
- `property_id` foreign key.
- `url`.
- `type`.
- `sort_order`.
- `created_at`.

### `property_tags`
- `slug` primary key.
- `label`.
- `description`.
- `is_active`.
- `sort_order`.

### `brand_content`
- `id` primary key.
- `mission`.
- `about`.
- `contact_phone`.
- `contact_email`.
- `contact_whatsapp`.
- `video_provider`.
- `video_title`.
- `video_thumbnail_url`.
- `video_url`.
- `updated_at`.

### `leads`
Futuro.

## Criterios De Aceite MVP
1. Home consome conteudo institucional via API.
2. Home consome imoveis destacados via API.
3. Busca publica retorna apenas imoveis publicados.
4. `/auth/login` valida senha local e retorna JWT Bearer.
5. `/me` valida JWT Bearer e carrega perfil do PostgreSQL.
6. Admin ativo lista usuarios.
7. Admin cria usuario no PostgreSQL com senha hasheada.
8. Broker nao acessa rotas admin.
9. Usuario inativo nao acessa areas restritas.
10. Relatorio admin mostra quantidade de imoveis por corretor.
11. Flutter nao acessa PostgreSQL diretamente.
12. Datasources Flutter usam HTTP API, preservando controllers/usecases/repositories.

## Criterios Ja Atendidos
1. PostgreSQL local criado.
2. Backend local compila e roda.
3. Prisma criou schema inicial.
4. Seed populou propriedades iniciais.
5. Endpoints Home existem no backend.
6. Flutter Home chama API local via datasource HTTP.

## Ordem Recomendada De Entrega
1. Criar backend Node local com `/health`. [done]
2. Criar PostgreSQL local com migrations. [done]
3. Seedar `brand_content` e `properties` a partir dos mocks atuais. [done]
4. Implementar endpoints Home. [done]
5. Implementar endpoint Search. [done no backend]
6. Trocar datasource Flutter de Home para HTTP. [done]
7. Integrar `/search` Flutter com `GET /api/v1/properties/search`. [next]
8. Atualizar schema de usuarios com `password_hash` e seed/script do primeiro admin.
9. Implementar `/api/v1/auth/login` e `/api/v1/me`.
10. Criar middlewares de auth/role no backend.
11. Migrar `AuthRepository` para login e perfil via API propria.
12. Implementar Admin Users.
13. Implementar relatorio simples de imoveis por corretor.
14. Evoluir Broker/Admin Properties conforme `docs/specs/properties/02-unified-property-form.md`.

## Fora Do MVP
- Upload definitivo de imagens.
- CRM completo.
- Relatorios avancados.
- Auditoria visual.
- Pagamentos.
- PostGIS.
- Busca full-text avancada.
