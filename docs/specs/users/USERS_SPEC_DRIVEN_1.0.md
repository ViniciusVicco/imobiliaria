# Spec 1.0 - Usuarios, Autenticacao e Acessos

## Status historico
Esta spec foi superseded por `USERS_SPEC_DRIVEN_1.2_POSTGRES_AUTH_ADMIN_BROKERS.md`.

As decisoes sobre Firebase Auth, Firestore, Custom Claims e Cloud Functions nao representam mais a direcao vigente. A direcao atual e autenticacao propria no backend Node + PostgreSQL, com JWT Bearer, senha local com hash e PostgreSQL como fonte de verdade para roles e `isActive`.

## Contexto
A plataforma tera area publica para clientes e areas restritas para corretores e administradores.

O cliente nao precisa se autenticar para navegar, buscar imoveis ou iniciar contato. Em alguns fluxos publicos ele podera informar nome e celular, mas isso sera tratado como identificacao temporaria de lead, fora do sistema de autenticacao.

Corretores e administradores precisam acessar rotas protegidas. A seguranca nao pode depender apenas do Flutter: o app deve ter guards para UX, mas a autorizacao real deve ser garantida pelo Firebase Auth, Custom Claims e backend Node/PostgreSQL.

## Decisoes fechadas
- Provider oficial: Firebase.
- Plataforma inicial configurada no Firebase: Web.
- Banco para perfis e imoveis: PostgreSQL via backend Node. Firestore fica legado/temporario ate a migracao completa.
- Login v1 para admin/corretor: email e senha.
- Login por SMS/telefone: preparado para fase futura, nao entra na v1.
- Roles oficiais: `admin` e `broker`.
- Claims de acesso: aplicadas pelo backend via Firebase Admin SDK, nunca escritas diretamente pelo Flutter.
- Perfil editavel do usuario: tabela `users` no PostgreSQL, acessada pelo backend.
- Primeiro admin: seed local/script controlado em ambiente de desenvolvimento ou criacao manual controlada no Firebase; nunca credencial hardcoded no app.
- Exclusao de corretor: soft delete com `isActive=false`.
- Cliente publico: sem autenticacao; nome/celular ficam como lead temporario em memoria nesta spec.

## Escopo
Em escopo:
- Definir modelo de usuario autenticado, roles e status ativo.
- Definir fluxo de login por email/senha.
- Definir guard de rotas para usuarios nao logados, corretores e admins.
- Definir regras de autorizacao esperadas para backend Node/PostgreSQL.
- Definir endpoints administrativos necessarios para criar usuarios e alterar roles/claims.
- Definir rotas iniciais recomendadas para areas restritas.

Fora de escopo:
- CRUD completo de imoveis.
- Upload e gerenciamento de fotos de imoveis.
- Persistencia formal de leads.
- Login por SMS em producao.
- Painel visual definitivo de admin/corretor.

## Perfis e permissoes
### Cliente publico
- Acessa rotas publicas sem login.
- Pode buscar imoveis e abrir fluxos de contato.
- Pode informar nome e celular de forma opcional.
- Nao recebe role, nao cria sessao Firebase e nao acessa dados administrativos.
- Dados temporarios de lead nao devem ser persistidos nesta spec.

### Corretor (`broker`)
- E criado, editado, desativado ou promovido por admin.
- Acessa area restrita de corretor.
- Pode cadastrar imoveis vinculados ao proprio `uid`.
- Pode ver, editar e marcar como vendido apenas imoveis com `brokerId == auth.uid`.
- Nao pode ver, listar, editar ou marcar como vendido imoveis de outros corretores.
- Nao pode listar, criar, editar ou desativar usuarios.
- Pode virar admin quando um admin elevar seu acesso.
- Se `isActive=false`, deve perder acesso funcional as areas restritas.

### Admin (`admin`)
- Pode fazer tudo que um corretor faz.
- Pode ver e editar imoveis de todos os corretores.
- Pode criar, editar, desativar e alterar roles de corretores/admins.
- Pode elevar corretor para admin e rebaixar admin para corretor.
- Admins iniciais devem ser criados por seed/script/Admin SDK/Firebase Console controlado.

## Rotas
Rotas publicas:
- `/home`
- `/search`
- paginas publicas de detalhe, catalogo e contato conforme specs de imoveis

Rotas autenticadas recomendadas:
- `/login`
- `/broker`
- `/broker/properties`
- `/broker/properties/new`
- `/broker/properties/:id/edit`
- `/admin`
- `/admin/users`
- `/admin/properties`

Regras de acesso:
- Usuario nao logado tentando `/broker/*` ou `/admin/*` deve ser redirecionado para `/login`.
- Usuario logado sem role valida deve ser bloqueado.
- `broker` pode acessar `/broker/*`.
- `admin` pode acessar `/admin/*` e tambem fluxos equivalentes de corretor.
- `broker` tentando `/admin/*` deve ser bloqueado ou redirecionado para area de corretor.
- `isActive=false` deve bloquear acesso mesmo que a role exista.

## Modelo de dados
### `users/{uid}`
Campos minimos:
- `uid`: string
- `name`: string
- `email`: string
- `phone`: string opcional
- `role`: `admin` ou `broker`
- `isActive`: boolean
- `createdAt`: timestamp
- `updatedAt`: timestamp
- `createdBy`: uid do admin criador, quando aplicavel
- `updatedBy`: uid do admin que fez a ultima alteracao, quando aplicavel

Observacoes:
- `users/{uid}` guarda dados editaveis de perfil.
- Custom Claims guardam apenas informacao minima de autorizacao, por exemplo `admin: true` ou `broker: true`.
- Claims nao devem carregar dados de perfil, telefone, nome ou informacoes longas.

### Imoveis futuros
Campos minimos esperados para integracao futura:
- `brokerId`: uid do corretor responsavel
- `status`: ativo, vendido, rascunho etc.
- `createdAt`
- `updatedAt`

Regras futuras de imoveis devem usar `brokerId == request.auth.uid` para corretor e claim de admin para acesso global.

## Firebase necessario para comecar
### Firebase Console
1. App Web ja registrado no projeto Firebase.
2. Authentication habilitado com provider Email/Password.
3. Cloud Firestore pode existir como legado, mas nao deve receber novas features de dominio.
4. Backend Node preparado para operacoes administrativas sensiveis.
5. Firebase Emulator Suite recomendado para desenvolvimento local.
6. Storage fica para spec de fotos/imoveis.

### FlutterFire
O app Flutter Web deve usar FlutterFire, nao o snippet JavaScript puro do console Firebase.

Comandos previstos:
```powershell
firebase login
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_auth
flutterfire configure --project=seletta-imobiliaria --platforms=web
```

Arquivos esperados:
- `lib/firebase_options.dart`
- inicializacao de `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` no `main.dart`

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra `try/catch`, mapeamento de erro e `Failure`? [ ]
- Datasource concentra chamadas Firebase Auth ou API HTTP? [ ]
- Guards de UI nao substituem autorizacao real no backend? [ ]

Camadas previstas:
- `lib/app/domain/users/entities/`
- `lib/app/domain/users/usecases/`
- `lib/app/data/users/datasources/`
- `lib/app/data/users/repositories/`
- `lib/app/presentation/authentication/`
- `lib/app/presentation/main/pages/admin/`
- `lib/app/presentation/main/pages/broker/`
- `lib/app/presentation/main/widgets/auth/` para guards usados pelas areas restritas.

## Plano tecnico
1. Configurar Firebase no Flutter Web com `firebase_core` e `firebase_auth`.
2. Criar entidade de sessao autenticada com `uid`, `email`, `role` e `isActive`.
3. Criar repository/datasource de Auth para login/logout.
4. Criar backend endpoint `GET /api/v1/me` para resolver perfil em PostgreSQL.
5. Criar session store global ou controller de sessao para expor usuario atual.
6. Criar guard central de rotas por login, role e `isActive`.
7. Criar tela `/login` por email/senha.
8. Criar placeholders protegidos para `/broker` e `/admin`.
9. Criar endpoints administrativos no backend para criar usuario, alterar role, ativar/desativar e sincronizar Custom Claims.
10. Garantir autorizacao real no backend por token Firebase, role e `isActive`.

## Steps iniciais de implementacao
1. Validar `lib/firebase_options.dart` com as credenciais Web do projeto `seletta-imobiliaria`.
2. Inicializar Firebase no `main.dart` antes do `ModuleApp`.
3. Criar as camadas `users/auth` seguindo `widget -> controller -> useCase -> repository -> datasource`.
4. Implementar login por email/senha com Firebase Auth.
5. Montar a sessao atual com `uid`, `email`, `role` e `isActive` lendo o perfil via `GET /api/v1/me`.
6. Criar guard central para `/broker/*` e `/admin/*`, usando a sessao atual e matriz de permissoes.
7. Criar `/login` e placeholders protegidos para `/broker` e `/admin`.
8. Deixar CRUD de usuarios e endpoints administrativos completos para o proximo incremento.

Decisao de modularizacao inicial:
- Login e fluxo visual de autenticacao ficam em `AuthenticationModule`.
- `MainModule` registra os use cases de sessao necessarios para guards de `/broker/*` e `/admin/*`.
- `AuthenticationModule` usa o `AppNavigator` do `MainModule` para voltar ao destino protegido apos login.

## Regras de seguranca
- O Flutter nunca pode escrever `role`, `isActive` ou claims diretamente sem passar por operacao administrativa protegida no backend.
- Apenas admin ativo pode criar/editar/desativar usuarios.
- Endpoints administrativos devem validar token do chamador antes de executar.
- Backend deve negar por padrao e liberar apenas casos explicitos.
- Server/Admin SDK pode alterar Auth/claims; por isso endpoints administrativos devem validar permissao manualmente.
- Depois de mudar role/claim, o cliente deve forcar refresh do ID token ou exigir novo login para refletir permissao atualizada.

## Criterios de aceite
1. Dado um usuario nao logado, quando tentar acessar `/admin`, entao deve ser enviado para `/login`.
2. Dado um usuario nao logado, quando tentar acessar `/broker`, entao deve ser enviado para `/login`.
3. Dado um corretor ativo, quando acessar `/broker/properties`, entao a rota deve abrir.
4. Dado um corretor ativo, quando acessar `/admin/users`, entao o acesso deve ser bloqueado.
5. Dado um admin ativo, quando acessar `/admin/users`, entao a rota deve abrir.
6. Dado um usuario com `isActive=false`, quando tentar acessar area restrita, entao o acesso deve ser bloqueado.
7. Dado um corretor, quando consultar imoveis protegidos na API, entao ele so pode ler registros com `brokerUid == auth.uid`.
8. Dado um admin, quando consultar imoveis protegidos na API, entao ele pode ler todos.
9. Dado um cliente publico, quando navegar em `/home` e `/search`, entao nenhuma autenticacao deve ser exigida.
10. Dado um cliente publico que informa nome/celular, quando sair do fluxo atual, entao esses dados nao devem criar usuario autenticado.

## Testes obrigatorios
- Unitario:
  - resolver role a partir de claims/perfil.
  - validar matriz de permissoes por rota.
  - bloquear `isActive=false`.
- Widget:
  - login por email/senha com sucesso/erro.
  - guard redirecionando usuario nao logado.
  - broker bloqueado em rota admin.
- Integracao/backend:
  - API bloqueia admin, broker, usuario inativo e publico conforme permissao.
  - Endpoint de criacao de usuario aplica profile e claims.
  - Endpoint de alteracao de role reflete nova permissao.

## Fase futura: SMS
Phone/SMS Auth fica preparado para depois.

Motivo:
- No Flutter Web, Phone Auth exige fluxo de SMS com reCAPTCHA.
- Ha custo, configuracao e testes especificos.
- Para a v1, email/senha atende admin e corretor com menor risco.

Quando entrar:
- habilitar Phone provider no Firebase Auth.
- configurar dominios autorizados.
- usar numeros de teste no Firebase Console.
- definir se SMS autentica admin/corretor ou apenas confirma contato de lead.

## Onde paramos
- A decisao de arquitetura evoluiu para Firebase Auth + backend Node + PostgreSQL + Custom Claims.
- O app web deve ser configurado via FlutterFire, nao pelo snippet JS do Firebase Console.
- Proximo passo de implementacao: criar `GET /api/v1/me` no backend e migrar `AuthRepository` para buscar perfil pela API em vez de Firestore.
