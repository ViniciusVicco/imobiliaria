# Spec 1 - Painel Amigavel do Corretor

## Status
- Painel `/broker`, tabs de imoveis/perfil, perfil via `/me/*` e upload de avatar ja estao implementados no Flutter/backend.
- Pendente: notificacao de venda por e-mail para admins ativos e cobertura de testes.

## Contexto
O corretor precisa de uma experiencia mais direta apos o login, focada nas duas acoes que ele mais usa:
- gerenciar os proprios imoveis;
- manter o proprio perfil profissional atualizado.

A rota principal do corretor passa a ser `/broker`. Ela deve abrir direto apos login bem-sucedido de usuario `broker`, sem menu lateral, com tabs superiores:
- `Meus imoveis`;
- `Meu perfil`.

## Escopo
Em escopo:
- Criar uma tela principal amigavel para o corretor em `/broker`.
- Consolidar a lista de imoveis dentro da tab `Meus imoveis`.
- Criar tab `Meu perfil` com avatar, dados profissionais, contatos e troca de senha.
- Permitir upload de avatar pelo backend/R2.
- Permitir edicao dos dados do proprio perfil.
- Permitir troca de senha com senha atual, nova senha e confirmacao.
- Manter arquitetura Flutter `Widget -> Controller -> UseCase -> Repository -> Datasource`.

Fora de escopo:
- Painel admin.
- CRUD completo de usuarios admin.
- Recuperacao de senha por email.
- Edicao de email pelo corretor.
- Avatar de admin.
- Menu lateral no painel do corretor.

## Decisoes fechadas
- A experiencia principal do corretor fica em `/broker`.
- A tela nao usa sidebar/menu lateral.
- `/broker/properties` pode continuar como compatibilidade, mas deve redirecionar ou reutilizar a experiencia de `/broker`.
- O destino padrao apos login de broker e `/broker`.
- E-mail aparece no perfil como somente leitura na v1.
- `phone` existente no banco representa celular.
- WhatsApp e celular sao campos separados.
- `creci` e opcional.
- `about` e editavel no perfil e representa a apresentacao profissional do corretor.
- Avatar usa upload real via backend/R2.
- Avatar atualiza imediatamente apos upload bem-sucedido, sem depender de `Salvar alteracoes`.
- `Salvar alteracoes` so habilita quando algum campo de texto editavel mudar.
- Alteracao de senha exige senha atual, nova senha e confirmacao.
- `draft` nao aparece como aba de produto no painel do corretor.
- Imoveis criados pelo broker nao ficam publicos ate confirmacao/admin.
- Ao sinalizar venda, backend deve enviar e-mail para todos os admins ativos.

## UX esperada
### Estrutura geral
Rota:
```txt
/broker
```

Topo:
- Titulo: `Painel do Corretor`.
- Subtitulo curto explicando que o corretor gerencia portfolio e perfil.
- Botao destacado: `Cadastrar novo imovel`.

Tabs principais:
```txt
Meus imoveis | Meu perfil
```

Regras:
- O botao `Cadastrar novo imovel` deve estar visivel na tab `Meus imoveis`.
- Em mobile, o topo deve empilhar sem overflow.
- Em desktop, cards e formulario devem usar layout amplo e denso.

### Tab Meus imoveis
Filtros internos:
```txt
Todos | Publicados | Pendentes | Venda Sinalizada
```

Mapeamento de status:
- `Todos`: todos os imoveis do corretor, exceto `inactive`.
- `Publicados`: `published`.
- `Pendentes`: `pending_review`.
- `Venda Sinalizada`: `sold`.

Comportamento:
- Ao abrir `/broker`, carregar `Todos`.
- Trocar filtro chama o controller, que chama use case, repository e datasource.
- Card deve mostrar capa, status, titulo, localizacao, area e valor.
- Card deve permitir editar.
- Card deve permitir sinalizar venda quando ainda nao estiver `sold`.
- Sinalizar venda pede confirmacao antes de alterar status.
- Ao confirmar venda, atualizar status para `sold` e enviar e-mail para todos os admins ativos.

Estados:
- Loading.
- Sucesso com cards.
- Vazio com mensagem clara.
- Erro com acao `Tentar novamente`.

### Tab Meu perfil
Conteudo:
- Avatar/foto profissional.
- Nome completo.
- WhatsApp.
- Celular.
- E-mail somente leitura.
- CRECI opcional.
- Acao `Alterar senha`.
- Botoes `Cancelar` e `Salvar alteracoes`.

Avatar:
- Upload deve abrir seletor de imagem.
- Upload chama endpoint proprio de avatar.
- Ao terminar com sucesso, a imagem em tela atualiza imediatamente.
- Erro de upload deve ser exibido sem perder alteracoes pendentes dos campos.

Formulario:
- Campos editaveis: nome completo, WhatsApp, celular e CRECI.
- Campo nao editavel: e-mail.
- `Salvar alteracoes` inicia desabilitado.
- `Salvar alteracoes` habilita quando algum campo editavel difere do valor original.
- `Cancelar` restaura os valores originais.
- Ao salvar com sucesso, os valores atuais viram a nova referencia original.

Alteracao de senha:
- Pode abrir dialog/modal simples ou secao dedicada.
- Campos:
  - senha atual;
  - nova senha;
  - confirmar nova senha.
- Nova senha e confirmacao devem ser iguais.
- Backend valida senha atual.
- Erro nao deve limpar os demais dados do perfil.

## Rotas Flutter
```txt
/broker
/broker/properties
/broker/properties/new
/broker/properties/:id/edit
```

Regras:
- `/broker` renderiza `BrokerDashboardPage`.
- `/broker/properties` deve redirecionar para `/broker` ou renderizar a mesma tela por compatibilidade.
- `/broker/properties/new` continua abrindo criacao de imovel.
- `/broker/properties/:id/edit` continua abrindo edicao de imovel.

## Endpoints
### Imoveis do corretor
Existentes:
```txt
GET /api/v1/broker/properties
GET /api/v1/broker/properties?status=published
GET /api/v1/broker/properties?status=pending_review
GET /api/v1/broker/properties?status=sold
PATCH /api/v1/broker/properties/:id/status
```

Atualizacao necessaria:
- `GET /broker/properties` sem `status` deve retornar todos os imoveis do corretor, exceto `inactive`.
- `PATCH /broker/properties/:id/status` com `status=sold` deve enviar e-mail para todos os admins ativos.

### Meu perfil
Novos endpoints:
```txt
PATCH /api/v1/me/profile
PATCH /api/v1/me/password
POST /api/v1/me/avatar
```

#### `PATCH /api/v1/me/profile`
Autenticado.

Body:
```json
{
  "name": "Nome completo",
  "phone": "(63) 99999-0000",
  "whatsapp": "(63) 99999-1111",
  "creci": "TO-00000"
}
```

Regras:
- Atualiza apenas o proprio usuario autenticado.
- Nao aceita `email`, `role`, `isActive`, `passwordHash`, `createdBy` ou `updatedBy` vindos do Flutter.
- `creci` pode ser vazio/nulo.
- Retorna o perfil atualizado.

Resposta:
```json
{
  "id": "user_id",
  "email": "corretor@seletta.local",
  "name": "Nome completo",
  "phone": "(63) 99999-0000",
  "whatsapp": "(63) 99999-1111",
  "creci": "TO-00000",
  "avatarUrl": "https://cdn.seletta.../avatars/user_id/avatar.webp",
  "role": "broker",
  "isActive": true
}
```

#### `PATCH /api/v1/me/password`
Autenticado.

Body:
```json
{
  "currentPassword": "senha-atual",
  "newPassword": "nova-senha",
  "newPasswordConfirmation": "nova-senha"
}
```

Regras:
- Validar senha atual contra `users.password_hash`.
- Validar nova senha com minimo de 8 caracteres.
- Validar confirmacao igual a nova senha.
- Salvar somente hash.
- Nunca retornar senha ou hash.

Resposta atual (perfil atualizado, sem senha/hash):
```json
{
  "id": "user_id",
  "name": "Nome completo",
  "email": "corretor@seletta.local",
  "phone": "(63) 99999-0000",
  "whatsapp": "(63) 99999-1111",
  "creci": "TO-00000",
  "avatarUrl": "https://cdn.seletta.../avatars/user_id/avatar.webp",
  "role": "broker",
  "isActive": true
}
```

#### `POST /api/v1/me/avatar`
Autenticado.

Body:
```json
{
  "fileName": "avatar.webp",
  "mimeType": "image/webp",
  "contentBase64": "base64..."
}
```

Regras:
- Reaproveitar configuracao R2 do backend.
- Aceitar apenas MIME types de imagem permitidos.
- Validar tamanho maximo.
- Gerar storage key em `media/users/{userId}/avatar/...`.
- Atualizar `users.avatar_url`.
- Retornar perfil atualizado ou ao menos `avatarUrl`.

Resposta minima:
```json
{
  "avatarUrl": "https://cdn.seletta.../media/users/user_id/avatar.webp"
}
```

## Modelo de dados
Atualizar `users`:
```txt
phone        String?  // celular
whatsapp     String?
creci        String?
avatar_url   String?
```

Observacoes:
- `email` continua unico e somente leitura para o corretor.
- `role` e `is_active` continuam controlados por admin/backend.
- O CTA publico de WhatsApp deve preferir `users.whatsapp`; se vazio, usar `users.phone`; se ambos vazios, usar fallback institucional.

## Camadas Flutter
### Presentation
- Criar `BrokerDashboardPage`.
- Criar `BrokerDashboardController`.
- Criar `BrokerDashboardStore`.
- Reaproveitar cards existentes de gerenciamento de imoveis quando fizer sentido.
- Criar componentes locais para:
  - tabs principais;
  - tabs de status;
  - painel de avatar;
  - formulario de perfil;
  - dialog de senha.

### Domain
Novas entities/use cases:
```txt
BrokerProfileEntity
BrokerProfileFormEntity
UpdateBrokerProfileUseCase
UpdateBrokerPasswordUseCase
UploadBrokerAvatarUseCase
```

Reaproveitar:
```txt
GetBrokerPropertiesUseCase
UpdateBrokerPropertyStatusUseCase
GetCurrentUserSessionUseCase
```

### Data
Criar ou evoluir datasource/repository de perfil:
```txt
BrokerProfileDatasource
BrokerProfileRepository
BrokerProfileEndpoints
BrokerProfileModel
```

Endpoints centralizados:
```txt
/me/profile
/me/password
/me/avatar
```

## Backend
Adicionar campos no Prisma e migration.

Atualizar respostas de usuario:
- `/auth/login`;
- `/me`;
- endpoints admin que listam usuarios, se fizer sentido exibir avatar/CRECI futuramente.

Adicionar rotas autenticadas:
- `PATCH /me/profile`;
- `PATCH /me/password`;
- `POST /me/avatar`.

Atualizar rota de status de imovel:
- Quando broker alterar status para `sold`, enviar e-mail para admins ativos.
- Usar o mesmo provedor SMTP definido para notificacoes administrativas, salvo decisao futura em contrario.
- Se envio de e-mail falhar, a operacao de venda deve retornar erro e nao confirmar status como `sold`.

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra `try/catch`, mapeamento de erro e `Failure`? [ ]
- Datasource chama API HTTP via `RestClient`? [ ]
- Backend valida JWT, usuario ativo e propriedade do recurso? [ ]
- Flutter nao envia nem decide `role` ou `isActive`? [ ]

## Criterios de aceite
1. Dado broker logado, quando login conclui, entao app abre `/broker`.
2. Dado broker abre `/broker`, entao ve tabs `Meus imoveis` e `Meu perfil`.
3. Dado broker abre `Meus imoveis`, entao a lista carrega todos os imoveis proprios nao inativos.
4. Dado broker clica `Publicados`, entao a lista filtra `published`.
5. Dado broker clica `Pendentes`, entao a lista filtra `pending_review`.
6. Dado broker clica `Venda Sinalizada`, entao a lista filtra `sold`.
7. Dado broker clica `Cadastrar novo imovel`, entao navega para `/broker/properties/new`.
8. Dado broker sinaliza venda, quando confirma, entao status vira `sold` e todos os admins ativos recebem e-mail.
9. Dado broker abre `Meu perfil`, entao ve avatar, nome, WhatsApp, celular, email e CRECI.
10. Dado nenhum campo editavel mudou, entao `Salvar alteracoes` fica desabilitado.
11. Dado campo editavel mudou, entao `Salvar alteracoes` fica habilitado.
12. Dado broker clica `Cancelar`, entao o formulario volta aos valores originais.
13. Dado broker faz upload de avatar valido, entao avatar atualiza na tela imediatamente.
14. Dado broker altera senha com senha atual correta, entao backend salva novo hash e retorna sucesso.
15. Dado senha atual incorreta, entao backend retorna erro controlado.

## Testes obrigatorios
### Backend
- Broker atualiza proprio perfil.
- Broker nao altera `role`, `isActive` ou email por `/me/profile`.
- `/me/profile` bloqueia usuario inativo.
- `/me/password` rejeita senha atual incorreta.
- `/me/password` rejeita confirmacao divergente.
- `/me/avatar` rejeita MIME invalido.
- `/me/avatar` atualiza `avatarUrl`.
- `PATCH /broker/properties/:id/status` para `sold` envia e-mail aos admins ativos.
- Se e-mail de venda falhar, status nao deve ser confirmado como `sold`.

### Flutter
- Login broker redireciona para `/broker`.
- `/broker` renderiza tabs principais.
- Tabs de status chamam busca com filtros esperados.
- Botao `Cadastrar novo imovel` navega corretamente.
- Formulario de perfil habilita/desabilita salvar por dirty state.
- Cancelar restaura valores originais.
- Upload de avatar atualiza preview imediatamente.
- Dialog de senha valida confirmacao.
- Erros de perfil, senha e avatar aparecem sem travar a tela.

## Ordem recomendada de entrega
1. Criar migration de `users.whatsapp`, `users.creci` e `users.avatar_url`.
2. Implementar endpoints `/me/profile`, `/me/password` e `/me/avatar`.
3. Atualizar respostas de auth/session para incluir novos campos.
4. Atualizar status `sold` para enviar e-mail aos admins.
5. Criar data/domain de perfil no Flutter.
6. Criar `BrokerDashboardPage`, controller e store.
7. Reaproveitar grid/cards de imoveis dentro da tab `Meus imoveis`.
8. Criar tab `Meu perfil` com avatar, formulario e senha.
9. Ajustar login broker para navegar para `/broker`.
10. Adicionar testes focados.

## Definition of Done
- Corretor cai em `/broker` apos login.
- `/broker` e a tela principal unica do corretor.
- Imoveis e perfil ficam em tabs superiores.
- Botao de novo imovel fica claro e acessivel.
- Perfil salva apenas campos editaveis alterados.
- Avatar faz upload real via backend/R2 e atualiza imediatamente.
- Troca de senha exige senha atual.
- Venda sinalizada notifica admins por e-mail.
