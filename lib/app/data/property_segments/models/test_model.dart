import 'package:imobiliaria/app/domain/property_segments/entities/test_entity.dart';

class TestModel extends TestEntity {
  TestModel({required super.isWorking, required super.route});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      isWorking: json['isWorking'] as bool,
      route: json['route'] as String,
    );
  }
}
