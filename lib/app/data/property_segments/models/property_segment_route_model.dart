import 'package:imobiliaria/app/domain/property_segments/entities/property_segment_route_entity.dart';

class PropertySegmentRouteModel extends PropertySegmentRouteEntity {
  PropertySegmentRouteModel({required super.canNavigate, required super.route});

  factory PropertySegmentRouteModel.fromJson(Map<String, dynamic> json) {
    return PropertySegmentRouteModel(
      canNavigate: json['canNavigate'] as bool,
      route: json['route'] as String,
    );
  }
}
