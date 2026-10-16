# Spec 1 ? Refatora??o da apresenta??o

## Status e fonte de verdade

Revisada em 2026-09-19 contra o c?digo local, incluindo altera??es ainda n?o commitadas.
Etapas 1 e 2 conclu?das; etapas 3 a 6 pendentes. O [ai_contract.md](../../../ai_contract.md) permanece obrigat?rio e n?o foi alterado por esta revis?o.

## Escopo e responsabilidades

Manter `MainModule` e `AuthenticationModule`, URLs, apar?ncia, regras de neg?cio e contratos HTTP. N?o alterar `packages/core` nesta refatora??o.

- M?dulos declaram rotas, rota inicial, prote??o de acesso e v?nculo com o injector.
- Injectors registram e conectam depend?ncias, preservando seus escopos.
- P?ginas conectam controller/store, observam estado e comp?em widgets.
- Widgets extra?dos recebem dados e callbacks; n?o recebem controllers de neg?cio nem consultam o injector.
- Componentes exclusivos ficam em `pages/<pagina>/widgets/`; compartilhados no m?dulo ficam em `pages/widgets/`.
- Estado visual e recursos como `TextEditingController` ficam com seu propriet?rio, que os descarta. O estado de neg?cio permanece no controller/store.
- Substituir m?todos auxiliares que retornam widgets por classes ou composi??o com widgets existentes. `build()` e builders exigidos pelo Flutter continuam permitidos.

## Entregas verificadas

### Etapa 1 ? Organiza??o b?sica: conclu?da

- Dez arquivos foram movidos para `lib/app/presentation/main/pages/widgets/`, nos grupos `auth`, `property`, `search` e `admin`.
- `auth` inclui guard, a??o de sess?o e os controllers/store que j? os acompanhavam. Eles ainda s?o componentes conectados ? infraestrutura; seu desacoplamento n?o foi realizado nesta etapa.
- `PropertySearchPanel` ? compartilhado pela Home e pelo Estoque.
- Imagem, tags e `property_management_widgets.dart` ficam em `widgets/property`; `AdminLayout` fica em `widgets/admin`.
- `PropertySegmentsModuleInjector` foi renomeado para `MainInjector`, sem alterar registros ou escopos.
- Imports e refer?ncias foram atualizados. N?o h? arquivos de compatibilidade nos destinos antigos.

### Etapa 2 ? Busca e login: conclu?da

- `search/property_search_page.dart` conserva apenas p?gina/State, liga??o com o controller, layout responsivo e abertura do modal.
- `search/widgets/` cont?m `StockResults`, `StockFilterPanel`, `AppliedFilterChips`, `StockPropertyCard`, `PropertyFacts` e estados de loading/erro/vazio. Formata??o de pre?o, localiza??o e tags permanece em helper de apresenta??o.
- `StockResults` recebe resultado, filtros aplicados, erro, flags de pagina??o e callbacks. A p?gina observa `loadingMore` e repassa o valor.
- `StockFilterPanel` recebe filtros, resultado, controllers de texto e callbacks. A p?gina conserva os controllers compartilhados entre sidebar e modal e os descarta.
- `LoginForm`, em `authentication/pages/login/widgets/`, possui e descarta seus controllers de texto. Recebe `isLoading` e callback com e-mail/senha; os campos sobrevivem a rebuilds de carregamento.
- `LoginPage` mant?m retomada de sess?o, envio ao controller, redirect e exibi??o de erro.
- Removidos `_buildFilterPanel` e `buildVerticalPadding`; o padding usa o widget Flutter diretamente.
- Mantidos os limites atuais: sidebar da busca a partir de 980 px dispon?veis e grid de resultados com limites de 600/900 px.

## Pr?ximas etapas ? ainda n?o executadas

| Etapa | Entrega |
| --- | --- |
| 3 ? Administra??o | Pasta pr?pria por p?gina, extra??o dos componentes locais e organiza??o do layout compartilhado j? movido. |
| 4 ? Corretor | Extrair abas, cards, perfil e di?logos, passando dados e callbacks. |
| 5 ? Formul?rios | Mover p?gina/controller/store/validador para `pages/property_form/`, extrair widgets e desmembrar componentes de gest?o. Preservar upload, valida??o, foco e estado. |
| 6 ? Valida??o integrada | Navega??o, guards, URLs, cria??o/edi??o, teclado, texto ampliado, responsividade e compila??o web. |

Os arquivos de formul?rio continuam em `pages/broker/`. `broker_page.dart`, p?ginas administrativas e componentes compartilhados ainda cont?m classes locais ou m?todos de composi??o. N?o declarar conformidade global antes das etapas restantes.

Cada etapa termina com an?lise, testes pertinentes e resumo para revis?o. Parar ao concluir e aguardar instru??o antes de iniciar a pr?xima. A revis?o documental n?o autoriza executar essas etapas.

## Evid?ncias e limites da valida??o

Resultado registrado na execu??o da etapa 2, em 2026-09-19:

- `flutter test --no-pub`: 15 testes aprovados, sendo 10 novos de widgets.
- `flutter analyze --no-pub`: 26 apontamentos preexistentes, sem novos diagn?sticos. O comando n?o retorna sucesso enquanto esses apontamentos existirem.
- `flutter build web --no-pub`: conclu?do.
- `git diff --check`: sem erros de whitespace.

Arquivos de testes existentes:

- `test/property_search_filters_entity_test.dart`: serializa??o, defaults, tipo inv?lido e atalho por tag.
- `test/property_search_store_test.dart`: append sem IDs duplicados e pagina??o.
- `test/property_search_widgets_test.dart`: aplicar/limpar filtros, callbacks, loading da pagina??o, vazio, retry e resultados em 390/800/1440 px.
- `test/login_form_test.dart`: envio por bot?o/teclado, bloqueio durante loading, preserva??o dos campos e formul?rio em 390/800/1440 px com texto ampliado.

Esses testes n?o comprovam login real, autoriza??o no backend, navega??o completa, modal mobile integrado, R2/SMTP ou layout de todas as p?ginas com teclado aberto. Esses cen?rios continuam pendentes.
