# Spec 1.1 - Admin Users CRUD

## Status historico
Esta spec foi superseded por `USERS_SPEC_DRIVEN_1.2_POSTGRES_AUTH_ADMIN_BROKERS.md`.

As decisoes sobre Cloud Functions, Firestore, Firebase Auth e Custom Claims nao representam mais a direcao vigente. O CRUD administrativo atual deve usar backend Node + PostgreSQL, senha local com hash e JWT Bearer.

## Contexto
A Spec 1.0 criou a base de autenticacao, sessao, roles e guards para areas restritas. O proximo passo e permitir que admins gerenciem corretores e administradores pela area `/admin/users`.

O CRUD de usuarios precisa preservar a regra de seguranca: o Flutter nao cria usuarios diretamente no Firebase Auth com privilegio administrativo e nao escreve `role`, `isActive` ou claims por conta propria. Operacoes sensiveis passam por Cloud Functions protegidas, e o app consome essas operacoes via datasource/repository/usecase.

## Escopo
Em escopo:
- Listar usuarios administrativos em `/admin/users`.
- Criar corretor/admin por formulario admin.
- Editar dados de perfil: nome, telefone, email visivel, role e status ativo.
- Desativar usuario com soft delete (`isActive=false`).
- Reativar usuario (`isActive=true`).
- Alterar role entre `broker` e `admin`.
- Sincronizar Custom Claims ao criar/alterar role/status.
- Mostrar estados de loading, sucesso, vazio e erro.

Fora de escopo:
- CRUD de imoveis.
- Upload de foto/avatar de usuario.
- Reset de senha completo por painel.
- Exclusao fisica de usuarios no Firebase Auth.
- Auditoria visual completa, logs administrativos detalhados e dashboard definitivo.
- Login por SMS.

## Decisoes recomendadas
- Comecar por `/admin/users` como tabela/lista simples com acoes.
- Criar usuario via Cloud Function `adminCreateUser`.
- Atualizar perfil/role/status via Cloud Function `adminUpdateUser`.
- Nao permitir que admin desative a propria conta pela UI nesta primeira versao.
- Primeiro admin continua sendo criado manualmente/seed controlado.
- `users/{uid}` continua sendo o documento de perfil do usuario.
- Custom Claims devem conter apenas autorizacao minima, por exemplo `admin: true`, `broker: true` e `isActive: true`.

## Modelo de dados
### `users/{uid}`
Campos obrigatorios para o CRUD:
- `uid`: string
- `name`: string
- `email`: string
- `phone`: string opcional
- `role`: `admin` ou `broker`
- `isActive`: boolean
- `createdAt`: timestamp
- `updatedAt`: timestamp
- `createdBy`: uid do admin criador
- `updatedBy`: uid do admin que fez a ultima alteracao

Campos opcionais futuros:
- `lastLoginAt`
- `notes`
- `creci`
- `displayName`

## Cloud Functions
### `adminCreateUser`
Entrada:
```json
{
  "name": "Nome do Usuario",
  "email": "usuario@email.com",
  "phone": "",
  "role": "broker",
  "password": "senha-inicial"
}
```

Comportamento:
- Validar que o chamador esta autenticado, ativo e e `admin`.
- Criar usuario no Firebase Auth.
- Criar documento `users/{uid}`.
- Aplicar Custom Claims de role/status.
- Retornar o perfil criado sem retornar senha.

### `adminUpdateUser`
Entrada:
```json
{
  "uid": "uid",
  "name": "Nome Atualizado",
  "phone": "",
  "role": "admin",
  "isActive": true
}
```

Comportamento:
- Validar que o chamador esta autenticado, ativo e e `admin`.
- Bloquear auto-desativacao do proprio admin na v1.
- Atualizar `users/{uid}`.
- Atualizar Custom Claims quando `role` ou `isActive` mudar.
- Forcar refresh de permissao no proximo login/token refresh do usuario afetado.

## Rotas e UI
Rotas:
- `/admin/users`: lista de usuarios.
- `/admin/users/new`: formulario de criacao.
- `/admin/users/:id/edit`: formulario de edicao.

Lista:
- Colunas/cards: nome, email, telefone, role, status, acoes.
- Acoes: editar, desativar/reativar.
- Filtros simples: busca por nome/email e filtro por role/status.

Formulario:
- Campos: nome, email, telefone, role, status.
- Na criacao: senha inicial obrigatoria.
- Na edicao: email pode ser somente leitura nesta versao, para evitar alteracao parcial entre Auth e Firestore.

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra `try/catch`, mapeamento de erro e `Failure`? [ ]
- Datasource concentra chamadas Firestore/Cloud Functions? [ ]
- UI admin usa guard de `admin` ativo antes de renderizar? [ ]
- Flutter nao escreve `role`, `isActive` ou claims diretamente? [ ]

Camadas previstas:
- `lib/app/domain/users/entities/user_profile_entity.dart`
- `lib/app/domain/users/entities/user_form_entity.dart`
- `lib/app/domain/users/usecases/get_admin_users_use_case.dart`
- `lib/app/domain/users/usecases/create_admin_user_use_case.dart`
- `lib/app/domain/users/usecases/update_admin_user_use_case.dart`
- `lib/app/domain/users/usecases/toggle_user_active_status_use_case.dart`
- `lib/app/data/users/models/user_profile_model.dart`
- `lib/app/data/users/datasources/users_admin_datasource.dart`
- `lib/app/data/users/repositories/users_admin_repository.dart`
- `lib/app/presentation/main/pages/admin/users/`

## Plano tecnico incremental
1. Criar entidades/modelos de perfil e formulario de usuario.
2. Criar datasource/repository/usecases para listar `users`.
3. Criar tela `/admin/users` protegida por guard admin.
4. Criar formulario de criacao em `/admin/users/new`.
5. Criar formulario de edicao em `/admin/users/:id/edit`.
6. Criar Cloud Functions `adminCreateUser` e `adminUpdateUser`.
7. Trocar a criacao/edicao para usar Functions em vez de escrita direta.
8. Criar rules Firestore para negar escrita direta indevida em `users`.
9. Adicionar testes unitarios e widget dos fluxos principais.

## Criterios de aceite
1. Dado um admin ativo, quando acessar `/admin/users`, entao ve a lista de usuarios.
2. Dado um broker ativo, quando acessar `/admin/users`, entao e bloqueado ou redirecionado.
3. Dado um usuario nao logado, quando acessar `/admin/users`, entao vai para `/login`.
4. Dado um admin ativo, quando criar um corretor, entao Auth user, `users/{uid}` e claims sao criados.
5. Dado um admin ativo, quando alterar role de broker para admin, entao Firestore e claims sao sincronizados.
6. Dado um admin ativo, quando desativar usuario, entao `isActive=false` bloqueia acesso funcional.
7. Dado um admin tentando desativar a propria conta, entao a operacao e bloqueada.
8. Dado uma falha de Function/Firestore, quando salvar, entao a UI mostra erro e mantem os dados do formulario.

## Testes obrigatorios
- Unitario:
  - matriz de permissao admin/broker/inativo para CRUD.
  - repository mapeia falhas de Functions para `Failure`.
  - valida formulario de criacao/edicao.
- Widget:
  - lista renderiza loading/sucesso/vazio/erro.
  - formulario cria usuario com campos obrigatorios.
  - broker nao acessa `/admin/users`.
- Integracao/emulator:
  - Function cria Auth user, perfil e claims.
  - Function altera role/status e claims.
  - Firestore Rules bloqueiam escrita direta de `role`/`isActive` pelo Flutter.

## Sugestao de ordem de entrega
1. Primeiro entregar leitura/lista de usuarios em `/admin/users`.
2. Depois criar/editar usando Cloud Functions.
3. Depois desativar/reativar e alterar role.
4. Por ultimo, fechar emulator tests e rules.

Essa ordem permite validar a area administrativa visual rapidamente sem comprometer a seguranca das operacoes sensiveis.
