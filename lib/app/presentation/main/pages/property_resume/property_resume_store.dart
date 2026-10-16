import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_detail_entity.dart';

class PropertyResumeStore extends Store {
  final AppState state = AppState();
  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  PropertyDetailEntity? property;
  String? error;
  bool unavailable = false;
}
