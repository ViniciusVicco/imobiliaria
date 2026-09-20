# Spec 2 ? Formul?rio centralizado de propriedades

## Status

Revisada em 2026-09-19 contra o c?digo local. Formul?rio dedicado, cria??o, edi??o, valida??o, m?dia e revis?o administrativa implementados no c?digo. Valida??o operacional com R2/SMTP e testes completos ainda pendentes.

Substitui o modal como fluxo principal do [CRUD hist?rico](../_archive/Properties/01-broker-admin-properties-crud.md) e usa o ciclo descrito na [spec de m?dia](../media/01-r2-media-upload.md). O formul?rio e seus componentes ainda ficam em `lib/app/presentation/main/pages/broker/`; sua extra??o ? a etapa 5 da [refatora??o](../presentation/01-presentation-refactoring.md).

## Fluxo existente

### Cria??o

1. `/broker/properties/new` ou `/admin/properties/new` abre `PropertyFormPage` no modo correspondente.
2. `PropertyFormController.startNewProperty` inicializa uma entidade local com ID vazio; n?o faz POST de draft ao abrir a p?gina.
3. A p?gina gera `uploadSessionId`. As imagens usam `POST /api/v1/media/property-images/temp` antes da cria??o do im?vel.
4. O formul?rio re?ne dados, `mediaIds`, `coverMediaId` e `uploadSessionId`. O broker n?o pode atribuir outro corretor; o admin possui sele??o de corretor.
5. Com ID vazio, `SaveBrokerPropertyUseCase`/`SaveAdminPropertyUseCase` executa cria??o via POST. O backend associa/promove as m?dias tempor?rias.
6. A cria??o pelo broker resulta em `pending_review`; pelo admin, em `published`.

Os endpoints `/broker/properties/draft` e `/admin/properties/draft`, use cases de draft e p?ginas antigas de cria??o continuam no reposit?rio, mas n?o s?o a entrada das rotas `new` registradas no `MainModule`. N?o recriar redirecionamento obrigat?rio para `:id/edit` com base no fluxo antigo.

### Edi??o e revis?o

- `/broker/properties/:id/edit` e `/admin/properties/:id/edit` carregam o im?vel pelo endpoint do perfil.
- Com ID existente, salvar usa PATCH; m?dia usa os endpoints por im?vel e por ID de m?dia.
- Edi??o por broker de im?vel publicado cria `PropertyRevision`; a vers?o publicada permanece at? a revis?o administrativa.
- Finaliza??o de existente chama atualiza??o de status: `pending_review` para broker, `published` para admin.
- Admin disp?e de lista de revis?o, consulta de revis?es, aprova??o e rejei??o; notifica??es possuem listagem, marca??o de leitura e retry de e-mail no backend.

**Diverg?ncia aberta:** a regra de produto exige confirma??o admin para publica??o por broker. O handler de `PATCH /broker/properties/:id/status` aceita `published` no schema e atualiza o status ap?s valida??o do im?vel. ? necess?rio restringir essa transi??o e test?-la; a regra n?o deve ser declarada plenamente garantida pelo backend atual.

## Interface e dados

A mesma `PropertyFormPage` atende `PropertyFormMode.broker` e `PropertyFormMode.admin`. O admin usa `AdminLayout`, localizado em `main/pages/widgets/admin/`.

Se??es existentes:

- Identifica??o: t?tulo, descri??o, segmento e tipo.
- Localiza??o: cidade, bairro e sub-bairro/quadra; cidade inicial `Palmas`.
- Caracter?sticas: ?reas, quartos, banheiros, vagas e idade.
- Pre?o, status, tags, destaque e desenvolvimento novo.
- Sele??o de corretor no modo admin.
- Fotos, capa, remo??o/restaura??o de m?dia e v?deo por URL YouTube.
- Pr?via do an?ncio e mensagens de valida??o.

Componentes ainda locais incluem campos, sliders, pr?via, se??o de m?dia e banners. A refatora??o futura deve preservar os valores editados, callbacks, chaves de estado, foco e m?dia selecionada. O `PropertyFormDialog` legado continua no arquivo compartilhado `main/pages/widgets/property/property_management_widgets.dart`.

## Contratos e fontes

Base HTTP: `/api/v1`.

| Opera??o | Endpoints existentes |
| --- | --- |
| Criar | `POST /broker/properties`, `POST /admin/properties` |
| Ler/editar | `GET` e `PATCH /broker/properties/:id` e `/admin/properties/:id` |
| Status | `PATCH /broker/properties/:id/status`, `PATCH /admin/properties/:id/status` |
| Revisar | `GET /admin/properties/review`, `GET /admin/properties/:id/revisions` |
| Aprovar/rejeitar | `POST /admin/properties/:id/approve`, `POST /admin/properties/:id/reject` |
| Upload tempor?rio | `POST /media/property-images/temp` |
| Upload em im?vel existente | `POST /media/properties/:propertyId/images` |
| M?dia | `GET /media/:mediaId/file`; `PATCH /media/:mediaId/cover`, `/pending-delete`, `/restore` |

Fontes de implementa??o:

- `PropertyFormPage`, `PropertyFormController`, `PropertyFormStore` e `PropertyFormValidator` em `main/pages/broker/`.
- `SaveBrokerPropertyUseCase` e `SaveAdminPropertyUseCase` em `domain/broker/usecases/`.
- `backend/src/modules/properties/protected-properties.routes.ts` e `backend/src/modules/media/media.routes.ts`.

Fluxo de dados: p?gina -> controller -> use case -> repository -> datasource. Permiss?es e associa??o de m?dia devem ser conferidas no backend; valida??o visual n?o as substitui.

## Crit?rios de aceite e valida??o pendente

- Criar por ambos os perfis sem exigir draft persistido ao abrir a p?gina.
- Upload tempor?rio, sele??o de capa, promo??o e rollback em falhas de armazenamento.
- Edi??o pr?pria pelo broker e global pelo admin, com corretor ativo quando atribu?do.
- Broker n?o publica diretamente nem acessa im?vel/m?dia de outro usu?rio; testar a corre??o da diverg?ncia de status.
- Revis?o de im?vel publicado, aprova??o/rejei??o e observa??es preservam a vers?o correta.
- Busca p?blica retorna apenas `published`.
- Remo??o/restaura??o de imagens respeita ciclo de vida e autoriza??o.
- Layout mobile/desktop, teclado aberto, texto ampliado e estado ap?s rebuild.

H? testes Flutter execut?veis no projeto, mas os 15 testes atuais cobrem busca e formul?rio de login, n?o este formul?rio. Usar `flutter analyze`, `flutter test` e compila??o web nas pr?ximas altera??es; a restri??o antiga de toolchain inst?vel foi removida.

Valida??o manual com R2 e SMTP reais permanece pendente. N?o foram executadas migrations nem valida??es de servi?os externos nesta revis?o documental.

Fora deste escopo: upload de v?deo, CRUD de localidades, mapas e workflow independente de solicita??o de destaque. Salvamento incremental por draft ? mecanismo legado e n?o deve ser apresentado como requisito j? atendido pelo fluxo `new` atual.
