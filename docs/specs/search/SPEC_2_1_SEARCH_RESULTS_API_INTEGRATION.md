# Spec 2.1 - Search Results API Integration

## Contexto
A Home ja envia filtros para `/search` com query parameters deterministicos. O backend Node/PostgreSQL ja possui o endpoint publico:

```txt
GET /api/v1/properties/search
```

Hoje a pagina `/search` ainda e placeholder e apenas exibe os parametros recebidos. O proximo passo e transformar essa rota em uma pagina funcional de resultados, consumindo a API local e preservando a arquitetura:

```txt
widget -> controller -> useCase -> repository -> datasource
```

## Objetivo
Integrar a pagina `/search` ao backend local para listar imoveis publicados de acordo com os filtros enviados pela Home.

## Escopo
Em escopo:
- Criar fluxo completo de busca em `property_segments` ou feature `search`.
- Consumir `GET /api/v1/properties/search`.
- Mapear query parameters da rota para filtros da API.
- Renderizar loading, sucesso, vazio e erro.
- Renderizar cards de imoveis com dados vindos do PostgreSQL.
- Preservar apenas dados publicos em tela.
- Manter responsividade mobile/desktop com `design_system`.

Fora de escopo:
- Filtros avancados editaveis dentro da pagina `/search`.
- Ordenacao pelo usuario.
- Mapa/geolocalizacao.
- Favoritos, comparacao e leads.
- Detalhe completo do imovel.
- Paginacao visual avancada/infinite scroll.
- Busca full-text avancada.

## Contrato De API
Endpoint:

```txt
GET /api/v1/properties/search
```

Query params aceitos:
- `city`: default `Palmas`.
- `segment`: `residential`, `commercial`, `investments`.
- `propertyType`.
- `blockOrNeighborhood`.
- `query`.
- `bedroomsMin`.
- `bathroomsMin`.
- `garageSpacesMin`.
- `priceMin`.
- `priceMax`.
- `page`: default `1`.
- `pageSize`: default `24`.

Resposta esperada:

```json
{
  "items": [
    {
      "id": "prop_001",
      "title": "Apartamento com varanda gourmet",
      "segment": "residential",
      "propertyType": "Apartamento",
      "city": "Palmas",
      "neighborhood": "Plano Diretor Sul",
      "subNeighborhood": "706 Sul",
      "coverUrl": "https://...",
      "areaM2": 82,
      "bedrooms": 2,
      "bathrooms": 2,
      "garageSpaces": 1,
      "propertyAgeYears": 4,
      "price": 850000
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 24,
    "total": 1,
    "totalPages": 1
  }
}
```

Regra obrigatoria no backend:
- retornar apenas `status=published` para endpoint publico.

## Decisao De Normalizacao
O app hoje usa valores de filtro em ingles/slug:

```txt
propertyType=apartment
propertyType=commercial-room
propertyType=new-development
```

O seed/backend atual guarda labels em portugues:

```txt
Apartamento
Sala comercial
Oportunidades na planta
```

Para esta spec, o backend deve aceitar os slugs enviados pelo Flutter e normalizar para os labels atuais do banco, ou o banco deve ser migrado para slugs. Decisao recomendada:

- Manter o contrato publico da URL com slugs.
- Normalizar no backend em uma funcao local de search.
- Planejar migracao futura do banco para `property_type_slug` e `property_type_label`.

## Camadas Flutter Afetadas
### Data
- Criar endpoint mixin para search, preferencialmente em:
  - `lib/app/data/api/property_segments_endpoints.dart`
- Adicionar metodo no datasource:
  - `searchPublishedProperties(filters/page/pageSize)`
- Criar/ajustar models para resposta de busca:
  - item reutiliza `FeaturedPropertyModel` se o contrato for suficiente.
  - pagination pode ser model simples se necessaria na UI.

### Domain
- Criar use case:
  - `SearchPublishedPropertiesUseCase`
- Criar entity de resultado se necessario:
  - `PropertySearchResultEntity`
  - `PropertySearchPaginationEntity`

### Presentation
- Criar controller/store para `/search` ou evoluir `PropertySearchPage` de forma coerente.
- A page deve:
  - ler `ModuleRouteData.queryParameters`;
  - disparar busca apos primeiro frame;
  - renderizar loading;
  - renderizar grid/lista de cards;
  - renderizar vazio;
  - renderizar erro com retry.

## Backend Afetado
O endpoint ja existe, mas precisa ser revisado para:
- aceitar slugs do Flutter para `propertyType`;
- manter `status=published`;
- suportar `blockOrNeighborhood`;
- suportar `priceMin`/`priceMax`;
- retornar shape estavel para Flutter.

## UX Esperada
### Loading
- Indicador central ou skeleton simples.

### Sucesso Com Resultados
- Titulo: `Resultados da busca`.
- Mostrar total de resultados quando disponivel.
- Cards responsivos usando dados publicos.

### Vazio
- Mensagem clara: `Nenhum imovel encontrado com esses filtros.`
- Acao secundaria: voltar para Home ou limpar filtros em fase futura.

### Erro
- Mensagem clara.
- Botao `Tentar novamente`.
- Se backend estiver fora durante desenvolvimento, pode mostrar fallback vazio ou erro controlado. Nao deve quebrar a tela.

## Criterios De Aceite
1. Dado que usuario submete busca na Home, quando chega em `/search`, entao a pagina chama `GET /api/v1/properties/search` com os filtros da URL.
2. Dado que backend retorna imoveis, quando a resposta chega, entao cards de resultado sao renderizados.
3. Dado que backend retorna lista vazia, quando a resposta chega, entao estado vazio e exibido.
4. Dado que backend falha, quando a requisicao termina, entao erro com retry e exibido.
5. Dado `propertyType=apartment`, quando busca executa, entao backend retorna imoveis do tipo Apartamento.
6. Dado `segment=investments&propertyType=new-development`, quando busca executa, entao backend retorna oportunidades na planta publicadas.
7. Dado mobile viewport, quando resultados renderizam, entao cards nao causam overflow.
8. Dado desktop viewport, quando resultados renderizam, entao layout usa grade responsiva.
9. Dado rota publica `/search`, quando usuario nao esta logado, entao busca funciona sem autenticacao.

## Testes Obrigatorios
### Backend
- Search com filtro por `segment`.
- Search com filtro por `propertyType` slug.
- Search com `blockOrNeighborhood`.
- Search com faixa de preco.
- Search nao retorna `draft`, `inactive` ou `sold`.

### Flutter Unit
- Use case retorna sucesso quando repository retorna items.
- Repository mapeia erro HTTP para Failure.
- Query params da rota viram filtros da API.

### Flutter Widget
- `/search` mostra loading.
- `/search` mostra resultados.
- `/search` mostra vazio.
- `/search` mostra erro e retry.

## Ordem De Entrega
1. Ajustar backend para normalizar `propertyType` slug.
2. Criar/ajustar endpoint mixin no Flutter.
3. Criar datasource/repository/usecase de search.
4. Criar store/controller da Search Page.
5. Substituir placeholder por lista real.
6. Validar local full stack com:
   - `back-end-local`
   - `front-end-local`
7. Adicionar testes focados.

## Definition Of Done
- `/search` consome backend local.
- Resultados reais do PostgreSQL aparecem no Flutter.
- Estados loading/sucesso/vazio/erro funcionam.
- URL continua shareable/deterministica.
- Nenhuma chamada HTTP direta em widget/controller.
- Backend preserva filtro `status=published`.
- Contrato de `propertyType` por slug esta resolvido.
