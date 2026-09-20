# Arquitetura e entrega incremental

## Refer?ncias e estado

Revisado em 2026-09-19. O [ai_contract.md](../ai_contract.md) define as regras obrigat?rias de legibilidade, reutiliza??o, organiza??o de widgets e layouts mobile/web. Consulte o [?ndice de specs](specs/README.md) para contratos de produto e a [spec de refatora??o](specs/presentation/01-presentation-refactoring.md) para entregas e pend?ncias.

A base atual ? Flutter com backend Node/Fastify, Prisma e PostgreSQL. Auth usa JWT; armazenamento de m?dia usa R2 por interm?dio do backend. Firebase n?o faz parte do fluxo vigente.

## Camadas e responsabilidades

Fluxo de opera??es com dados: `p?gina/callback -> controller -> use case -> repository -> datasource -> RestClient`. Widgets visuais n?o fazem HTTP.

| Camada | Responsabilidade |
| --- | --- |
| Module | Declarar rotas, rota inicial e injector; compor p?ginas e guards. |
| Injector | Registrar depend?ncias e seus escopos. |
| P?gina | Conectar controller/store, observar estado, tratar argumentos e compor widgets. |
| Widget extra?do | Renderizar dados recebidos e disparar callbacks; manter estado visual local quando necess?rio. |
| Controller | Coordenar a??es, use cases, store e navega??o. |
| Store | Representar estado observ?vel da funcionalidade. |
| Use case | Encapsular a a??o; chamar repository quando exige dados. Regras puras, como resolu??o de acesso, n?o precisam de repository. |
| Repository | Adaptar respostas e mapear exce??es para `Failure`/`DualResponse`. |
| Datasource | Acessar HTTP/storage e adaptar payloads; endpoints centralizados em `lib/app/data/api/`. |

Esse ? o padr?o de destino; componentes legados ainda recebem controllers completos ou acessam `Module.get`. A refatora??o est? parcial, n?o conclu?da globalmente.

## Organiza??o atual

- `packages/core`: m?dulos, inje??o, navega??o, estado e cliente HTTP. Ciclo de vida fora do escopo da refatora??o atual.
- `packages/design_system`: tokens, layout, grids e componentes gen?ricos sem depend?ncias do dom?nio do app.
- `lib/app/data/<feature>/`: datasources, repositories, models e failures.
- `lib/app/domain/<feature>/`: entidades e use cases.
- `lib/app/presentation/<module>/`: m?dulo, injector, rotas e p?ginas.
- `pages/<pagina>/widgets/`: componentes exclusivos da p?gina.
- `pages/widgets/`: componentes compartilhados entre p?ginas do m?dulo.

Em `main/pages/widgets/` existem os grupos `admin`, `auth`, `property` e `search`. Busca tem seus pr?prios componentes em `main/pages/search/widgets/`; login em `authentication/pages/login/widgets/`.

O formul?rio de im?veis ainda fica em `main/pages/broker/`. Mov?-lo para `main/pages/property_form/` ? parte da etapa 5, n?o uma mudan?a j? realizada. Classes de widgets ainda presentes em p?ginas de corretor e administra??o ser?o extra?das nas etapas correspondentes.

## Rotas e inje??o

`ModuleApp` registra `MainModule` e `AuthenticationModule`. `MainModule` usa `MainInjector`; autentica??o usa `AuthenticationInjector`. Preservar o getter do injector, pois sua constru??o consulta o m?dulo registrado:

```dart
@override
ModuleInjector<MainModule> get injector => MainInjector();
```

| Rotas | Implementa??o |
| --- | --- |
| `/home` | Vitrine, busca compartilhada, destacados, v?deo e conte?do institucional. |
| `/estoque`, `/search` | Mesma `PropertySearchPage`; novas buscas navegam para `/estoque`. |
| `/login` | `LoginPage` e `LoginForm`; retomada de sess?o e redirect no controller. |
| `/broker`, `/broker/properties` | `BrokerPage`, com abas de im?veis e perfil. |
| `/broker/properties/new`, `/broker/properties/:id/edit` | `PropertyFormPage` em modo broker. |
| `/admin`, `/admin/users`, `/admin/properties`, `/admin/review` | Home, corretores, im?veis e revis?o administrativa. |
| `/admin/properties/new`, `/admin/properties/:id/edit` | Mesmo formul?rio em modo admin. |
| `/commercial`, `/residential`, `/investments`, `/announce-property` | `SegmentDetailsPage`, ainda placeholder. |

Guard Flutter melhora a experi?ncia; o backend deve autorizar cada opera??o. A diverg?ncia de publica??o pelo endpoint de status do broker est? registrada no ?ndice de specs.

## Responsividade e estado visual

Usar `DSPageLayoutContainer`, tokens e componentes existentes. N?o alterar breakpoints durante uma extra??o estrutural: a busca usa sidebar a partir de 980 px dispon?veis; seus resultados usam 600/900 px para colunas. O layout admin usa 820 px para alternar sidebar e abas.

Widgets de apresenta??o recebem dados/callbacks. `LoginForm` possui seus controllers de texto; a p?gina de busca conserva os controllers usados em sidebar/modal. Cada propriet?rio deve descartar seus recursos. Componentes gen?ricos sem regras de produto podem ir para o design system; componentes com entidades, textos e a??es de produto permanecem no app.

## Entrega orientada por specs

Cada spec deve distinguir:

1. Estado implementado, data e arquivos/s?mbolos que o comprovam.
2. Requisitos e diverg?ncias ainda abertas.
3. Crit?rios de aceite e testes necess?rios.
4. Valida??es realmente executadas e seus limites.

Mudan?as documentais n?o comprovam funcionamento operacional. Na etapa 2 passaram 15 testes Flutter e a compila??o web; a an?lise manteve 26 apontamentos anteriores. Integra??o com backend, R2/SMTP e navega??o completa permanecem pendentes. N?o tratar checklist de testes desejados como cobertura existente.
