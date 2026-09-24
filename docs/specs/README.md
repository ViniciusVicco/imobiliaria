# Specs Seletta

## Como ler

Revis?o documental: **2026-09-19**, baseada no c?digo local, incluindo as etapas 1 e 2 da refatora??o ainda n?o commitadas. O [ai_contract.md](../../ai_contract.md) ? o contrato obrigat?rio de organiza??o de c?digo. A [arquitetura](../ARCHITECTURE_SPEC_DRIVEN.md) descreve a estrutura atual.

- **Implementado no c?digo** n?o significa validado em produ??o ou com servi?os externos.
- Crit?rios de aceite e planos de testes s?o requisitos; s? os resultados explicitamente registrados s?o evid?ncias de execu??o.
- A numera??o ? local por dom?nio. `properties/02` mant?m seu n?mero para preservar refer?ncias; a vers?o anterior est? no arquivo hist?rico.
- `_archive/` guarda decis?es anteriores e n?o deve orientar novas implementa??es.

## Specs vigentes

| Dom?nio | Spec | Estado observado |
| --- | --- | --- |
| Apresenta??o | [1 ? Refatora??o da apresenta??o](presentation/01-presentation-refactoring.md) | Etapas 1 e 2 conclu?das; 3 a 6 pendentes. |
| Home | [1 ? Showcase, busca e marca](home/01-home-showcase-brand-search.md) | Se??es e integra??o HTTP implementadas; valida??o integrada pendente. |
| Estoque | [1 ? Cat?logo p?blico](stock/01-public-property-inventory.md) | `/estoque`, alias `/search`, filtros e pagina??o implementados; testes unit?rios/widgets existentes. |
| Backend | [1 ? Plataforma Node/PostgreSQL](backend/01-node-postgres-platform.md) | Rotas e persist?ncia implementadas; exemplos iniciais n?o substituem schemas atuais. |
| Autentica??o | [2 ? JWT e gest?o de usu?rios](backend/02-auth-jwt-postgres-admin-brokers.md) | Login, sess?o, perfil e guards implementados; formul?rio de login extra?do e testado. |
| Administra??o | [1 ? Gest?o de corretores](admin/01-admin-lifecycle-brokers.md) | Listagem, convite e layout implementados; extra??o das p?ginas pendente. |
| Permiss?es | [2 ? Capacidades de admin e broker](admin/02-admin-broker-capabilities.md) | Matriz de produto com diverg?ncias de implementa??o identificadas. |
| Corretor | [1 ? Painel e perfil](broker/01-broker-dashboard-profile.md) | `BrokerPage`, perfil e avatar implementados; e-mail de venda e testes do painel pendentes. |
| Propriedades | [2 ? Formul?rio centralizado](properties/02-unified-property-form.md) | Cria??o local com m?dia tempor?ria, edi??o e revis?o implementadas; extra??o e valida??o completa pendentes. |
| M?dia | [1 ? Upload R2](media/01-r2-media-upload.md) | Upload tempor?rio e por im?vel, capa, remo??o/restaura??o e cleanup manual implementados; opera??o externa e limpeza autom?tica pendentes. |

Página individual: [3 — Property Resume](properties/03-property-resume.md), implementada com rota pública, galeria responsiva e contatos.

## Decis?es consolidadas

1. Autentica??o vigente usa backend Node/Fastify, PostgreSQL e JWT. As specs Firebase s?o hist?ricas.
2. Home e Estoque compartilham `PropertySearchPanel` em `main/pages/widgets/search/`. `/estoque` ? a rota can?nica; `/search` ? alias.
3. `MainModule` e `AuthenticationModule` permanecem. O injector principal chama-se `MainInjector`.
4. Convite de corretor usa `POST /api/v1/admin/brokers`, senha tempor?ria e e-mail. O CRUD gen?rico `admin/users` aceita senha e role e permanece dispon?vel no backend.
5. As rotas `new` abrem `PropertyFormPage` com estado local sem ID. Upload tempor?rio antecede a cria??o; endpoints de draft continuam existentes como legado, mas n?o s?o a entrada principal.
6. Cria??o por broker resulta em `pending_review`; por admin, em `published`. Edi??o de im?vel publicado pelo broker cria revis?o. A publica??o exclusiva pelo admin ? regra de produto com uma diverg?ncia no endpoint de status, descrita abaixo.
7. A central de revis?o e notifica??es existe. Workflow independente de solicita??o de destaque e CRUD de localidades continuam pendentes.

## Diverg?ncias e prioridades

- **Autoriza??o de publica??o:** o endpoint `PATCH /broker/properties/:id/status` usa schema que inclui `published` e atualiza o status ap?s validar o im?vel. A exig?ncia de confirma??o exclusiva por admin n?o est? plenamente imposta nessa rota. Corrigir e adicionar teste de autoriza??o em trabalho separado; esta revis?o n?o modifica c?digo.
- **Venda:** o status `sold` pode ser atualizado; n?o foi encontrado envio de e-mail de venda aos admins no handler atual.
- **Valida??o:** R2, SMTP, revis?o de im?veis, guards e navega??o completa precisam de testes e valida??o operacional. O backend n?o tem script de testes em `backend/package.json`.
- **Refatora??o:** pr?xima etapa ? administra??o. A pasta `pages/property_form/` ainda ? destino planejado, n?o existente.
- **Localidades e destaques:** criar specs espec?ficas quando houver escopo de produto definido; n?o inventar contratos nesta revis?o.

## Hist?rico preservado

- [Home inicial](_archive/Home/01-home-showcase-initial-filters.md)
- [Integra??o inicial da busca](_archive/Home/02-search-results-api-integration.md)
- [Firebase Auth](_archive/Users/01-firebase-auth-accesses.md)
- [CRUD Firebase](_archive/Users/02-firebase-admin-users-crud.md)
- [CRUD inicial de im?veis](_archive/Properties/01-broker-admin-properties-crud.md)
