# Spec 1.1 - Home Showcase with Real Data and Initial Filters

## Context
A home page is already available with 4 entry points (`commercial`, `residential`, `investments`, `announce-property`).
Now we need to evolve this page into a real showcase with property data and initial filters, while preserving the architecture flow:
`widget -> controller -> useCase -> repository -> datasource`.

## Scope
- In scope:
  - Fetch and render real property cards on Home.
  - Add initial filters (city, neighborhood, property type, segment).
  - Keep the segment/announcement navigation grid visible as entry point.
  - Add loading, success, empty, and error states on Home.
- Out of scope:
  - Full advanced filter panel.
  - Favorite, compare, and lead conversion flows.
  - Pagination/infinite scroll (handled in later specs).

## Architecture Contracts
- Widget calls only Controller? [ ]
- Controller calls only UseCase? [ ]
- UseCase calls only Repository? [ ]
- Repository handles `try/catch` and maps to `Failure`? [ ]

## Functional Requirements
1. Home displays at least one section of real property cards.
2. User can filter by:
   - Segment (`commercial`, `residential`, `investments`)
   - City
   - Neighborhood
   - Property type
3. Applying filters refreshes cards without direct API call from widget.
4. If no result, show empty state with clear message.
5. If fetch fails, show feedback and allow retry.

## Non-Functional Requirements
1. Responsive behavior for mobile and desktop using `design_system`.
2. Maintain first render performance suitable for web showcase.
3. Keep route and UI copy in English for segment URLs and section naming.
4. Preserve accessibility basics (tap target, semantic labels, readable contrast).

## Proposed Data Contract (Home List)
Example response used by datasource/repository mapping:
```json
{
  "items": [
    {
      "id": "prop_001",
      "title": "Modern Apartment in Downtown",
      "segment": "residential",
      "type": "apartment",
      "city": "Sao Paulo",
      "neighborhood": "Pinheiros",
      "price": 1250000,
      "thumbnailUrl": "https://..."
    }
  ]
}
```

## Acceptance Criteria (Given/When/Then)
1. Given user opens `/home`, when page loads, then a filtered list of real properties is shown.
2. Given user changes segment filter, when applying filter, then list updates according to selected segment.
3. Given user applies a filter that returns no items, when request completes, then empty state is displayed.
4. Given backend error, when request fails, then error state is shown with retry action.
5. Given mobile viewport, when page renders, then cards and filters adapt without overflow.
6. Given desktop viewport, when page renders, then cards use multi-column layout.

## Technical Plan
- Affected layers:
  - `presentation/main/pages/property_segments`: page, controller, store
  - `domain/property_segments`: entities + use cases
  - `data/property_segments`: datasource, repository, models, failures
- Routes affected:
  - `/home` (enhanced behavior)
- Risks:
  - Inconsistent payload from backend.
  - Excessive filter-triggered requests.
- Mitigation:
  - Repository mapping validation + fallback failure.
  - Debounce/filter-apply action strategy in controller.

## Folder/Files Target (planned)
- `lib/app/domain/property_segments/entities/property_entity.dart`
- `lib/app/domain/property_segments/usecases/get_home_properties_use_case.dart`
- `lib/app/data/property_segments/models/property_model.dart`
- `lib/app/data/property_segments/datasources/property_segments_datasource.dart` (new method)
- `lib/app/data/property_segments/repositories/property_segments_repository.dart` (new method)
- `lib/app/presentation/main/pages/property_segments/property_segments_home_store.dart`
- `lib/app/presentation/main/pages/property_segments/property_segments_home_controller.dart`
- `lib/app/presentation/main/pages/property_segments/property_segments_home_page.dart`

## Test Plan
- Unit:
  - Use case returns mapped `DualResponse` from repository.
  - Repository maps payload and errors to success/failure.
- Widget:
  - Home shows loading, success, empty, and error states.
  - Filter actions trigger controller methods.
- Integration:
  - End-to-end home load + filter apply + retry error flow.

## Rollout Strategy
1. Deliver read-only real list with one default filter preset.
2. Enable all initial filters in UI.
3. Improve UX feedback states and instrumentation.

## Definition of Done (Spec 1.1)
- Home list connected to real data source.
- Initial filters working end-to-end through architecture layers.
- No direct API call in widget/controller.
- Responsive layout validated for mobile/desktop.
- Acceptance criteria covered by tests.
