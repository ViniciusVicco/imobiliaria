# Graph Report - imobiliaria  (2026-11-21)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 3215 nodes · 4932 edges · 186 communities (157 shown, 29 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 51 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `23eba1a9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- property_form_page.dart
- StatelessWidget
- authentication_injector.dart
- property_management_widgets.dart
- package:legend_core/legend_core.dart
- main_injector.dart
- property_search_panel.dart
- property_segments_home_controller.dart
- design_system_mixin.dart
- broker_property_entity.dart
- GeneratedPluginRegistrant.swift
- package:flutter/material.dart
- profile_photo_editor.dart
- broker_store.dart
- property_brand_reveal.dart
- media_repository.dart
- property_form_controller.dart
- admin-users.routes.ts
- search_property_entity.dart
- dependencies
- broker_profile_test.dart
- module.dart
- auth.middleware.ts
- my_application.cc
- theme.dart
- broker_properties_controller.dart
- admin_properties_page.dart
- property_search_filters_entity.dart
- protected-properties.routes.ts
- design_typography.dart
- admin_brokers_page.dart
- admin_layout.dart
- package.json
- MainModule
- main_routes.dart
- featured_properties_section.dart
- stock_results.dart
- broker_controller.dart
- app.ts
- avatar.ts
- stock_filter_panel.dart
- admin_broker_edit_dialog.dart
- property_resume_page.dart
- property_brand_cards_section_test.dart
- package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart
- module_app.dart
- media.routes.ts
- property_segments_home_page.dart
- package:dio/dio.dart
- property_media_entity.dart
- property_detail_content.dart
- property_gallery.dart
- property_segments_top_navigation.dart
- property_search_controller.dart
- admin_outbound_links_page.dart
- auth_token_interceptor.dart
- broker_properties_repository.dart
- property_brand_cards_section.dart
- property_search_page.dart
- featured_property_entity.dart
- package:imobiliaria/app/domain/users/entities/user_profile_entity.dart
- property_image_picker_stub.dart
- admin_brokers_repository.dart
- main_module.dart
- property_resume_navigation_test.dart
- profile.test.ts
- admin_notification_entity.dart
- admin_brokers_controller.dart
- go-live-proxy.mjs
- session_action.dart
- custom_assets.dart
- broker_properties_datasource.dart
- broker-welcome-email.ts
- admin_brokers_datasource.dart
- property_segments_datasource.dart
- property_image_picker_web.dart
- property_tag_selector.dart
- home_brand_content_entity.dart
- auth_datasource.dart
- win32_window.cpp
- utils.cpp
- property_resume_test.dart
- property_segments_repository.dart
- property_card_image.dart
- property_search_store.dart
- design_system/pubspec.yaml
- .Create
- state.dart
- module_injector.dart
- authenticated_user_entity.dart
- admin_properties_store.dart
- property_resume_actions.dart
- auth_guard_page.dart
- List
- core/pubspec.yaml
- Win32Window
- compilerOptions
- app_navigator.dart
- admin_broker_entity.dart
- property_form_validator.dart
- property_segments_home_store.dart
- .MessageHandler
- enviroment.dart
- broker_property_model.dart
- authentication_module.dart
- login_page.dart
- property_tag_catalog.dart
- design_tokens.dart
- manifest.json
- protected_route_access_entity.dart
- ds_youtube_embed.dart
- FlutterWindow::OnCreate
- FlutterWindow
- user_profile_repository.dart
- session_store.dart
- login_form.dart
- StatefulWidget
- property_form_store.dart
- package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart
- .MessageHandler
- profile_photo_editor_test.dart
- dual_response.dart
- env_abstract.dart
- Failure
- admin_review_endpoints.dart
- broker_properties_endpoints.dart
- get_property_detail_use_case.dart
- auth_repository.dart
- login_store.dart
- module_window_widget.dart
- Controller
- package:flutter_test/flutter_test.dart
- State
- layout_breakpoints.dart
- seed.ts
- jwt.ts
- dart:async
- _
- package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart
- property_segment_route_model.dart
- admin_brokers_store.dart
- property_resume_controller.dart
- auth_guard_store.dart
- AppState
- bool get
- property_resume_state_test.dart
- ds_youtube_embed_web.dart
- admin_notifications_datasource.dart
- property_resume_store.dart
- property_tag_chips.dart
- property_photo.dart
- cancelable_request.dart
- property_detail_repository.dart
- Map
- property_search_formatters.dart
- ds_weighted_field.dart
- login_form_test.dart
- responsive_app_builder.dart
- property_image_picker_types.dart
- package:flutter/widgets.dart
- data_source_response.dart
- rest_env.dart
- binds_arguments.dart
- MainActivity.kt
- media_failure.dart
- segment_route_failure.dart
- package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart
- auth_failure.dart
- user_profile_failure.dart
- url_strategy_web.dart
- String get
- random_alpha_and_num_generator_mixin.dart
- url_strategy_stub.dart
- PropertyFormDialog
- PropertyManagementCoverImage
- _PriceRangeSlider
- PropertySearchPanel

## God Nodes (most connected - your core abstractions)
1. `MainModule` - 30 edges
2. `Win32Window` - 27 edges
3. `sendApiError()` - 23 edges
4. `mediaRoutes()` - 22 edges
5. `protectedPropertiesRoutes()` - 21 edges
6. `fastify` - 21 edges
7. `buildApp()` - 18 edges
8. `prisma` - 18 edges
9. `zod` - 18 edges
10. `requireActiveAdmin()` - 17 edges

## Surprising Connections (you probably didn't know these)
- `_BrokerPageState` --inherits--> `StateController`  [EXTRACTED]
  lib/app/presentation/main/pages/broker/broker_page.dart → packages/core/lib/src/dependencies/state.dart
- `AuthenticationModule` --inherits--> `Module`  [EXTRACTED]
  lib/app/presentation/authentication/authentication_module.dart → packages/core/lib/src/module/module/module.dart
- `LoginController` --inherits--> `Controller`  [EXTRACTED]
  lib/app/presentation/authentication/pages/login/login_controller.dart → packages/core/lib/src/dependencies/controller.dart
- `_LoginPageState` --inherits--> `StateController`  [EXTRACTED]
  lib/app/presentation/authentication/pages/login/login_page.dart → packages/core/lib/src/dependencies/state.dart
- `PropertyFormController` --inherits--> `Controller`  [EXTRACTED]
  lib/app/presentation/main/pages/broker/property_form_controller.dart → packages/core/lib/src/dependencies/controller.dart

## Import Cycles
- None detected.

## Communities (186 total, 29 thin omitted)

### Community 0 - "property_form_page.dart"
Cohesion: 0.02
Nodes (88): _activeImageUrls, _areaController, areaM2, _bathrooms, _bedrooms, _brokerId, build, _buildForm (+80 more)

### Community 1 - "StatelessWidget"
Cohesion: 0.03
Nodes (82): BrokerPage, _BrokerPageState, BrokerPasswordDialog, _BrokerPasswordDialogState, BrokerProfileTab, build, _CardMetric, _changePassword (+74 more)

### Community 2 - "authentication_injector.dart"
Cohesion: 0.04
Nodes (48): AuthenticatedUserModel, fromJson, AuthRepository, call, GetCurrentUserSessionUseCase, repository, call, LoginWithEmailUseCase (+40 more)

### Community 3 - "property_management_widgets.dart"
Cohesion: 0.03
Nodes (64): allowBrokerId, _areaController, _bathrooms, _bedrooms, _brokerIdController, build, _buildForm, _cityController (+56 more)

### Community 4 - "package:legend_core/legend_core.dart"
Cohesion: 0.05
Nodes (42): message, BrokerPropertiesRepository, ApproveAdminPropertyUseCase, call, repository, call, CreateAdminPropertyDraftUseCase, repository (+34 more)

### Community 5 - "main_injector.dart"
Cohesion: 0.05
Nodes (39): AdminNotificationsRepository, call, GetAdminNotificationsUseCase, repository, call, MarkAdminNotificationReadUseCase, repository, SessionStore (+31 more)

### Community 6 - "property_search_panel.dart"
Cohesion: 0.04
Nodes (51): _ActiveTagFilter, allowAll, autoSubmitShortcuts, availableMax, availableMin, blockOrNeighborhoodController, buffer, build (+43 more)

### Community 7 - "property_segments_home_controller.dart"
Cohesion: 0.04
Nodes (36): PropertySegmentsRepository, BuildPropertySearchQueryUseCase, call, repository, call, GetFeaturedPropertiesUseCase, repository, call (+28 more)

### Community 8 - "design_system_mixin.dart"
Cohesion: 0.04
Nodes (38): background, breakpoints, colors, desktop, DSBreakpointTokens, DSColorTokens, DSRadiusTokens, DSSpacingTokens (+30 more)

### Community 9 - "broker_property_entity.dart"
Cohesion: 0.04
Nodes (46): areaM2, bathrooms, bedrooms, broker, brokerId, BrokerPropertyFormEntity, city, copyWith (+38 more)

### Community 10 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (19): Cocoa, file_selector_macos, Flutter, FlutterMacOS, Foundation, AppDelegate, SceneDelegate, RunnerTests (+11 more)

### Community 11 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (30): PropertySearchFiltersEntity, build, content, enabled, onPressed, PropertyVideoSection, thumbnailUrl, _VideoFallback (+22 more)

### Community 12 - "profile_photo_editor.dart"
Cohesion: 0.05
Nodes (35): mediaCover, MediaEndpoints, mediaFile, mediaPendingDelete, mediaRestore, propertyImages, temporaryPropertyImages, getFile (+27 more)

### Community 13 - "broker_store.dart"
Cohesion: 0.05
Nodes (42): UserProfileModel, about, avatarUrl, brokerCode, copyWith, createdAt, creci, email (+34 more)

### Community 14 - "property_brand_reveal.dart"
Cohesion: 0.05
Nodes (33): build, createState, didPopRoute, didPushRouteInformation, dispose, _initialRoute, initState, MainNavigation (+25 more)

### Community 15 - "media_repository.dart"
Cohesion: 0.06
Nodes (28): fromJson, datasource, getFile, MediaRepository, pendingDelete, _requestMedia, restore, setCover (+20 more)

### Community 16 - "property_form_controller.dart"
Cohesion: 0.05
Nodes (28): deletePropertyMedia, finalizeProperty, getAdminProperty, getBrokerProperty, getPropertyMediaFile, getPropertyResponsibles, _isAdminMode, loadBrokers (+20 more)

### Community 17 - "admin-users.routes.ts"
Cohesion: 0.11
Nodes (26): adminBrokersRoutes(), createBrokerBodySchema, adminUsersRoutes(), buildUserWhere(), createUserBodySchema, listUsersQuerySchema, paramsSchema, toAdminUserResponse() (+18 more)

### Community 18 - "search_property_entity.dart"
Cohesion: 0.06
Nodes (33): fromJson, PropertySearchPaginationModel, PropertySearchResultModel, SearchPropertyModel, areaM2, bathrooms, bedrooms, city (+25 more)

### Community 19 - "dependencies"
Cohesion: 0.06
Nodes (34): dependencies, bootstrap_icons, design_system, dio, equatable, flutter, flutter_bloc, flutter_web_plugins (+26 more)

### Community 20 - "broker_profile_test.dart"
Cohesion: 0.07
Nodes (28): GetBrokerPropertiesUseCase, GetUserProfileUseCase, UpdateUserProfileUseCase, UploadUserAvatarUseCase, AdminBrokersController, BrokerController, AdminController, avatarPicks (+20 more)

### Community 21 - "module.dart"
Cohesion: 0.06
Nodes (29): _composeRouteArguments, injector, didStart, dispose, extra, _extractPathParameters, fullPath, getFallBackRoute (+21 more)

### Community 22 - "auth.middleware.ts"
Cohesion: 0.16
Nodes (16): fastify, FastifyRequest, requireActiveAdmin(), requireActiveBroker(), featuredQuerySchema, clickBodySchema, listQuerySchema, outboundLinksRoutes() (+8 more)

### Community 23 - "my_application.cc"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 24 - "theme.dart"
Cohesion: 0.06
Nodes (24): background, brandLogoBackground, colorScheme, dark, DSColors, DSTheme, error, onError (+16 more)

### Community 25 - "broker_properties_controller.dart"
Cohesion: 0.07
Nodes (22): createDraftAndOpenForm, getBrokerProperties, getPropertyMediaFile, loadMediaFile, loadProperties, navigator, openEditForm, saveBrokerProperty (+14 more)

### Community 26 - "admin_properties_page.dart"
Cohesion: 0.08
Nodes (21): AdminHomePage, build, AdminPropertiesController, AdminPropertiesPage, _AdminPropertiesPageState, build, _confirmStatus, _createDraft (+13 more)

### Community 27 - "property_search_filters_entity.dart"
Cohesion: 0.08
Nodes (25): AnyPropertyType, bathroomsMin, bedroomsMin, blockOrNeighborhood, city, CommercialPropertyType, copyWith, defaultPropertyType (+17 more)

### Community 28 - "protected-properties.routes.ts"
Cohesion: 0.14
Nodes (23): buildListWhere(), buildMediaRows(), findPropertyDetail(), listProperties(), listPropertiesQuerySchema, mapPropertyDetail(), mapPropertyListItem(), normalizeTagSlugs() (+15 more)

### Community 29 - "design_typography.dart"
Cohesion: 0.08
Nodes (19): body, caps, display, DSBodyTypography, DSDisplayTypography, DSHeadingTypography, DSLabelTypography, DSTypographyTokens (+11 more)

### Community 30 - "admin_brokers_page.dart"
Cohesion: 0.08
Nodes (21): _AdminBrokersErrorState, _AdminBrokersList, brokers, build, controller, _CreateBrokerDialog, _CreateBrokerDialogState, createState (+13 more)

### Community 31 - "admin_layout.dart"
Cohesion: 0.08
Nodes (15): BrokerHomePage, build, AdminLayout, _AdminNavButton, _AdminSidebar, _AdminTopTabs, build, child (+7 more)

### Community 32 - "package.json"
Cohesion: 0.09
Nodes (24): devDependencies, prisma@^6.19.0, tsx@^4.20.6, @types/node@^24.10.1, typescript@^5.9.3, name, prisma, seed (+16 more)

### Community 33 - "MainModule"
Cohesion: 0.10
Nodes (19): MainModule, AdminBrokersPage, _AdminBrokersPageState, BrokerPropertiesController, BrokerPropertiesPage, _BrokerPropertiesPageState, build, _confirmStatus (+11 more)

### Community 34 - "main_routes.dart"
Cohesion: 0.08
Nodes (24): admin, adminOutboundLinks, adminProperties, adminPropertyEdit, adminPropertyEditPath, adminPropertyNew, adminReview, adminUsers (+16 more)

### Community 35 - "featured_properties_section.dart"
Cohesion: 0.08
Nodes (24): build, _collapsedLimit, createState, _expandedLimit, _FeaturedPropertiesEmptyState, FeaturedPropertiesSection, _FeaturedPropertiesSectionState, _FeaturedPropertyCard (+16 more)

### Community 36 - "stock_results.dart"
Cohesion: 0.08
Nodes (17): appliedFilters, build, _buildSummary, canLoadMore, errorMessage, filters, isLoadingMore, onLoadMore (+9 more)

### Community 37 - "broker_controller.dart"
Cohesion: 0.08
Nodes (18): changePassword, getBrokerProperties, getPropertyMediaFile, getUserProfile, _isChangingPassword, load, loadMediaFile, loadProperties (+10 more)

### Community 39 - "app.ts"
Cohesion: 0.17
Nodes (18): buildApp(), isAllowedLocalOrigin(), mapPrismaError(), mapZodFieldErrors(), env, envSchema, adminNotificationsRoutes(), adminReportsRoutes() (+10 more)

### Community 40 - "avatar.ts"
Cohesion: 0.23
Nodes (19): createPropertyWithTemporaryMedia(), assertR2Configured(), buildR2PublicUrl(), copyR2Object(), deleteR2Object(), encodeR2CopySourceKey(), getAllowedImageMimeTypes(), getMaxImageSizeBytes() (+11 more)

### Community 41 - "stock_filter_panel.dart"
Cohesion: 0.09
Nodes (18): brokers, build, currentName, isNew, onChanged, PropertyResponsibleDropdown, value, _asFeaturedProperties (+10 more)

### Community 42 - "admin_broker_edit_dialog.dart"
Cohesion: 0.09
Nodes (17): _about, _avatar, broker, build, _busy, controller, createState, _creci (+9 more)

### Community 43 - "property_resume_page.dart"
Cohesion: 0.10
Nodes (14): PropertyResumeController, build, _contact, createState, didUpdateWidget, dispose, extends, _id (+6 more)

### Community 44 - "property_brand_cards_section_test.dart"
Cohesion: 0.09
Nodes (15): about, build, capture, contact, _content, _finishAnimations, _Harness, main (+7 more)

### Community 45 - "package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart"
Cohesion: 0.12
Nodes (15): fromJson, AdminBrokersRepository, call, CreateAdminBrokerUseCase, repository, call, repository, UpdateAdminBrokerUseCase (+7 more)

### Community 46 - "module_app.dart"
Cohesion: 0.10
Nodes (20): build, _childModules, createState, dispose, disposeChildModules, _disposeModules, _initModules, initState (+12 more)

### Community 47 - "media.routes.ts"
Cohesion: 0.18
Nodes (19): getBearerToken(), requireAuthenticatedUser(), buildPropertyMediaStorageKey(), buildTempPropertyMediaStorageKey(), findAccessibleMedia(), findAccessibleProperty(), getNextSortOrder(), getNextTempSortOrder() (+11 more)

### Community 48 - "property_segments_home_page.dart"
Cohesion: 0.10
Nodes (15): PropertySegmentsHomeController, _aboutKey, _blockOrNeighborhoodController, _contactKey, createState, dispose, extends, _filterFeaturedPropertiesByPrice (+7 more)

### Community 49 - "package:dio/dio.dart"
Cohesion: 0.11
Nodes (15): getProfile, _restClient, updatePassword, updateProfile, uploadAvatar, UserProfileDatasource, addInterceptor, dio (+7 more)

### Community 50 - "property_media_entity.dart"
Cohesion: 0.10
Nodes (20): PropertyMediaModel, contentBase64, deletedAt, fileName, id, isActive, isImage, mimeType (+12 more)

### Community 51 - "property_detail_content.dart"
Cohesion: 0.10
Nodes (17): build, child, description, desktop, _gold, icon, onContact, onShare (+9 more)

### Community 52 - "property_gallery.dart"
Cohesion: 0.10
Nodes (18): build, createState, desktop, dispose, images, _index, initialIndex, _move (+10 more)

### Community 53 - "property_segments_top_navigation.dart"
Cohesion: 0.10
Nodes (18): build, icon, isCompact, label, _LogoMark, _NavigationLinkButton, _NavigationLinks, onAboutPressed (+10 more)

### Community 54 - "property_search_controller.dart"
Cohesion: 0.10
Nodes (17): _appliedQueryParameters, applyFilters, clearFilters, load, loadMore, _navigator, _openCanonicalStock, retry (+9 more)

### Community 55 - "admin_outbound_links_page.dart"
Cohesion: 0.11
Nodes (16): _, BrandInstitutionalContent, mission, values, vision, AdminOutboundLinksPage, _AdminOutboundLinksPageState, build (+8 more)

### Community 56 - "auth_token_interceptor.dart"
Cohesion: 0.10
Nodes (15): accessTokenKey, AuthTokenInterceptor, _candidatePaths, _handleError, _handleRequest, _isProtectedPath, _isProtectedRequest, _normalizePath (+7 more)

### Community 57 - "broker_properties_repository.dart"
Cohesion: 0.10
Nodes (17): approveAdminProperty, createAdminProperty, createAdminPropertyDraft, createBrokerProperty, createBrokerPropertyDraft, datasource, getAdminProperties, getAdminProperty (+9 more)

### Community 58 - "property_brand_cards_section.dart"
Cohesion: 0.11
Nodes (18): aboutKey, body, _BrandGrid, build, children, contactKey, content, createState (+10 more)

### Community 59 - "property_search_page.dart"
Cohesion: 0.11
Nodes (11): PropertySearchController, _blockOrNeighborhoodController, createState, dispose, extends, initState, PropertySearchPage, _PropertySearchPageState (+3 more)

### Community 60 - "featured_property_entity.dart"
Cohesion: 0.11
Nodes (17): FeaturedPropertyModel, areaM2, bathrooms, bedrooms, city, coverUrl, FeaturedPropertyEntity, garageSpaces (+9 more)

### Community 61 - "package:imobiliaria/app/domain/users/entities/user_profile_entity.dart"
Cohesion: 0.14
Nodes (12): fromJson, UserProfileRepository, call, repository, call, repository, UpdateUserPasswordUseCase, call (+4 more)

### Community 62 - "property_image_picker_stub.dart"
Cohesion: 0.11
Nodes (13): pickPropertyImage, pickPropertyImages, bytes, camera, file, files, lower, mime (+5 more)

### Community 63 - "admin_brokers_repository.dart"
Cohesion: 0.12
Nodes (10): createBroker, datasource, _edit, getBrokers, getPropertyResponsibles, updateBroker, uploadAvatar, datasource (+2 more)

### Community 64 - "main_module.dart"
Cohesion: 0.11
Nodes (4): initialRoute, injector, routes, widget

### Community 65 - "property_resume_navigation_test.dart"
Cohesion: 0.11
Nodes (9): build, build, actions, injector, QuickActions, QuickActionsMixin, initialRoute, injector (+1 more)

### Community 66 - "profile.test.ts"
Cohesion: 0.12
Nodes (15): dependencies, @aws-sdk/client-s3@^3.1075.0, dotenv@^17.2.3, fastify@^5.6.2, @fastify/cors@^11.0.1, @prisma/client@^6.19.0, zod@^4.1.13, AuthenticatedUser (+7 more)

### Community 67 - "admin_notification_entity.dart"
Cohesion: 0.12
Nodes (14): AdminNotificationModel, AdminNotificationsModel, fromJson, AdminNotificationEntity, AdminNotificationsEntity, createdAt, emailStatus, id (+6 more)

### Community 68 - "admin_brokers_controller.dart"
Cohesion: 0.12
Nodes (11): createAdminBroker, createBroker, editError, getAdminBrokers, _isEditing, loadBrokers, saveBroker, store (+3 more)

### Community 69 - "go-live-proxy.mjs"
Cohesion: 0.18
Nodes (7): contentTypes, createGoLiveServer(), defaultWebRoot, endError(), forwardingHeaders(), inside(), proxyApi()

### Community 70 - "session_action.dart"
Cohesion: 0.13
Nodes (11): _authenticatedButton, build, compact, _confirmLogout, createState, initState, _loadingButton, _loginButton (+3 more)

### Community 71 - "custom_assets.dart"
Cohesion: 0.12
Nodes (12): CustomAssets, featuredProperties, homeBrandContent, IconAssets, icons, logo, Logos, logoSeletta (+4 more)

### Community 72 - "broker_properties_datasource.dart"
Cohesion: 0.12
Nodes (15): approveAdminProperty, createAdminProperty, createAdminPropertyDraft, createBrokerProperty, createBrokerPropertyDraft, getAdminProperties, getAdminProperty, getBrokerProperties (+7 more)

### Community 73 - "broker-welcome-email.ts"
Cohesion: 0.24
Nodes (12): buildBrokerWelcomeHtml(), buildBrokerWelcomeText(), buildEmailMessage(), connectToGmailSmtp(), EmailDeliveryError, encodeHeader(), escapeHtml(), sendAdminPropertyReviewEmail() (+4 more)

### Community 74 - "admin_brokers_datasource.dart"
Cohesion: 0.13
Nodes (12): AdminBrokersDatasource, createBroker, getBrokerPropertySummaries, getBrokers, getPropertyResponsibles, _restClient, updateBroker, uploadAvatar (+4 more)

### Community 75 - "property_segments_datasource.dart"
Cohesion: 0.13
Nodes (12): brandContent, featuredProperties, homeBaseUrl, propertiesBaseUrl, propertiesSearch, PropertySegmentsEndpoints, getFeaturedProperties, getHomeBrandContent (+4 more)

### Community 76 - "property_image_picker_web.dart"
Cohesion: 0.13
Nodes (13): any, bytes, camera, complete, images, input, _pickImages, pickPropertyImageImpl (+5 more)

### Community 77 - "property_tag_selector.dart"
Cohesion: 0.14
Nodes (13): build, catalog, createState, edit, failed, initState, isAdmin, load (+5 more)

### Community 79 - "home_brand_content_entity.dart"
Cohesion: 0.14
Nodes (12): about, contact, email, mission, phone, values, videoProvider, videoThumbnailUrl (+4 more)

### Community 80 - "auth_datasource.dart"
Cohesion: 0.15
Nodes (9): AuthDatasource, clearAccessToken, getAccessToken, getCurrentUserProfile, _restClient, saveAccessToken, signInWithEmailAndPassword, dio (+1 more)

### Community 81 - "win32_window.cpp"
Cohesion: 0.16
Nodes (5): Win32Window::Show(), EnableNonClientDpiScaling, WindowClassRegistrar, class_registered_, instance_

### Community 82 - "utils.cpp"
Cohesion: 0.18
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 83 - "property_resume_test.dart"
Cohesion: 0.15
Nodes (3): main, detailJson, main

### Community 84 - "property_segments_repository.dart"
Cohesion: 0.14
Nodes (6): buildPropertySearchUri, datasource, getFeaturedProperties, getHomeBrandContent, resolveSegmentRoute, searchPublishedProperties

### Community 85 - "property_card_image.dart"
Cohesion: 0.13
Nodes (10): build, message, onStock, PropertyDetailError, unavailable, build, coverUrl, _ImageBottomScrim (+2 more)

### Community 86 - "property_search_store.dart"
Cohesion: 0.14
Nodes (13): appendResult, appliedFilters, draftFilters, _errorMessage, initializeFilters, loadingMore, result, setDraftFilters (+5 more)

### Community 87 - "design_system/pubspec.yaml"
Cohesion: 0.14
Nodes (13): dependencies, cached_network_image, cupertino_icons, flutter, flutter_svg, responsive_framework, description, environment (+5 more)

### Community 88 - ".Create"
Cohesion: 0.14
Nodes (8): Scale(), Point, x, y, Size, height, width, Win32Window::Win32Window()

### Community 89 - "state.dart"
Cohesion: 0.15
Nodes (7): controller, dispose, enteredAt, initState, logScreenTime, StatelessController, Store

### Community 90 - "module_injector.dart"
Cohesion: 0.15
Nodes (11): controllers, core, datasources, _getit, _injectionsDispose, internalInjectorHashCode, register, repositories (+3 more)

### Community 91 - "authenticated_user_entity.dart"
Cohesion: 0.15
Nodes (12): email, fromValue, isActive, isAdmin, isBroker, label, name, phone (+4 more)

### Community 92 - "admin_properties_store.dart"
Cohesion: 0.15
Nodes (12): _errorMessage, featured, properties, query, selectedStatus, setError, setFilters, setLoading (+4 more)

### Community 93 - "property_resume_actions.dart"
Cohesion: 0.15
Nodes (11): base, https, number, openPropertyWhatsapp, origin, propertyWhatsappUri, publicSite, shareProperty (+3 more)

### Community 94 - "auth_guard_page.dart"
Cohesion: 0.17
Nodes (11): AuthGuardController, _AccessBlockedPage, AuthGuardPage, _AuthGuardPageState, build, child, createState, initState (+3 more)

### Community 95 - "List"
Cohesion: 0.15
Nodes (8): body, build, DSInfoCard, title, build, children, columns, mainAxisExtent

### Community 96 - "core/pubspec.yaml"
Cohesion: 0.15
Nodes (12): dependencies, dio, flutter, get_it, logger, description, environment, sdk (+4 more)

### Community 97 - "Win32Window"
Cohesion: 0.17
Nodes (6): Win32Window::Destroy(), Win32Window::GetClientArea(), Win32Window, child_content_, quit_on_close_, window_handle_

### Community 98 - "compilerOptions"
Cohesion: 0.17
Nodes (11): compilerOptions, esModuleInterop, forceConsistentCasingInFileNames, module, moduleResolution, outDir, rootDir, skipLibCheck (+3 more)

### Community 99 - "app_navigator.dart"
Cohesion: 0.17
Nodes (7): activeRoutes, addRoute, canPop, navigatorKey, popUntil, removeRoute, Store

### Community 100 - "admin_broker_entity.dart"
Cohesion: 0.17
Nodes (11): AdminBrokerModel, AdminBrokerEntity, CreateBrokerEntity, email, emailConfirmation, id, name, phone (+3 more)

### Community 101 - "property_form_validator.dart"
Cohesion: 0.17
Nodes (11): changedFieldsCount, isValid, _meaningfulDraftContentFields, messages, _normalized, _normalizedList, PropertyFormValidationResult, PropertyFormValidator (+3 more)

### Community 102 - "property_segments_home_store.dart"
Cohesion: 0.17
Nodes (11): brandContent, consumeErrorMessage, _errorMessage, featuredProperties, filters, setError, setFilters, setHomeContent (+3 more)

### Community 104 - "enviroment.dart"
Cohesion: 0.17
Nodes (11): apiBaseUrl, cdcUrl, colorFromHex, configName, debug, firebaseEnv, firebaseNotificationSubscriptionName, fromJson (+3 more)

### Community 106 - "broker_property_model.dart"
Cohesion: 0.18
Nodes (9): BrokerPropertiesPaginationModel, BrokerPropertiesResultModel, BrokerPropertyBrokerModel, BrokerPropertyModel, fromJson, BrokerPropertiesPaginationEntity, BrokerPropertiesResultEntity, BrokerPropertyBrokerEntity (+1 more)

### Community 107 - "authentication_module.dart"
Cohesion: 0.20
Nodes (7): AuthenticationInjector, AuthenticationModule, initialRoute, injector, routes, MainInjector, ModuleInjector

### Community 108 - "login_page.dart"
Cohesion: 0.20
Nodes (8): LoginController, build, createState, initState, LoginPage, _LoginPageState, routeData, ModuleRouteData

### Community 109 - "property_tag_catalog.dart"
Cohesion: 0.18
Nodes (9): _client, description, fromJson, isActive, load, PropertyTag, PropertyTagCatalog, save (+1 more)

### Community 110 - "design_tokens.dart"
Cohesion: 0.18
Nodes (9): DSRadius, DSSpacing, lg, md, sm, xl, xs, xxl (+1 more)

### Community 111 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 112 - "protected_route_access_entity.dart"
Cohesion: 0.20
Nodes (8): AuthenticatedUserEntity, canAccess, message, ProtectedRouteAccessEntity, ProtectedRouteAccessStatus, redirectRoute, status, user

### Community 113 - "ds_youtube_embed.dart"
Cohesion: 0.20
Nodes (7): build, DSYoutubeEmbed, _extractYoutubeVideoId, fallback, title, _toYoutubeEmbedUrl, url

### Community 114 - "FlutterWindow::OnCreate"
Cohesion: 0.22
Nodes (3): RegisterPlugins(), FlutterWindow::OnCreate(), Win32Window::OnCreate()

### Community 115 - "FlutterWindow"
Cohesion: 0.20
Nodes (5): FlutterWindow::OnDestroy(), FlutterWindow, flutter_controller_, project_, Win32Window::OnDestroy()

### Community 116 - "user_profile_repository.dart"
Cohesion: 0.20
Nodes (6): datasource, getProfile, _profile, updatePassword, updateProfile, uploadAvatar

### Community 117 - "session_store.dart"
Cohesion: 0.20
Nodes (8): clearSession, hasSession, initialized, instance, setLoading, setSession, state, user

### Community 118 - "login_form.dart"
Cohesion: 0.22
Nodes (9): build, createState, dispose, _emailController, isLoading, LoginForm, _LoginFormState, _passwordController (+1 more)

### Community 119 - "StatefulWidget"
Cohesion: 0.20
Nodes (9): AdminBrokerEditDialog, _AdminBrokerEditDialogState, PropertyFormController, _MediaFileImage, _MediaFileImageState, _PropertyFormContent, _PropertyFormContentState, PropertyFormPage (+1 more)

### Community 120 - "property_form_store.dart"
Cohesion: 0.20
Nodes (9): brokers, _errorMessage, property, PropertyFormStore, setBrokers, setError, setLoading, setProperty (+1 more)

### Community 121 - "package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart"
Cohesion: 0.20
Nodes (4): DSResponsiveFieldGrid, main, main, _result

### Community 124 - "dual_response.dart"
Cohesion: 0.36
Nodes (5): error, ErrorResponse, getResult, success, SuccessResponse

### Community 125 - "env_abstract.dart"
Cohesion: 0.22
Nodes (7): dev, EnvAbstract, hom, isOnDebug, isProd, prod, resolve

### Community 126 - "Failure"
Cohesion: 0.22
Nodes (6): AdminBrokersFailure, BrokerPropertiesFailure, message, HomeShowcaseFailure, message, PropertyDetailFailure

### Community 127 - "admin_review_endpoints.dart"
Cohesion: 0.22
Nodes (7): adminApproveProperty, adminNotificationRead, adminNotifications, adminProperties, adminPropertyRevisions, adminRejectProperty, adminReviewProperties

### Community 128 - "broker_properties_endpoints.dart"
Cohesion: 0.22
Nodes (8): adminProperties, adminProperty, adminPropertyStatus, brokerProperties, BrokerPropertiesEndpoints, brokerProperty, brokerPropertyStatus, BrokerPropertiesDatasource

### Community 129 - "get_property_detail_use_case.dart"
Cohesion: 0.22
Nodes (5): fromJson, PropertyDetailModel, call, GetPropertyDetailUseCase, repository

### Community 130 - "auth_repository.dart"
Cohesion: 0.22
Nodes (5): datasource, getCurrentSession, signInWithEmailAndPassword, signOut, watchCurrentSession

### Community 131 - "login_store.dart"
Cohesion: 0.22
Nodes (8): consumeErrorMessage, _errorMessage, LoginStore, setError, setIdle, setLoading, setSuccess, state

### Community 132 - "module_window_widget.dart"
Cohesion: 0.25
Nodes (6): build, builder, createState, initState, ModuleWindow, _ModuleWindowState

### Community 133 - "Controller"
Cohesion: 0.22
Nodes (6): Controller, dispose, CustomCoreLogger, initializeObject, Module, _Routes

### Community 134 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.22
Nodes (4): main, admin, broker, main

### Community 135 - "State"
Cohesion: 0.31
Nodes (6): didChangeDependencies, onPopGestureInProgress, PopGestureMixin, StateController, StatePage, StateStore

### Community 136 - "layout_breakpoints.dart"
Cohesion: 0.22
Nodes (6): defaults, desktop, DSBreakpoints, mobile, tablet, ultra

### Community 137 - "seed.ts"
Cohesion: 0.29
Nodes (6): featuredProperties, main(), now, prisma, propertyTags, brandContent

### Community 138 - "jwt.ts"
Cohesion: 0.43
Nodes (7): encodeBase64Url(), JwtPayload, parseJson(), safeEqual(), sign(), signAccessToken(), verifyAccessToken()

### Community 139 - "dart:async"
Cohesion: 0.25
Nodes (6): ClickRecorder, ExternalLauncher, ExternalLinkService, launch, open, record

### Community 140 - "_"
Cohesion: 0.25
Nodes (7): _, _apiErrorMessage, ApiFailureMapper, _debugLog, fromDioException, _looksLikeCorsOrBrowserNetworkError, unexpectedResponse

### Community 141 - "package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart"
Cohesion: 0.25
Nodes (5): fromJson, HomeBrandContentModel, HomeContactModel, HomeBrandContentEntity, HomeContactEntity

### Community 142 - "property_segment_route_model.dart"
Cohesion: 0.25
Nodes (5): fromJson, PropertySegmentRouteModel, canNavigate, PropertySegmentRouteEntity, route

### Community 143 - "admin_brokers_store.dart"
Cohesion: 0.25
Nodes (7): AdminBrokersStore, brokers, _errorMessage, setBrokers, setError, setLoading, state

### Community 144 - "property_resume_controller.dart"
Cohesion: 0.25
Nodes (5): dispose, getProperty, load, _request, store

### Community 145 - "auth_guard_store.dart"
Cohesion: 0.25
Nodes (7): AuthGuardStore, message, setAllowed, setBlocked, setLoading, state, user

### Community 146 - "AppState"
Cohesion: 0.29
Nodes (7): AppState, AppStateEnum, isError, isIdle, isLoading, isSuccess, updateState

### Community 147 - "bool get"
Cohesion: 0.29
Nodes (4): DSLayoutContextExtension, isDesktopLayout, isMobileLayout, isTabletLayout

### Community 148 - "property_resume_state_test.dart"
Cohesion: 0.29
Nodes (3): main, pending, status

### Community 149 - "ds_youtube_embed_web.dart"
Cohesion: 0.29
Nodes (3): buildYoutubeEmbed, _registeredViewTypes, viewType

### Community 150 - "admin_notifications_datasource.dart"
Cohesion: 0.29
Nodes (5): AdminNotificationsDatasource, getNotifications, markRead, _restClient, AdminReviewEndpoints

### Community 151 - "property_resume_store.dart"
Cohesion: 0.29
Nodes (6): dispose, error, property, PropertyResumeStore, state, unavailable

### Community 152 - "property_tag_chips.dart"
Cohesion: 0.29
Nodes (6): build, isOverlay, overlay, PropertyTagChips, _propertyTagLabel, tags

### Community 153 - "property_photo.dart"
Cohesion: 0.33
Nodes (4): build, fit, PropertyPhoto, url

### Community 154 - "cancelable_request.dart"
Cohesion: 0.33
Nodes (4): call, cancel, CancelableRequest, _token

### Community 155 - "property_detail_repository.dart"
Cohesion: 0.33
Nodes (4): client, message, PropertyDetailRepository, unavailable

### Community 156 - "Map"
Cohesion: 0.33
Nodes (4): facts, images, price, PropertyDetailEntity

### Community 157 - "property_search_formatters.dart"
Cohesion: 0.33
Nodes (5): buffer, formatPrice, formatPropertyLocation, tagLabel, text

### Community 158 - "ds_weighted_field.dart"
Cohesion: 0.33
Nodes (4): build, builder, DSWeightedField, flex

### Community 161 - "property_image_picker_types.dart"
Cohesion: 0.40
Nodes (4): contentBase64, fileName, mimeType, PickedPropertyImage

### Community 163 - "data_source_response.dart"
Cohesion: 0.40
Nodes (3): data, DataSourceResponse, hasSuccess

### Community 164 - "rest_env.dart"
Cohesion: 0.50
Nodes (4): baseUrl, enviromentName, RestEnv, RestEnvAbstract

### Community 165 - "binds_arguments.dart"
Cohesion: 0.40
Nodes (3): _arguments, instance, remove

## Knowledge Gaps
- **1713 isolated node(s):** `_activeImageUrls`, `_areaController`, `areaM2`, `_bathrooms`, `_bedrooms` (+1708 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 2141 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **29 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Win32Window` to `String?`, `win32_window.cpp`, `FlutterWindow::OnCreate`, `FlutterWindow`, `.Create`, `.MessageHandler`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `_activeImageUrls`, `_areaController`, `areaM2` to the rest of the system?**
  _1713 weakly-connected nodes found - possible missing edges._
- **Should `property_form_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.021052631578947368 - nodes in this community are weakly interconnected._
- **Why does `_` connect `_` to `package:dio/dio.dart`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **Should `StatelessWidget` be split into smaller, more focused modules?**
  _Cohesion score 0.029411764705882353 - nodes in this community are weakly interconnected._
- **Why does `AdminBrokerEntity` connect `admin_broker_entity.dart` to `admin_broker_edit_dialog.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Should `authentication_injector.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.040068201193520885 - nodes in this community are weakly interconnected._