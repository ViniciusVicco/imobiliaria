mixin class PropertySegmentsEndpoints {
  String get homeBaseUrl => '/home';
  String get propertiesBaseUrl => '/properties';
  String get featuredProperties => '$homeBaseUrl/featured-properties';
  String get brandContent => '$homeBaseUrl/brand-content';
  String get propertiesSearch => '$propertiesBaseUrl/search';
}
