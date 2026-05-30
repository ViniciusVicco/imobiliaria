import 'package:imobiliaria/app/domain/property_segments/usecases/search_published_properties_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchController extends Controller {
  PropertySearchController({
    required this.store,
    required this.searchPublishedProperties,
  });

  final PropertySearchStore store;
  final SearchPublishedPropertiesUseCase searchPublishedProperties;
  Map<String, String> _lastQueryParameters = const <String, String>{};

  Future<void> search(Map<String, String> queryParameters) async {
    _lastQueryParameters = Map<String, String>.from(queryParameters);
    store.setLoading();

    final result = await searchPublishedProperties.call(
      queryParameters: _lastQueryParameters,
    );

    result.getResult(
      onSuccess: store.setResult,
      onError: (error) => store.setError(error.message),
    );
  }

  Future<void> retry() => search(_lastQueryParameters);
}
