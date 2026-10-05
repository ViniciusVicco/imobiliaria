# Fluxo de guarda de rotas autenticadas

Este guia explica como a navegacao protegida funciona hoje no app e como manter novas rotas autenticadas depois do login.

## Ideia central

O frontend guarda apenas o `accessToken` JWT e usa esse token para pedir ao backend quem e o usuario atual. O frontend pode decidir a experiencia de navegacao, como redirecionar para login ou exibir uma tela bloqueada, mas ele nao e a fonte de verdade de permissao.

A fonte de verdade continua sendo o backend com PostgreSQL:

- token JWT identifica a sessao;
- backend valida o JWT;
- backend recarrega o usuario no banco;
- backend confere `role` e `isActive`;
- rotas sensiveis usam middlewares como `requireAuthenticatedUser`, `requireActiveAdmin` e `requireActiveBroker`.

## Fluxo simples

```text
Usuario faz login
  -> POST /api/v1/auth/login
  -> backend valida email/senha no PostgreSQL
  -> backend retorna accessToken + dados publicos do usuario
  -> Flutter salva accessToken em SharedPreferences

Usuario acessa rota protegida
  -> AuthGuardPage chama AuthGuardController.ensureAccess()
  -> controller busca sessao atual
  -> datasource le token salvo
  -> se nao houver token: redireciona para /login?redirect=<rota>
  -> se houver token: chama GET /api/v1/me com Authorization: Bearer <token>

Backend recebe /me
  -> requireAuthenticatedUser valida Bearer token
  -> verifica assinatura/expiracao do JWT
  -> busca usuario no PostgreSQL pelo id do token
  -> bloqueia usuario inexistente ou inativo
  -> devolve usuario atual

Flutter resolve permissao
  -> ResolveProtectedRouteAccessUseCase confere role requerida
  -> admin acessa areas admin e broker
  -> broker acessa apenas areas de broker
  -> se permitido: renderiza a pagina filha
  -> se bloqueado: redireciona ou mostra tela de acesso restrito
```

## Onde o token fica

O token e salvo no Flutter em `SharedPreferences` com a chave:

```text
seletta_access_token
```

Isso acontece depois de um login bem-sucedido em `AuthRepository.signInWithEmailAndPassword`.

As chamadas protegidas feitas pelo `RestClient` passam por um interceptor de autenticacao. Esse interceptor le a chave `seletta_access_token` e adiciona automaticamente:

```text
Authorization: Bearer <accessToken>
```

O interceptor so injeta token em rotas autenticadas conhecidas, como `/me`, `/auth/logout`, `/admin/*` e `/broker/*`. Rotas publicas de home, busca e detalhes continuam sem Bearer token para que erros publicos nao derrubem a sessao autenticada.

Ao abrir uma rota protegida, o app nao confia apenas no token existir. Ele chama `/me`, e o backend confirma se o token ainda e valido e se o usuario ainda existe/esta ativo no banco.

## Como a guarda funciona no Flutter

As rotas protegidas sao declaradas no `MainModule` usando `AuthGuardPage`.

Exemplo conceitual:

```dart
MainRoutes.admin: (context, arguments) => const AuthGuardPage(
  requiredRole: UserRole.admin,
  requestedRoute: MainRoutes.admin,
  child: AdminHomePage(),
),
```

Responsabilidades:

- `AuthGuardPage`: componente visual que mostra loading, pagina liberada ou bloqueio.
- `AuthGuardController`: busca a sessao atual e aplica a regra de acesso.
- `GetCurrentUserSessionUseCase`: pede ao repositorio a sessao atual.
- `AuthRepository.getCurrentSession`: le token salvo e chama `/me`.
- `ResolveProtectedRouteAccessUseCase`: decide se a rota pode abrir, se deve redirecionar ou bloquear.

## Regras atuais de permissao no Flutter

Se nao existe usuario autenticado:

```text
/login?redirect=<rota-original>
```

Se o usuario esta inativo:

```text
Este usuario esta inativo.
```

Se o usuario e `admin`:

```text
acesso permitido
```

Se a rota pede `broker` e o usuario e `broker`:

```text
acesso permitido
```

Se o usuario nao pode acessar a area:

```text
redireciona para /broker
```

## Como o backend protege de verdade

No backend, as rotas protegidas usam `preHandler`.

Exemplos:

```ts
{ preHandler: requireAuthenticatedUser }
{ preHandler: requireActiveAdmin }
{ preHandler: requireActiveBroker }
```

O middleware `requireAuthenticatedUser`:

- exige header `Authorization: Bearer <accessToken>`;
- valida o JWT;
- busca o usuario no PostgreSQL;
- retorna `401` se nao houver token ou o token for invalido;
- retorna `404` se o usuario do token nao existir mais;
- retorna `403` se o usuario estiver inativo;
- anexa `request.authenticatedUser` para a rota usar.

O middleware `requireActiveAdmin`:

- roda `requireAuthenticatedUser`;
- permite apenas `role = admin`.

O middleware `requireActiveBroker`:

- roda `requireAuthenticatedUser`;
- permite `role = broker` ou `role = admin`.

## Como manter novas rotas autenticadas

Para criar uma nova tela protegida no Flutter:

1. Defina a rota em `MainRoutes`.
2. No `MainModule`, envolva a pagina com `AuthGuardPage`.
3. Escolha o `requiredRole` correto: `UserRole.admin` ou `UserRole.broker`.
4. Passe `requestedRoute` com a rota original para permitir redirect pos-login.
5. Use datasources com o `RestClient` injetado; nao monte `Authorization` manualmente.

Para criar um novo endpoint protegido no backend:

1. Use `requireAuthenticatedUser` se qualquer usuario ativo puder acessar.
2. Use `requireActiveBroker` se corretor e admin puderem acessar.
3. Use `requireActiveAdmin` se apenas admin puder acessar.
4. Nunca aceite `role`, `isAdmin` ou permissao vinda do frontend como decisao final.
5. Sempre use `request.authenticatedUser` e/ou uma consulta ao banco para aplicar regras de dominio.

## Exemplo de endpoint admin

```ts
app.post(
  '/admin/brokers',
  { preHandler: requireActiveAdmin },
  async (request, reply) => {
    // Apenas admin ativo chega aqui.
  },
);
```

Mesmo que alguem altere o frontend e tente chamar a API direto, o backend ainda exige:

- token valido;
- usuario existente no PostgreSQL;
- usuario ativo;
- role `admin`.

## Como a sessao se mantem

A sessao se mantem enquanto o token salvo continuar valido. Em cada entrada de rota protegida, o app chama `/me` e confirma a sessao.

Se o token expirar, for removido ou o usuario for desativado:

- o backend retorna erro;
- o interceptor limpa o token local em chamadas autenticadas que retornam `401`, `403` ou `404`;
- o repositorio tambem trata `/me` como sessao invalida nesses casos;
- a guarda passa a tratar como usuario nao autenticado;
- a navegacao volta para login ou mostra bloqueio.

## Logout

Hoje o logout efetivo no Flutter e limpar o token local.

Depois disso:

- `SharedPreferences` nao tem mais `seletta_access_token`;
- `getCurrentSession` retorna `null`;
- qualquer rota protegida redireciona para login.

O backend tambem possui `/auth/logout`, mas como ainda nao existe blacklist/refresh token, o ponto principal da saida local e remover o token salvo no app.

## Pontos de manutencao

- Novos datasources protegidos devem usar o `RestClient` injetado para receber o Bearer token automaticamente.
- Nao duplique leitura de `SharedPreferences` nem monte `Authorization` manualmente nos datasources.
- O interceptor adiciona token apenas em rotas protegidas conhecidas.
- Rotas publicas nao devem limpar sessao mesmo quando retornarem `404`.
- Nao devemos guardar role como fonte de verdade no frontend.
- Se um admin mudar `role` ou `isActive` de um usuario no banco, a proxima chamada protegida deve refletir essa mudanca via `/me` ou middleware da API.

## Checklist para nova rota protegida

- Flutter: declarar a rota em `MainRoutes`.
- Flutter: envolver a pagina com `AuthGuardPage`.
- Flutter: escolher `requiredRole` correto.
- Flutter: usar datasource com `RestClient` injetado.
- Backend: aplicar `requireAuthenticatedUser`, `requireActiveBroker` ou `requireActiveAdmin`.
- Backend: usar `request.authenticatedUser` e/ou consulta ao banco para regras de dominio.
