abstract final class CustomAssets {
  static const Logos logo = Logos();
  static const IconAssets icons = IconAssets();
  static const MockAssets mocks = MockAssets();
}

class Logos {
  const Logos();

  String get logo => 'assets/logos/seleta_logo.png';
}

class IconAssets {
  const IconAssets();

  String get selettaIcon => 'assets/icons/seletta-icon.svg';
}

class MockAssets {
  const MockAssets();

  String get featuredProperties => 'assets/mocks/featured_properties.json';
  String get homeBrandContent => 'assets/mocks/home_brand_content.json';
}
