import 'package:dio/dio.dart';
import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_detail_entity.dart';
import '../models/property_detail_model.dart';

class PropertyDetailFailure extends Failure {
  PropertyDetailFailure({this.unavailable = false});
  final bool unavailable;
  @override
  String get message => unavailable
      ? 'Esta propriedade está indisponível para visualização ou já foi comprada.'
      : 'Não foi possível carregar o imóvel. Tente novamente.';
}

class PropertyDetailRepository {
  PropertyDetailRepository({required this.client});
  final RestClient client;
  Future<DualResponse<PropertyDetailFailure, PropertyDetailEntity>> get(
    String id,
  ) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/properties/${Uri.encodeComponent(id)}',
      );
      if (response.statusCode == 200 && response.data != null) {
        return SuccessResponse(PropertyDetailModel.fromJson(response.data!));
      }
      return ErrorResponse(
        PropertyDetailFailure(unavailable: response.statusCode == 404),
      );
    } on DioException catch (error) {
      return ErrorResponse(
        PropertyDetailFailure(unavailable: error.response?.statusCode == 404),
      );
    } catch (_) {
      return ErrorResponse(PropertyDetailFailure());
    }
  }
}
