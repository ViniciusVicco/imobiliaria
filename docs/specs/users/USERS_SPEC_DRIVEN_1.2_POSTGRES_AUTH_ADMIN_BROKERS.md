# Spec 1.2 - Auth propria PostgreSQL e CRUD de Admins/Corretores

## Versionamento
- Supersedes: `USERS_SPEC_DRIVEN_1.0.md` para autenticacao/autorizacao.
- Supersedes: `USERS_SPEC_DRIVEN_1.1_ADMIN_USERS_CRUD.md` para CRUD administrativo.
- Motivo: a plataforma nao usara mais Firebase Auth, Firestore, Cloud Functions ou Custom Claims para usuarios. A identidade, senha, sessao, perfil e permissoes passam a ser responsabilidade do backend Node + PostgreSQL.

## Contexto
A plataforma Seletta tem area publica para clientes e areas restritas para corretores e administradores.

Clientes publicos nao terao login nesta fase. Eles navegam pela Home, busca e detalhes publicados sem autenticacao, e fluxos de contato devem ser tratados como leads em specs futuras.

Corretores e administradores precisam autenticar por email/senha propria da plataforma. A seguranca nao pode depender do Flutter: o app pode ter guards para UX, mas toda autorizacao real deve acontecer no backend, validando token Bearer, usuario ativo e role atual no PostgreSQL.

## Decisoes fechadas
- Firebase nao sera usado para autenticacao, perfil, roles, claims ou CRUD de usuarios.
- Auth oficial: backend Node/Fastify com senha local armazenada como hash seguro no PostgreSQL.
- Sessao oficial: JWT Bearer enviado pelo Flutter em `Authorization: Bearer <accessToken>`.
- Fonte de verdade para permissao: tabela `users` no PostgreSQL.
- Roles oficiais: `admin` e `broker`.
- Cliente publico: sem autenticacao nesta fase.
- Exclusao/desativacao de usuario administrativo: soft delete funcional com `is_active=false`.
- Primeiro admin: seed/script local controlado, nunca credencial hardcoded no app.
- Frontend nunca envia nem decide `isAdmin`, `role` ou `isActive` para liberar acesso.

## Escopo
Em escopo:
- Definir modelo relacional de usuarios com senha local.
- Definir login/logout/me com JWT Bearer.
- Definir middleware backend para autenticacao e autorizacao por role.
- Definir CRUD administrativo de admins e corretores.
- Definir relatorio inicial de quantidade de imoveis por corretor.
- Definir migracao do Flutter para auth via API propria.

Fora de escopo:
- Autenticacao de clientes publicos.
- Recuperacao completa de senha por email.
- Refresh token persistente.
- CRUD completo de imoveis.
- Upload de fotos.
- Leads persistidos.
- Auditoria detalhada de acoes administrativas.

## Perfis e permissoes
### Publico
- Acessa `/home`, `/search` e detalhes publicos sem login.
- Nao recebe role.
- Nao acessa rotas administrativas ou de corretor.

### Corretor (`broker`)
- Acessa area protegida de corretor quando `is_active=true`.
- Pode cadastrar imoveis vinculados ao proprio usuario.
- Pode ver, editar e dar baixa apenas em imoveis com `broker_id` igual ao proprio usuario.
- Nao pode listar, criar, editar ou desativar usuarios.
- Nao pode acessar relatorios administrativos.

### Admin (`admin`)
- Pode fazer tudo que o corretor faz.
- Pode ver e editar imoveis de todos os corretores.
- Pode criar, editar, desativar e alterar role de admins/corretores.
- Pode visualizar relatorios, incluindo quantidade de imoveis cuidados por corretor.
- Nao pode desativar a propria conta pela UI/API v1.

## Modelo relacional
### `users`
- `id`: primary key interna.
- `name`: nome exibido.
- `email`: unico, usado no login.
- `phone`: opcional.
- `password_hash`: hash seguro da senha.
- `role`: enum `admin` ou `broker`.
- `is_active`: boolean.
- `created_at`.
- `updated_at`.
- `created_by`: FK opcional para `users`.
- `updated_by`: FK opcional para `users`.
- `last_login_at`: opcional.

### `properties`
- Manter relacao com corretor responsavel por `broker_id`.
- Rotas de corretor sempre filtram pelo usuario autenticado.
- Rotas admin podem acessar todos os registros.

## Contratos de API
Base path:
```txt
/api/v1
```

Autenticacao:
```txt
Authorization: Bearer <accessToken>
```

Formato de erro:
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Seu perfil nao pode acessar esta area."
  }
}
```

### `POST /auth/login`
Publico.

Body:
```json
{
  "email": "admin@seletta.com.br",
  "password": "senha"
}
```

Resposta:
```json
{
  "accessToken": "jwt",
  "user": {
    "id": "user_id",
    "email": "admin@seletta.com.br",
    "name": "Admin",
    "phone": "",
    "role": "admin",
    "isActive": true
  }
}
```

Regras:
- Validar email/senha contra `users.password_hash`.
- Nao retornar `password_hash`.
- Bloquear login de usuario inativo.
- Atualizar `last_login_at` quando existir no schema.

### `GET /me`
Autenticado.

Resolve a sessao atual a partir do JWT e carrega o usuario atual no PostgreSQL.

Regras:
- Sem token ou token invalido: `401`.
- Usuario inexistente: `404 PROFILE_NOT_FOUND`.
- Usuario inativo: `403 INACTIVE_USER`.
- Role sempre vem do banco, nao do payload enviado pelo front.

### `POST /auth/logout`
Autenticado, opcional na v1.

Como o JWT Bearer inicial pode ser stateless, logout no Flutter pode apenas descartar o token. O endpoint fica reservado para auditoria/revogacao futura.

### `GET /admin/users`
Admin ativo.

Query params:
- `query`: nome/email.
- `role`: `admin` ou `broker`.
- `isActive`: boolean.
- `page`: default `1`.
- `pageSize`: default `20`.

### `POST /admin/users`
Admin ativo.

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
- Gerar `password_hash` no backend.
- Permitir apenas `admin` ou `broker`.
- Nunca retornar senha ou hash.

### `GET /admin/users/:id`
Admin ativo.

Retorna perfil administrativo por id.

### `PATCH /admin/users/:id`
Admin ativo.

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
- Email fica somente leitura na v1.
- Bloquear auto-desativacao do proprio admin.
- Bloquear remocao da ultima conta admin ativa.

### `PATCH /admin/users/:id/password`
Admin ativo.

Define nova senha temporaria para admin/corretor.

Body:
```json
{
  "password": "nova-senha-temporaria"
}
```

### `GET /admin/reports/brokers-property-summary`
Admin ativo.

Retorna quantidade de imoveis por corretor.

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

## Middleware de seguranca
### `requireAuthenticatedUser`
- Lê JWT Bearer.
- Valida assinatura e expiracao.
- Carrega usuario no PostgreSQL.
- Anexa usuario ao request.
- Bloqueia usuario inexistente ou inativo.

### `requireActiveBroker`
- Aceita `broker` ativo.
- Aceita `admin` ativo quando a rota permitir capacidades equivalentes de corretor.

### `requireActiveAdmin`
- Aceita apenas `admin` ativo.

Regra critica:
- O JWT pode conter `sub`/`userId`, mas a role final usada na autorizacao deve ser lida do PostgreSQL em cada request protegido.

## Flutter
- Remover uso de Firebase Auth/Firestore do fluxo novo de usuarios.
- `AuthDatasource` deve chamar `POST /auth/login`, `GET /me` e logout local/API.
- Token Bearer deve ser enviado apenas por datasources HTTP em rotas protegidas.
- Guards de UI continuam, mas apenas refletem o resultado de `/me`.
- CRUD admin segue o fluxo `widget -> controller -> useCase -> repository -> datasource`.

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra `try/catch`, mapeamento de erro e `Failure`? [ ]
- Datasource concentra chamadas HTTP via `RestClient`? [ ]
- Backend valida token, usuario ativo e role em toda rota protegida? [ ]
- Frontend nunca decide permissao a partir de enum local? [ ]

## Criterios de aceite
1. Dado email/senha validos de admin ativo, quando login executa, entao API retorna token e perfil.
2. Dado senha invalida, quando login executa, entao API retorna erro sem revelar detalhes sensiveis.
3. Dado token ausente/invalido, quando rota protegida e chamada, entao API retorna `401`.
4. Dado usuario inativo, quando chama rota protegida, entao API retorna `403`.
5. Dado broker ativo, quando chama `/admin/users`, entao API retorna `403`.
6. Dado admin ativo, quando cria corretor, entao usuario e salvo no PostgreSQL com senha hasheada.
7. Dado admin ativo, quando desativa corretor, entao corretor perde acesso funcional.
8. Dado broker ativo, quando lista imoveis protegidos, entao recebe apenas seus proprios imoveis.
9. Dado admin ativo, quando consulta relatorio de corretores, entao recebe contagem de imoveis por corretor.
10. Dado usuario tenta alterar `role` no front, quando chama rota protegida, entao backend ignora qualquer role enviada e valida pelo banco.

## Testes obrigatorios
### Backend
- Login sucesso e erro.
- Hash de senha nao retorna em nenhuma resposta.
- `/me` com token valido, invalido e usuario inativo.
- Middleware bloqueia broker em rota admin.
- Admin cria, edita, desativa e troca role de usuario.
- Auto-desativacao de admin e bloqueada.
- Ultimo admin ativo nao pode ser desativado/rebaixado.
- Relatorio agrega imoveis por corretor.

### Flutter Unit/Widget
- Repository mapeia erro de auth para `Failure`.
- Login chama usecase e persiste sessao local.
- Guard redireciona usuario sem sessao.
- Guard bloqueia broker em rota admin.
- Lista admin users mostra loading, sucesso, vazio e erro.

### Integracao
- Login -> `/me` -> acesso admin users.
- Broker logado nao acessa admin users.
- Usuario inativo nao acessa broker/admin.

## Ordem recomendada de entrega
1. Atualizar schema Prisma de `users` com `password_hash` e campos de auditoria necessarios.
2. Criar seed/script do primeiro admin local.
3. Implementar `POST /auth/login` e `GET /me`.
4. Criar middlewares `requireAuthenticatedUser`, `requireActiveAdmin` e `requireActiveBroker`.
5. Implementar Admin Users no backend.
6. Migrar Flutter AuthDatasource/AuthRepository para HTTP.
7. Criar UI CRUD `/admin/users`.
8. Implementar relatorio simples por corretor.
9. Cobrir testes focados.

## Definition of Done
- Firebase nao participa de auth, perfil, roles ou CRUD de usuarios.
- PostgreSQL e a fonte de verdade para permissao.
- Senhas sao armazenadas apenas como hash.
- Rotas protegidas validam token, usuario ativo e role no backend.
- Admin gerencia admins/corretores.
- Corretor nao acessa dados administrativos.
- Clientes publicos continuam sem login.
