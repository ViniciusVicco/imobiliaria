# Guia de Auth Propria JWT + PostgreSQL

## Visao geral
A autenticacao vigente da Seletta e propria do backend Node/Fastify com PostgreSQL.

Firebase nao participa mais do fluxo de autenticacao, perfil, roles, claims ou CRUD de usuarios.

Regras centrais:
- PostgreSQL e a fonte de verdade para usuario, `role` e `is_active`.
- Senhas sao armazenadas apenas como hash em `users.password_hash`.
- O backend emite JWT Bearer no login.
- O JWT identifica a sessao, mas permissoes finais sempre sao validadas pelo backend consultando o usuario no banco.
- O frontend nunca deve liberar acesso por confiar em enum local, `isAdmin`, `role` enviado pelo cliente ou estado manipulavel.

Spec fonte de verdade:
- `docs/specs/users/USERS_SPEC_DRIVEN_1.2_POSTGRES_AUTH_ADMIN_BROKERS.md`

## Fluxo de login
Endpoint:

```txt
POST /api/v1/auth/login
```

Body:

```json
{
  "email": "admin@seletta.local",
  "password": "AdminLocal123!"
}
```

Resposta esperada:

```json
{
  "accessToken": "jwt",
  "user": {
    "id": "user_id",
    "email": "admin@seletta.local",
    "name": "Admin Local",
    "phone": "",
    "role": "admin",
    "isActive": true
  }
}
```

Regras:
- Email e senha sao validados no backend.
- A senha e comparada contra `password_hash`.
- Usuario inativo nao faz login.
- A resposta nunca retorna senha ou hash.

## Sessao atual
Endpoint:

```txt
GET /api/v1/me
```

Header:

```txt
Authorization: Bearer <accessToken>
```

Respostas esperadas:
- `200`: token valido e usuario ativo encontrado no PostgreSQL.
- `401`: token ausente, invalido ou expirado.
- `403`: usuario existe, mas esta inativo.
- `404`: token aponta para usuario que nao existe mais no banco.

Regra importante:
- A role usada para autorizacao vem do PostgreSQL em cada request protegido, nao do frontend.

## Usuario local inicial
O seed cria/atualiza um admin local para desenvolvimento.

Defaults:

```txt
FIRST_ADMIN_EMAIL=admin@seletta.local
FIRST_ADMIN_PASSWORD=AdminLocal123!
FIRST_ADMIN_NAME=Admin Local
```

Esses valores podem ser sobrescritos por variaveis de ambiente no backend.

Para criar/atualizar o admin local:

```powershell
npm.cmd run prisma:seed
```

## Rotas protegidas
Middlewares principais:

```txt
requireAuthenticatedUser
requireActiveAdmin
requireActiveBroker
```

Responsabilidades:
- `requireAuthenticatedUser`: valida JWT Bearer, carrega usuario do banco e bloqueia usuario ausente/inativo.
- `requireActiveAdmin`: exige usuario ativo com `role=admin`.
- `requireActiveBroker`: aceita `role=broker` e tambem `role=admin` quando a rota permite capacidade equivalente de corretor.

O frontend pode usar guards para melhorar UX, mas a seguranca real precisa continuar no backend.

## Admin Users
Todas as rotas abaixo exigem admin ativo.

Endpoints principais:

```txt
GET /api/v1/admin/users
POST /api/v1/admin/users
GET /api/v1/admin/users/:id
PATCH /api/v1/admin/users/:id
PATCH /api/v1/admin/users/:id/password
```

Regras:
- Admin pode criar admin ou corretor.
- Admin pode editar nome, telefone, role e status.
- Admin pode trocar senha temporaria de outro usuario.
- Admin nao pode desativar a propria conta.
- A API deve impedir que o ultimo admin ativo seja desativado ou rebaixado.

## Relatorio por corretor
Endpoint:

```txt
GET /api/v1/admin/reports/brokers-property-summary
```

Requer admin ativo.

Retorna a quantidade de imoveis sob responsabilidade de cada corretor, incluindo contagens por status.

## Comandos uteis
Execute a partir de `backend/`.

Build TypeScript:

```powershell
npm.cmd run build
```

Validar schema Prisma:

```powershell
npx.cmd prisma validate
```

Aplicar migrations no banco local:

```powershell
npx.cmd prisma migrate deploy
```

Rodar seed:

```powershell
npm.cmd run prisma:seed
```

Gerar Prisma Client:

```powershell
npx.cmd prisma generate
```

Se no Windows o Prisma falhar com erro `EPERM` ao trocar `query_engine-windows.dll.node`, provavelmente algum processo Node/Prisma esta segurando a DLL. Para atualizar os tipos sem trocar a engine:

```powershell
npx.cmd prisma generate --no-engine
```

## Checklist de teste manual
1. Rodar migrations:
   ```powershell
   npx.cmd prisma migrate deploy
   ```

2. Rodar seed:
   ```powershell
   npm.cmd run prisma:seed
   ```

3. Fazer login com admin local:
   ```txt
   POST /api/v1/auth/login
   ```

4. Copiar `accessToken` da resposta.

5. Chamar sessao atual:
   ```txt
   GET /api/v1/me
   Authorization: Bearer <accessToken>
   ```

6. Chamar lista de usuarios:
   ```txt
   GET /api/v1/admin/users
   Authorization: Bearer <accessToken>
   ```

7. Chamar relatorio:
   ```txt
   GET /api/v1/admin/reports/brokers-property-summary
   Authorization: Bearer <accessToken>
   ```

8. Testar token ausente:
   ```txt
   GET /api/v1/me
   ```
   Resultado esperado: `401`.

9. Testar token invalido:
   ```txt
   GET /api/v1/me
   Authorization: Bearer token-invalido
   ```
   Resultado esperado: `401`.
