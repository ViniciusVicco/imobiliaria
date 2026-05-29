# Spec 2.0 - Backend Node + PostgreSQL

## Visao De Produto
A plataforma Seletta precisa sair de mocks/Firestore para uma base relacional com backend proprio, mantendo velocidade de desenvolvimento local e reduzindo custo/complexidade inicial.

A nova direcao e:

```txt
Flutter Web/Mobile
  -> Datasource HTTP
  -> Backend Node
  -> PostgreSQL local/dev/prod

CREATE USER admin_local WITH PASSWORD 'sua_senha_local';
CREATE DATABASE seletta_local OWNER admin_local;
CREATE DATABASE seletta_shadow OWNER admin_local;
```

Firebase Auth continua como provedor de identidade no primeiro momento. O backend valida o ID token recebido pelo app e aplica as regras de negocio por role.

## Objetivos
- Criar API propria para Home, Search, Auth/Profile, Admin Users e futuramente Imoveis.
- Usar PostgreSQL local para desenvolvimento rapido e barato.
- Manter a arquitetura Flutter atual: `widget -> controller -> useCase -> repository -> datasource`.
- Trocar Firestore gradualmente por HTTP API.
- Centralizar regras sensiveis no backend.
- Preparar deploy futuro em Cloud Run, Render, Railway, Fly.io ou VPS.

## Publicos E Papeis
- Publico: navega Home, busca imoveis e consulta detalhes publicados.
- Broker: acessa area protegida, gerencia seus proprios imoveis.
- Admin: gerencia usuarios e imoveis de todos.

## Principios De API
- Base path: `/api/v1`.
- Respostas JSON.
- Autenticacao por header:

```txt
Authorization: Bearer <firebase_id_token>
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
Resolve sessao atual a partir do token Firebase e perfil no PostgreSQL.

### Admin Users
Permite que admins gerenciem corretores e administradores.

### Broker Properties
Fase seguinte para cadastro e manutencao de imoveis pelo corretor.

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
- `segment`: `residential`, `commercial`, `investments`.
- `propertyType`.
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
### `GET /api/v1/me`
Autenticado.

Resolve o usuario atual a partir do Firebase ID token.

Resposta:
```json
{
  "uid": "firebase_uid",
  "email": "user@email.com",
  "name": "Nome",
  "phone": "",
  "role": "admin",
  "isActive": true
}
```

Regras:
- se nao houver token, retornar `401`.
- se nao houver perfil no PostgreSQL, retornar `404 PROFILE_NOT_FOUND`.
- se `isActive=false`, retornar perfil, mas guards devem bloquear rotas restritas.

### `POST /api/v1/auth/logout`
Opcional no backend.

O logout principal continua no Firebase Auth do cliente. Este endpoint fica reservado para auditoria futura.

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
      "uid": "firebase_uid",
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
- criar usuario no Firebase Auth.
- criar perfil no PostgreSQL.
- aplicar custom claims minimas.
- nunca retornar senha.

### `GET /api/v1/admin/users/:uid`
Retorna perfil administrativo por uid.

### `PATCH /api/v1/admin/users/:uid`
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
- role/status devem sincronizar custom claims.
- bloquear auto-desativacao do proprio admin.

### `PATCH /api/v1/admin/users/:uid/status`
Ativa ou desativa usuario.

Body:
```json
{
  "isActive": false
}
```

### `PATCH /api/v1/admin/users/:uid/role`
Altera role.

Body:
```json
{
  "role": "admin"
}
```

## Broker Properties - Proxima Fase
### `GET /api/v1/broker/properties`
Broker ativo lista apenas seus imoveis.

### `POST /api/v1/broker/properties`
Broker cria imovel proprio em `draft`.

### `GET /api/v1/broker/properties/:id`
Broker acessa apenas imovel com `brokerId` igual ao proprio uid.

### `PATCH /api/v1/broker/properties/:id`
Broker edita apenas imovel proprio.

### `PATCH /api/v1/broker/properties/:id/status`
Broker muda status permitido dentro de seu escopo.

## Admin Properties - Proxima Fase
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
- `uid` primary key.
- `name`.
- `email` unique.
- `phone`.
- `role`.
- `is_active`.
- `created_at`.
- `updated_at`.
- `created_by`.
- `updated_by`.

### `properties`
- `id` primary key.
- `broker_uid` foreign key nullable.
- `title`.
- `description`.
- `segment`.
- `property_type`.
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
4. `/me` valida token Firebase e carrega perfil do PostgreSQL.
5. Admin ativo lista usuarios.
6. Admin cria usuario sincronizando Firebase Auth e PostgreSQL.
7. Broker nao acessa rotas admin.
8. Usuario inativo nao acessa areas restritas.
9. Flutter nao acessa PostgreSQL diretamente.
10. Datasources Flutter usam HTTP API, preservando controllers/usecases/repositories.

## Ordem Recomendada De Entrega
1. Criar backend Node local com `/health`.
2. Criar PostgreSQL local com migrations.
3. Seedar `brand_content` e `properties` a partir dos mocks atuais.
4. Implementar endpoints Home.
5. Implementar endpoint Search.
6. Trocar datasource Flutter de Home/Search para HTTP.
7. Implementar `/me`.
8. Implementar Admin Users.
9. Criar Broker/Admin Properties em spec propria.

## Fora Do MVP
- Upload definitivo de imagens.
- CRM completo.
- Relatorios.
- Auditoria visual.
- Pagamentos.
- PostGIS.
- Busca full-text avancada.
