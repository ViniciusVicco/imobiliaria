# Spec 1.2 - Home Showcase, Search Entry and Brand Sections

## Versioning
- Supersedes: `docs/specs/_archive/Home/01-home-showcase-initial-filters.md` for Home layout and search behavior.
- Keeps: architecture contract `widget -> controller -> useCase -> repository -> datasource`.
- Reason for new version: the Home is no longer only a segment grid with initial filters. It becomes a brand showcase with a search entry point, featured properties, institutional sections, and a video block.
- Historical rule: keep previous specs as context; create a new spec when product direction changes layout, routing, or user intent.
- 2026-04-29 update: Home search was reduced for a local Palmas-TO experience. The Home now shows only the essential search controls by default and moves bedrooms, bathrooms, garage spaces, price, and keyword into `Mais filtros`.
- 2026-05-29 update: Home data source moved from local mocks-first to HTTP API-first through `RestClient`.
- 2026-05-30 update: official public segments were consolidated to `residential` and `commercial`; `Na planta` moved from segment/type to the `tag=na-planta` filter.

## Context
The Home should present Seletta as a real estate brand before pushing the user into a full listing experience.

The sketch defines this hierarchy:
1. Top navigation with `Novidades na planta`, `Contatos`, `Sobre nos`, and `Missao`.
2. Short brand message with mission/values.
3. Search/filter block as the main action.
4. Featured property cards.
5. Seletta video presentation.
6. Footer/institutional cards with brand details.

The Home starts a search and sends the user to `/estoque`. The editable result grid and optimized filters live in the Stock page, not only inside the Home.

The product is local to Palmas, Tocantins. Search copy, quick filters, and hidden defaults should reflect this scope.

## Scope
- In scope:
  - Build Home as a structured showcase page.
  - Add a top navigation area.
  - Add a brand message/mission/values section above search.
  - Add a compact Home search/filter block optimized for Palmas.
  - Keep city hidden and defaulted to `Palmas` in state/query contract.
  - Add quick local chips for common Palmas searches.
  - Keep advanced filters collapsed behind `Mais filtros`.
  - Navigate search submit to `/estoque` with query parameters.
  - Make `Novidades na planta` navigate to the same search flow with the `na-planta` tag preselected.
  - Render featured property cards on Home.
  - Add a Seletta video section using the initial YouTube URL.
  - Add lower-page cards for contact, about, and mission details.
- Out of scope:
  - Detail, sorting and favorites inside `/estoque`.
  - SEO strategy for `Na planta` landing pages.
  - Lead capture, favorite, compare, financing simulation, and property detail page.
  - Real CMS/admin editing for institutional content.

## Routes
- `/home`: showcase page.
- `/estoque`: canonical public inventory destination.
- `/search`: compatibility alias for old shared URLs.
- `/investments`: remains available temporarily for compatibility, but `Novidades na planta` uses `/estoque?city=Palmas&tag=na-planta`.

## Backend Integration
Local backend base URL:
```txt
http://localhost:3333/api/v1
```

Home endpoints:
```txt
GET /home/brand-content
GET /home/featured-properties
```

Search endpoints planned/available in backend:
```txt
GET /properties/search
GET /properties/:id
```

Flutter integration rules:
- `PropertySegmentsDatasource` calls HTTP through `RestClient`.
- Endpoint paths are centralized in `PropertySegmentsEndpoints`.
- Controller/usecase/repository boundaries remain unchanged.
- Repository keeps mapping external errors to `Failure`.
- Mocks under `assets/mocks/` remain in the repository as reference data only; API failures render an error state.

## Search Behavior
### Home Search Fields
- `blockOrNeighborhood`: bairro, quadra ou condominio.
- `city`: hidden and defaulted to `Palmas`.
- `segment`: `residential`, `commercial`.
- `propertyType`: enabled and option-driven by selected `segment`.
- `tag`: optional visual/filter helper such as `na-planta`, `alta-rentabilidade`, or `entrada-reduzida`.

Default visible controls:
- `blockOrNeighborhood`
- `segment`
- `propertyType`
- submit button

Quick chips:
- `706 Sul`
- `Plano Diretor Sul`
- `Plano Diretor Norte`
- `Taquaralto`
- `Orla`
- `Casas em condominio`
- `Na planta`

Collapsed advanced fields under `Mais filtros`:
- `query`: free text keyword.
- `bedroomsMin`: options `1+`, `2+`, `3+`, `4+`, `5+`.
- `bathroomsMin`: options `1+`, `2+`, `3+`, `4+`, `5+`.
- `garageSpacesMin`: options `1+`, `2+`, `3+`, `4+`, `5+`.
- `priceMin`: minimum price.
- `priceMax`: maximum price.

### Segment-Specific Property Types
#### Residential
- Apartamento
- Casa
- Casa em condominio
- Sobrado
- Kitnet
- Studio

#### Commercial
- Sala comercial
- Loja
- Galpao
- Predio comercial
- Ponto comercial
- Terreno comercial
- Coworking
- Consultorio

### Submit Contract
When the user submits the Home search:
- Controller validates and normalizes the selected filters.
- UseCase builds a search request/query object.
- Repository maps it into route-safe query parameters.
- Navigator opens `/estoque` with the current filters.

Example:
```txt
/estoque?segment=residential&propertyType=apartment&bedroomsMin=2&bathroomsMin=1&garageSpacesMin=1&priceMin=300000&priceMax=900000
```

Hidden city example:
```txt
/estoque?city=Palmas&segment=commercial&propertyType=commercial-room
```

`Novidades na planta` behavior:
```txt
/estoque?city=Palmas&tag=na-planta
```

## Featured Cards
Home should render a limited list of featured properties, not the full catalog.

Each card should support:
- Cover photo.
- Title.
- Location summary.
- Property type.
- Segment: residential or commercial.
- Tags: render up to 3 visual tags from `tags`, when present.
- Area in square meters.
- Bedrooms, when applicable.
- Bathrooms.
- Garage spaces.
- Property age.
- Price, when available.
- CTA to view details or start search with similar filters.

For commercial cards, bedroom count can be omitted.

## Institutional Sections
### Top Navigation
- `Novidades na planta`: navigates to `/estoque?city=Palmas&tag=na-planta`.
- `Contatos`: scrolls to the contact card near the bottom of Home.
- `Sobre nos`: scrolls to the about card near the bottom of Home.
- `Missao`: scrolls to the mission card near the bottom of Home.

### Brand Message
The message above search should communicate mission/values in a short form.

Initial content can be placeholder copy, but must be isolated from layout code so it can later come from datasource/CMS.

### Video
Use the initial YouTube URL:
```txt
https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1
```

The first implementation can render a thumbnail/CTA that opens the URL. Embedded playback can be a later enhancement.

### Lower Brand Cards
Home bottom must include explicit cards for:
- Contact.
- About Seletta.
- Mission/values.

These cards are the target of top navigation scroll actions.

## Architecture Contracts
- Widget calls only Controller? [ ]
- Controller calls only UseCase? [ ]
- UseCase calls only Repository? [ ]
- Repository concentrates `try/catch`, mapping, and `Failure`? [ ]
- Search state/query mapping is not built directly inside Widget? [ ]
- Navigation to `/estoque` is triggered by Controller via injected `AppNavigator`? [ ]

## Functional Requirements
1. Home displays top navigation with all required entries.
2. Clicking `Novidades na planta` opens `/estoque` with `tag=na-planta`.
3. Clicking `Contatos`, `Sobre nos`, or `Missao` scrolls to the corresponding lower Home card.
4. Home displays a short brand message before the search block.
5. Home displays a search/filter block with the required fields.
6. City field exists in the filter contract, defaults to `Palmas`, and is visually hidden.
7. Selecting `residential` enables residential property types.
8. Selecting `commercial` enables commercial property types.
9. Submitting search navigates to `/estoque` with route-safe query parameters.
10. Home displays featured cards with cover photo, core property facts, and up to 3 tags.
11. Home displays a Seletta video section.
12. Home displays lower explicit cards for contact, about, and mission.
13. Home keeps advanced filters collapsed until the user clicks `Mais filtros`.
14. Quick local chips apply filters and navigate to `/estoque`.

## Non-Functional Requirements
1. Responsive layout for mobile and desktop using `design_system`.
2. Search controls must avoid overflow on small viewports.
3. Featured cards must keep stable dimensions while images load.
4. Controls must have accessible labels and tap targets.
5. Query parameters must be deterministic and shareable.
6. Home first render should not depend on loading the full search result catalog.

## Proposed Data Contracts
### Search Filters
```json
{
  "query": "",
  "blockOrNeighborhood": "",
  "city": "Palmas",
  "segment": "residential",
  "propertyType": "apartment",
  "tag": "",
  "bedroomsMin": 2,
  "bathroomsMin": 1,
  "garageSpacesMin": 1,
  "priceMin": 300000,
  "priceMax": 900000
}
```

### Featured Property
```json
{
  "id": "prop_001",
  "title": "Apartamento com varanda gourmet",
  "segment": "residential",
  "propertyType": "apartment",
  "tags": ["pronto-para-morar"],
  "city": "Sao Paulo",
  "neighborhood": "Pinheiros",
  "coverUrl": "https://...",
  "areaM2": 82,
  "bedrooms": 2,
  "bathrooms": 2,
  "garageSpaces": 1,
  "propertyAgeYears": 4,
  "price": 850000
}
```

### Brand Content
```json
{
  "mission": "Conectar pessoas a imoveis com clareza, criterio e acompanhamento humano.",
  "about": "A Seletta atua na curadoria de oportunidades residenciais, comerciais e de investimento.",
  "contact": {
    "phone": "",
    "email": "",
    "whatsapp": ""
  },
  "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1"
}
```

## Acceptance Criteria (Given/When/Then)
1. Given user opens `/home`, when the page renders, then top navigation, brand message, search block, featured cards, video, and lower brand cards are visible.
2. Given user clicks `Novidades na planta`, when navigation completes, then `/estoque` opens with `city=Palmas` and `tag=na-planta`.
3. Given user clicks `Missao`, when the action runs, then the page scrolls to the mission card.
4. Given user selects `residential`, when property type options open, then only residential types are shown.
5. Given user selects `commercial`, when property type options open, then only commercial types are shown.
6. Given city exists in state, when Home renders, then city is not shown as a visible control.
7. Given user submits search, when filters are valid, then app navigates to `/estoque` with deterministic query params.
8. Given mobile viewport, when Home renders, then search controls stack without overflow.
9. Given desktop viewport, when Home renders, then featured cards use a multi-column layout.
10. Given Home loads, when user has not opened advanced filters, then bedrooms, bathrooms, garage spaces, price, and keyword are hidden.
11. Given user clicks `Mais filtros`, when the panel opens, then advanced filters are available without changing current filters.
12. Given user clicks a local quick chip, when navigation completes, then `/estoque` opens with the chip filter applied.
13. Given a featured property has more than 3 tags, when the card renders, then only the first 3 are shown.

## Technical Plan
- Affected layers:
  - `presentation/main/pages/property_segments`: Home page, controller, store.
  - `domain/property_segments`: search filter entity, featured property entity, use cases.
  - `data/property_segments`: datasource methods, models, repository methods, failures.
  - `presentation/main`: route declarations for `/estoque` and `/search`.
- New or updated use cases:
  - `BuildPropertySearchQueryUseCase`
  - `GetFeaturedPropertiesUseCase`
  - `GetHomeBrandContentUseCase`
- New or updated routes:
  - `MainRoutes.stock = '/estoque'`
  - `MainRoutes.search = '/search'` as compatibility alias.
- Stock page:
  - Receives query parameters, renders editable filters and the public grid.
- Backend:
  - Home brand content and featured properties are served by Node/PostgreSQL.
  - Search endpoint is integrated into `/estoque` and its `/search` alias.

## File Targets (Planned)
- `lib/app/domain/property_segments/entities/property_search_filters_entity.dart`
- `lib/app/domain/property_segments/entities/featured_property_entity.dart`
- `lib/app/domain/property_segments/entities/home_brand_content_entity.dart`
- `lib/app/domain/property_segments/usecases/build_property_search_query_use_case.dart`
- `lib/app/domain/property_segments/usecases/get_featured_properties_use_case.dart`
- `lib/app/domain/property_segments/usecases/get_home_brand_content_use_case.dart`
- `lib/app/data/property_segments/models/property_search_filters_model.dart`
- `lib/app/data/property_segments/models/featured_property_model.dart`
- `lib/app/data/property_segments/models/home_brand_content_model.dart`
- `lib/app/data/property_segments/datasources/property_segments_datasource.dart`
- `lib/app/data/property_segments/repositories/property_segments_repository.dart`
- `lib/app/presentation/main/main_routes.dart`
- `lib/app/presentation/main/main_module.dart`
- `lib/app/presentation/main/pages/property_segments/property_segments_home_store.dart`
- `lib/app/presentation/main/pages/property_segments/property_segments_home_controller.dart`
- `lib/app/presentation/main/pages/property_segments/property_segments_home_page.dart`
- `lib/app/presentation/main/pages/search/property_search_page.dart`

## Risks
- Home search can become too dense for mobile.
- Hidden city field may be forgotten in query mapping.
- Local Palmas chips may become outdated as business priorities change.
- `Na planta` pages may need SEO-specific route strategy later.
- Commercial/residential filters share similar controls but differ in meaning.
- YouTube embed may add performance cost if loaded immediately.

## Mitigations
- Use compact controls and progressive disclosure on mobile.
- Keep a single filter entity with explicit defaults.
- Keep quick chips as presentation-level shortcuts backed by the same filter entity.
- Treat `/estoque` as the canonical functional route and revisit `/investments`/`Na planta` SEO strategy in a dedicated spec.
- Allow card facts to be optional per segment.
- Render video as thumbnail/CTA first; defer embed.

## Test Plan
- Unit:
  - Search query use case maps filters to stable query params.
  - Residential property types are returned only for residential segment.
  - Commercial property types are returned only for commercial segment.
  - Tag shortcut `Na planta` maps to `/estoque?city=Palmas&tag=na-planta`.
  - Repository maps featured property payloads and errors to `DualResponse`.
- Widget:
  - Home renders required sections.
  - City filter is not visible but exists in store/default filters.
  - Default city is `Palmas`.
  - Advanced filters are collapsed by default.
  - Quick chips trigger expected filter updates.
  - Segment selection changes property type options.
  - Featured cards render facts without overflow.
  - Navigation links trigger expected controller actions.
- Integration:
  - Submit Home search and land on `/estoque` with expected query params.
  - Click `Novidades na planta` and land on `/estoque?city=Palmas&tag=na-planta`.
  - Click lower-section nav links and verify scroll target.

## Rollout Strategy
1. Add contracts/entities and datasource-backed placeholder content. [done]
2. Build Home layout sections with static/mock data through repository. [done]
3. Add search query mapping and `/search` compatibility route. [done]
4. Wire top navigation scroll and `Novidades na planta`. [done]
5. Serve Home content from backend Node/PostgreSQL with controlled error state when API is unavailable. [done]
6. Integrate `/estoque` page with `GET /api/v1/properties/search`. [done]
7. Validate mobile/desktop layout and accessibility basics.

## Definition of Done (Spec 1.2)
- Home structure matches the sketch: nav, mission/message, search, highlights, video, brand cards.
- Search submits to `/estoque` with stable query params.
- `Novidades na planta` preselects `tag=na-planta`.
- Segment selection controls property type options.
- City exists in filter state/query contract as `Palmas` but is hidden.
- Home search defaults to compact local Palmas controls.
- Advanced filters are available under `Mais filtros`.
- Quick local chips apply shortcuts into `/estoque`.
- Featured cards show required property facts.
- Architecture flow is respected end to end.
- Errors are mapped in repository as `Failure`.
- Mobile and desktop layouts are validated.
