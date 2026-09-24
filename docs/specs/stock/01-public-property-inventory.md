# Spec 1 - Estoque Publico de Imoveis

## Status
- Implementada no primeiro corte.
- Substitui `docs/specs/_archive/Home/02-search-results-api-integration.md`.
- `/estoque` e a rota canonica; `/search` permanece como alias compativel.

## Contexto
A Home continua como vitrine institucional e mantem sua busca compacta. O
catalogo completo passa a viver em uma tela propria, chamada Estoque, onde o
publico pode consultar e refinar todos os imoveis publicados de Palmas.

## Decisoes fechadas
- Acesso direto a `/estoque` mostra todos os segmentos e tipos publicados.
- Filtros da Home e do Estoque usam o mesmo componente e contrato.
- A Home envia seus filtros para `/estoque` por query parameters.
- Desktop usa sidebar; mobile abre os filtros em painel modal.
- Alteracoes ficam em rascunho ate a acao `Aplicar filtros`.
- Resultados usam paginas de 24 itens e acao `Carregar mais`.
- Cidade permanece oculta e fixa em `Palmas`.
- Ordenacao, favoritos e detalhe completo ficam fora deste corte.

## Rotas
```txt
/estoque
/search
```

`/search` renderiza a mesma experiencia e preserva os parametros antigos. Toda
nova navegacao gerada pela aplicacao usa `/estoque`.

## Filtros
- Segmento: todos, residencial ou comercial.
- Tipo: todos ou um tipo permitido pelo segmento.
- Bairro, quadra ou condominio.
- Tag/atalho, incluindo `na-planta`.
- Palavra-chave.
- Quartos, banheiros e vagas minimas.
- Preco minimo e maximo.

Sem filtros, o contrato envia apenas:
```txt
city=Palmas
```

## API
```txt
GET /api/v1/properties/search
```

Parametros existentes sao preservados. `segment` e `propertyType` ausentes
significam todos. A resposta inclui:

```json
{
  "items": [],
  "pagination": {
    "page": 1,
    "pageSize": 24,
    "total": 0,
    "totalPages": 0
  },
  "facets": {
    "priceRange": {
      "min": 300000,
      "max": 1800000
    }
  }
}
```

A faixa ignora somente `priceMin` e `priceMax`, mantendo os demais filtros. Se
nao houver valores, `min` e `max` retornam `null`.

## Comportamento
1. Abrir o Estoque le filtros da URL e busca a primeira pagina.
2. Editar controles altera somente os filtros em rascunho.
3. Aplicar substitui a rota pela URL canonica e busca novamente.
4. Limpar abre `/estoque?city=Palmas`.
5. Carregar mais solicita a pagina seguinte e acrescenta itens sem duplicar IDs.
6. Loading inicial, erro, vazio e erro de pagina adicional sao independentes.

## Arquitetura
- Widget -> Controller -> UseCase -> Repository -> Datasource.
- O controller coordena URL, aplicacao, limpeza, retry e paginacao.
- O repository concentra mapeamento de falhas.
- Widgets nao acessam API diretamente.

## Implementa??o e cobertura em 2026-09-19

- `PropertySearchPage` conecta controller/store e abre sidebar/modal; componentes visuais ficam em `main/pages/search/widgets/`.
- `StockResults` recebe dados e callbacks, sem controller de neg?cio. `StockFilterPanel` adapta os dados para o painel compartilhado em `main/pages/widgets/search/`.
- Sidebar usa largura dispon?vel de 980 px; o grid usa limites de 600/900 px. A extra??o preservou esses valores.
- Testes existentes: `test/property_search_filters_entity_test.dart`, `test/property_search_store_test.dart` e `test/property_search_widgets_test.dart`.
- Cobertura: filtros, append sem duplica??o, callbacks de aplicar/limpar/retry, loading de pagina??o e resultados em 390/800/1440 px.
- N?o cobre ainda navega??o Home -> Estoque com API real, autoriza??o p?blica no backend nem o modal mobile integrado. Esses crit?rios continuam pendentes de valida??o.

## Criterios de aceite
1. Home filtrada abre `/estoque` com parametros deterministicos.
2. `/estoque` sem filtros lista todos os publicados de Palmas.
3. `/search` com URL antiga continua funcional.
4. Segmento/tipo `Todos` nao sao enviados para a API.
5. Sidebar desktop e painel mobile exibem os mesmos controles.
6. Aplicar filtros reinicia na primeira pagina.
7. Carregar mais preserva itens atuais e desaparece na ultima pagina.
8. Busca publica nunca retorna `draft`, `pending_review`, `sold` ou `inactive`.
9. O slider usa a faixa informada pela API.

## Testes obrigatorios
- Serializacao e leitura dos filtros.
- Tipo invalido volta para `Todos os tipos`.
- Atalho somente por tag preserva URL.
- Append de pagina remove IDs duplicados.
- API filtra apenas publicados e calcula faixa sem restricao de preco.
- Responsividade sem overflow em desktop e mobile.

## Definition of Done
- `/estoque` e `/search` funcionam.
- Home e Estoque compartilham filtros.
- Todos os publicados aparecem por padrao.
- Aplicar, limpar, retry e carregar mais funcionam.
- Backend compila, testes focados passam e Flutter nao possui erro novo.

## Página individual — atualização de 2026-09-23

O detalhe público foi entregue separadamente na [spec Property Resume](../properties/03-property-resume.md), em `/imovel/:id`. Cards abrem o imóvel; na Home, o botão WhatsApp mantém sua ação independente. As exclusões de escopo acima descrevem a entrega original.
