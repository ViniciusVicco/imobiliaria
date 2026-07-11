# Spec 3.0 - Admin Lifecycle e Gerenciamento de Corretores

## Contexto
Com a autenticacao propria via JWT e PostgreSQL funcionando, o proximo passo e dar vida ao ecossistema admin.

O admin precisa entrar em uma area simples, entender que esta autenticado e acessar uma funcionalidade lateral para gerenciar corretores. Nesta primeira entrega, o foco nao e um dashboard completo: e uma experiencia operacional minima para listar corretores e criar novos acessos.

Clientes publicos continuam sem autenticacao nesta fase.

## Escopo
Em escopo:
- Criar tela inicial basica de boas-vindas ao admin.
- Criar layout admin com navegacao lateral esquerda.
- Adicionar item lateral `Gerenciar corretores`.
- Criar tela de listagem de corretores.
- Mostrar nome, telefone e quantidade de imoveis sob responsabilidade do corretor.
- Criar botao `Criar novo corretor`.
- Criar formulario simples para nome, email e telefone.
- Criar corretor via API protegida.
- Confirmar e-mail do corretor duas vezes antes de criar.
- Gerar senha temporaria no backend.
- Enviar senha temporaria por e-mail via Gmail SMTP.
- Exibir estados de loading, sucesso, vazio e erro.

Fora de escopo:
- CRUD completo de imoveis.
- Dashboard administrativo completo.
- Relatorios avancados.
- Recuperacao automatica de senha.
- Edicao/desativacao de corretor, que pode entrar no proximo incremento.

## Rotas
Flutter:
- `/admin`: boas-vindas admin.
- `/admin/users`: gerenciar corretores.

Backend ja disponivel/planejado:
- `GET /api/v1/admin/users?role=broker`
- `POST /api/v1/admin/brokers`
- `GET /api/v1/admin/reports/brokers-property-summary`

## UX esperada
### Admin Home
- Mostrar titulo simples de boas-vindas.
- Indicar que o usuario esta na area administrativa.
- Usar layout com sidebar esquerda.
- Sidebar deve ter, no minimo:
  - `Gerenciar corretores`

### Gerenciar corretores
Listagem:
- Nome.
- Telefone.
- Email, se couber sem poluir.
- Quantidade de imoveis sob responsabilidade.
- Estado vazio: `Nenhum corretor cadastrado.`
- Botao principal: `Criar novo corretor`.

Criacao:
- Campos:
  - Nome.
  - Email.
  - Confirmar email.
  - Telefone.
- Senha inicial:
  - Backend gera senha temporaria segura.
  - Backend envia a senha por e-mail via Gmail SMTP.
  - UI nao exibe senha e nao permite senha manual.
- Ao criar com sucesso, voltar para a lista e atualizar os dados.

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra `try/catch`, mapeamento de erro e `Failure`? [ ]
- Datasource chama API HTTP via `RestClient`? [ ]
- Token JWT e enviado apenas por datasource/interceptor HTTP? [ ]
- Backend valida admin ativo antes de criar/listar corretores? [ ]

## Camadas Flutter afetadas
Presentation:
- Area admin em `lib/app/presentation/main/pages/admin/`.
- Controller/store para home admin e gerenciar corretores.
- Widgets simples para sidebar, tabela/lista e formulario.

Domain:
- Entidade de corretor administrativo.
- Use cases:
  - listar corretores.
  - criar corretor.
  - buscar resumo de imoveis por corretor.

Data:
- Datasource admin users.
- Repository admin users.
- Models para corretor e resumo de imoveis.
- Endpoints centralizados em `lib/app/data/api/`.

## Contratos de API
### Listar corretores
```txt
GET /api/v1/admin/users?role=broker
Authorization: Bearer <accessToken>
```

### Criar corretor
```txt
POST /api/v1/admin/brokers
Authorization: Bearer <accessToken>
```

Body v1:
```json
{
  "name": "Nome do Corretor",
  "email": "corretor@email.com",
  "emailConfirmation": "corretor@email.com",
  "phone": "(63) 99999-9999",
}
```

Regras:
- Backend fixa `role=broker`.
- Backend valida se `email` e `emailConfirmation` sao iguais.
- Backend normaliza e-mail para lowercase.
- Backend valida e-mail unico.
- Se e-mail ja existe, retornar exatamente: `Esse e-mail já se encontra na nossa base de dados`.
- Backend gera senha temporaria, salva hash e envia senha por Gmail SMTP.
- API nunca retorna senha temporaria.

### Resumo de imoveis por corretor
```txt
GET /api/v1/admin/reports/brokers-property-summary
Authorization: Bearer <accessToken>
```

Resposta esperada:
```json
{
  "items": [
    {
      "brokerId": "broker_id",
      "brokerName": "Nome",
      "brokerEmail": "broker@email.com",
      "totalProperties": 0,
      "draftProperties": 0,
      "publishedProperties": 0,
      "soldProperties": 0,
      "inactiveProperties": 0
    }
  ]
}
```

## Email e credenciais do corretor
Decisao vigente:
- Usar Gmail SMTP.
- `GMAIL_SMTP_SECRET` guarda a app password do Gmail.
- `GMAIL_SMTP_USER` define o e-mail remetente.
- `GMAIL_SMTP_FROM` define o nome de exibicao do remetente.
- Se o envio falhar, a API nao deve criar o corretor.
- A senha temporaria nunca deve ir para logs ou resposta HTTP.

Variaveis:
```txt
GMAIL_SMTP_SECRET=
GMAIL_SMTP_USER="seu-email@gmail.com"
GMAIL_SMTP_FROM="Seletta"
```

## Requisitos funcionais
1. Admin autenticado acessa `/admin` e ve tela de boas-vindas.
2. Admin ve sidebar esquerda com `Gerenciar corretores`.
3. Admin clica em `Gerenciar corretores` e acessa listagem.
4. A listagem mostra nome, telefone e quantidade de imoveis de cada corretor.
5. Corretor sem imoveis aparece com quantidade `0`.
6. Admin clica em `Criar novo corretor` e abre formulario.
7. Admin informa nome, email, confirmacao de email e telefone.
8. Ao salvar, a API cria usuario com `role=broker`.
9. A API envia senha temporaria por email via Gmail SMTP.
10. A lista atualiza apos criacao.
11. Broker nao acessa tela ou API de gerenciamento de corretores.

## Requisitos nao funcionais
1. Layout responsivo sem overflow em mobile/desktop.
2. UI administrativa deve ser simples, densa e operacional.
3. Erros devem ser exibidos de forma clara.
4. Backend continua sendo a fonte real de autorizacao.
5. Nenhum dado sensivel de senha deve ser exibido na UI, logs ou resposta HTTP.

## Criterios de aceite
1. Dado admin logado, quando abre `/admin`, entao ve boas-vindas e sidebar.
2. Dado admin logado, quando clica em `Gerenciar corretores`, entao ve lista de corretores.
3. Dado nao existem corretores, quando lista carrega, entao aparece estado vazio.
4. Dado corretor sem imoveis, quando lista carrega, entao total de imoveis e `0`.
5. Dado admin preenche formulario valido, quando salva, entao corretor e criado e recebe e-mail.
6. Dado email ja cadastrado, quando salva, entao erro e exibido.
7. Dado emails divergentes, quando salva, entao erro e exibido.
8. Dado usuario broker tenta acessar `/admin/users`, quando guard/API validam, entao acesso e bloqueado.
9. Dado backend falha, quando lista ou criacao terminam, entao estado de erro e exibido.

## Testes obrigatorios
### Backend
- Admin lista apenas usuarios `broker`.
- Admin cria corretor.
- Admin cria corretor via `/admin/brokers` sem enviar role.
- Broker nao cria/lista corretores.
- Email duplicado retorna erro controlado.
- Emails divergentes retornam erro controlado.
- Falha no Gmail SMTP impede criacao do corretor.
- Relatorio retorna `0` para corretor sem imoveis.

### Flutter Unit
- Use case de listagem retorna corretores e resumo.
- Repository mapeia erro da API para `Failure`.
- Criacao envia `role=broker` sempre, sem depender de input livre do usuario.

### Flutter Widget
- Admin home renderiza sidebar.
- Lista renderiza vazio, sucesso e erro.
- Formulario valida nome, email, confirmacao de email e telefone.
- Formulario valida confirmacao de e-mail.
- Criacao com sucesso volta/atualiza a lista.

## Ordem recomendada de entrega
1. Criar/ajustar endpoints/data layer para admin users no Flutter.
2. Criar layout admin com sidebar.
3. Criar tela de boas-vindas.
4. Criar tela `Gerenciar corretores`.
5. Integrar listagem com `GET /admin/users?role=broker`.
6. Integrar resumo com `/admin/reports/brokers-property-summary`.
7. Criar formulario de novo corretor.
8. Integrar `POST /admin/brokers`.
9. Adicionar estados de loading, vazio e erro.
10. Adicionar testes focados.

## Definition of Done
- Admin consegue acessar area administrativa viva.
- Sidebar possui `Gerenciar corretores`.
- Admin lista corretores com quantidade de imoveis.
- Admin cria novo corretor com dados basicos.
- Corretor recebe senha temporaria por e-mail via Gmail SMTP.
- Broker nao acessa fluxo admin.
