# Spec 2 - Capacidades de Admin e Broker

## Contexto
Esta spec resume, de forma operacional, o que cada perfil autenticado pode fazer hoje na plataforma Seletta.

A fonte de verdade de permissao continua sendo o backend Node/PostgreSQL:
- JWT Bearer identifica a sessao.
- `users.role` e `users.is_active` no PostgreSQL definem acesso.
- Guards no Flutter melhoram UX, mas nao substituem a autorizacao no backend.

## Escopo
Em escopo:
- Listar capacidades de `admin` e `broker`.
- Mapear rotas Flutter principais.
- Mapear endpoints de API.
- Mapear use cases Flutter existentes ou esperados.

Fora de escopo:
- Detalhar layout visual de cada tela.
- Definir auditoria completa.
- Definir leads, pagamentos ou CRM.
- Definir CRUD de localidades.

## Regras gerais
1. Usuario inativo nao acessa rotas protegidas.
2. Publico acessa `/home`, `/search` e detalhes publicados sem login.
3. Broker acessa apenas recursos vinculados ao proprio usuario.
4. Admin acessa recursos globais e pode operar como gestor.
5. Backend sempre valida permissao de novo em cada endpoint protegido.

## Broker
### O que pode fazer
- Fazer login por email e senha.
- Acessar area do corretor.
- Listar os proprios imoveis.
- Criar imovel proprio em fluxo nao publico.
- Editar imovel proprio.
- Enviar imovel para confirmacao do admin.
- Alterar status de imovel proprio conforme regras permitidas.
- Fazer upload de imagens para imovel proprio.
- Definir capa usando midia ativa do proprio imovel.
- Marcar midia propria como `pending_delete`.
- Restaurar midia propria dentro da janela permitida.
- Sinalizar imovel como vendido e disparar e-mail para todos os admins.
- Inativar/remover imovel da visualizacao publica.

Regra de publicacao:
- Nao existe mais fluxo de publicar imovel como `draft`.
- Broker cria o imovel e envia para confirmacao.
- O imovel nao fica publico ate que um admin confirme.
- O antigo "draft" deve ser tratado como nome tecnico legado para criar um imovel ainda nao publico, nao como estado de publicacao do produto.

### O que nao pode fazer
- Acessar `/admin/*`.
- Listar, criar ou editar usuarios.
- Ver imoveis de outros corretores em endpoints protegidos.
- Alterar `brokerId` de imovel.
- Tornar imovel publico sem confirmacao admin.
- Usar credenciais R2 ou enviar arquivo direto ao storage.

### Rotas Flutter
```txt
/login
/broker
/broker/properties
/broker/properties/new
/broker/properties/:id/edit
```

### Endpoints
```txt
POST /api/v1/auth/login
GET /api/v1/me
POST /api/v1/auth/logout

GET /api/v1/broker/properties
POST /api/v1/broker/properties
POST /api/v1/broker/properties/draft
GET /api/v1/broker/properties/:id
PATCH /api/v1/broker/properties/:id
PATCH /api/v1/broker/properties/:id/status

POST /api/v1/media/properties/:propertyId/images
GET /api/v1/media/:mediaId/file
PATCH /api/v1/media/:mediaId/cover
PATCH /api/v1/media/:mediaId/pending-delete
PATCH /api/v1/media/:mediaId/restore
```

### Use cases Flutter
```txt
LoginWithEmailUseCase
GetCurrentUserSessionUseCase
WatchCurrentUserSessionUseCase
LogoutUseCase
ResolveProtectedRouteAccessUseCase

GetBrokerPropertiesUseCase
GetBrokerPropertyUseCase
CreateBrokerPropertyDraftUseCase
SaveBrokerPropertyUseCase
UpdateBrokerPropertyStatusUseCase

UploadPropertyImageUseCase
UploadTemporaryPropertyImageUseCase
GetPropertyMediaFileUseCase
SetPropertyCoverUseCase
DeletePropertyMediaUseCase
RestorePropertyMediaUseCase
```

## Admin
### O que pode fazer
- Fazer login por email e senha.
- Acessar area administrativa.
- Listar corretores.
- Criar corretor.
- Consultar resumo de imoveis por corretor.
- Listar todos os imoveis.
- Criar imovel administrativo em fluxo nao publico quando necessario.
- Criar imovel do zero.
- Editar qualquer imovel.
- Atribuir ou alterar corretor responsavel quando o corretor estiver ativo.
- Alterar status de qualquer imovel.
- Confirmar publicacao de imovel enviado por broker.
- Publicar imovel diretamente quando criado ou editado por admin.
- Inativar ou marcar qualquer imovel como vendido.
- Fazer upload de imagens para qualquer imovel.
- Definir capa de qualquer imovel.
- Marcar/restaurar midia de qualquer imovel.
- Executar limpeza manual de midias pendentes quando endpoint admin estiver habilitado.

### O que nao pode fazer
- Desativar a propria conta.
- Rebaixar ou desativar o ultimo admin ativo.
- Atribuir imovel a corretor inexistente ou inativo.
- Retornar senha, hash ou credenciais sensiveis para o Flutter.
- Expor dados administrativos em rotas publicas.

### Rotas Flutter
```txt
/login
/admin
/admin/users
/admin/properties
/admin/properties/new
/admin/properties/:id/edit
```

### Endpoints
```txt
POST /api/v1/auth/login
GET /api/v1/me
POST /api/v1/auth/logout

GET /api/v1/admin/users
POST /api/v1/admin/users
GET /api/v1/admin/users/:id
PATCH /api/v1/admin/users/:id
PATCH /api/v1/admin/users/:id/password

POST /api/v1/admin/brokers
GET /api/v1/admin/reports/brokers-property-summary

GET /api/v1/admin/properties
POST /api/v1/admin/properties
POST /api/v1/admin/properties/draft
GET /api/v1/admin/properties/:id
PATCH /api/v1/admin/properties/:id
PATCH /api/v1/admin/properties/:id/status

POST /api/v1/media/properties/:propertyId/images
GET /api/v1/media/:mediaId/file
PATCH /api/v1/media/:mediaId/cover
PATCH /api/v1/media/:mediaId/pending-delete
PATCH /api/v1/media/:mediaId/restore
POST /api/v1/media/cleanup/pending-delete
```

### Use cases Flutter
```txt
LoginWithEmailUseCase
GetCurrentUserSessionUseCase
WatchCurrentUserSessionUseCase
LogoutUseCase
ResolveProtectedRouteAccessUseCase

GetAdminBrokersUseCase
CreateAdminBrokerUseCase

GetAdminPropertiesUseCase
GetAdminPropertyUseCase
CreateAdminPropertyUseCase
CreateAdminPropertyDraftUseCase
SaveAdminPropertyUseCase
UpdateAdminPropertyStatusUseCase

UploadPropertyImageUseCase
UploadTemporaryPropertyImageUseCase
GetPropertyMediaFileUseCase
SetPropertyCoverUseCase
DeletePropertyMediaUseCase
RestorePropertyMediaUseCase
```

## Matriz resumida
| Capacidade | Broker | Admin |
| --- | --- | --- |
| Acessar Home/Search publico | Sim | Sim |
| Login protegido | Sim | Sim |
| Acessar `/broker` | Sim | Sim, se rota permitir capacidade equivalente |
| Acessar `/admin` | Nao | Sim |
| Listar proprios imoveis | Sim | Sim |
| Listar todos os imoveis | Nao | Sim |
| Criar imovel proprio | Sim, nao publico ate confirmacao | Sim |
| Criar imovel para outro corretor | Nao | Sim |
| Editar imovel proprio | Sim | Sim |
| Editar imovel de outro corretor | Nao | Sim |
| Alterar `brokerId` | Nao | Sim, apenas para corretor ativo |
| Upload de midia | Apenas em imovel proprio | Qualquer imovel |
| Gerenciar usuarios | Nao | Sim |
| Criar corretor | Nao | Sim |
| Confirmar publicacao | Nao | Sim |
| Sinalizar venda | Sim, com e-mail aos admins | Sim |
| Ver relatorio de corretores | Nao | Sim |
| Executar cleanup de midia | Nao | Sim |

## Pontos de decisao
1. Criacao de corretor deve usar somente `POST /api/v1/admin/brokers` ou tambem manter `POST /api/v1/admin/users` com `role=broker`?
2. Senha inicial do corretor deve ser sempre gerada e enviada por email, ou admin pode informar senha manual?
3. Admin deve poder acessar telas `/broker/*` como operador equivalente ou deve usar apenas telas `/admin/*`?
4. Qual status interno representa "criado pelo broker, mas ainda nao publico": `pending_review`, outro enum, ou manter o nome atual apenas no backend?
5. O e-mail de venda para admins deve usar o mesmo Gmail SMTP do fluxo de criacao de corretor?

## Observacao sobre nomes tecnicos legados
Os nomes `draft` em endpoints e use cases ainda podem existir no codigo como mecanismo tecnico de criacao antecipada de `propertyId`, principalmente para associar midias.

No produto, a regra vigente e:
- Broker nao publica diretamente para o publico.
- Broker cria/envia o imovel, mas ele fica nao publico ate confirmacao admin.
- Nao existe mais "publicar em draft" como acao de negocio.

## Definition of Done
- Rotas protegidas usam guard no Flutter.
- Endpoints protegidos validam JWT, usuario ativo e role no backend.
- Use cases preservam o fluxo `widget -> controller -> useCase -> repository -> datasource`.
- Broker nao acessa dados de outros corretores.
- Admin consegue operar gestao global sem expor dados sensiveis ao publico.
