import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/failures/home_showcase_failure.dart';
import 'package:imobiliaria/app/data/property_segments/failures/segment_route_failure.dart';
import 'package:imobiliaria/app/data/property_segments/models/featured_property_model.dart';
import 'package:imobiliaria/app/data/property_segments/models/home_brand_content_model.dart';
import 'package:imobiliaria/app/data/property_segments/models/property_segment_route_model.dart';
import 'package:imobiliaria/app/data/property_segments/models/search_property_model.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsRepository {
  PropertySegmentsRepository({required this.datasource});

  final PropertySegmentsDatasource datasource;

  Future<DualResponse<Failure, PropertySegmentRouteModel>> resolveSegmentRoute({
    required String targetRoute,
  }) async {
    try {
      final response = await datasource.resolveSegmentRoute(
        targetRoute: targetRoute,
      );
      if (response.hasSuccess) {
        return SuccessResponse<Failure, PropertySegmentRouteModel>(
          PropertySegmentRouteModel.fromJson(response.data),
        );
      }
      return ErrorResponse<Failure, PropertySegmentRouteModel>(
        SegmentRouteFailure(),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, PropertySegmentRouteModel>(
        SegmentRouteFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, PropertySegmentRouteModel>(
        SegmentRouteFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, Uri>> buildPropertySearchUri({
    required PropertySearchFiltersEntity filters,
  }) async {
    try {
      return SuccessResponse<Failure, Uri>(
        Uri(path: '/estoque', queryParameters: filters.toQueryParameters()),
      );
    } catch (_) {
      return ErrorResponse<Failure, Uri>(HomeShowcaseFailure());
    }
  }

  Future<DualResponse<Failure, List<FeaturedPropertyEntity>>>
  getFeaturedProperties() async {
    try {
      final response = await datasource.getFeaturedProperties();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, List<FeaturedPropertyEntity>>(
          HomeShowcaseFailure(),
        );
      }

      return SuccessResponse<Failure, List<FeaturedPropertyEntity>>(
        response.data.map(FeaturedPropertyModel.fromJson).toList(),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, List<FeaturedPropertyEntity>>(
        HomeShowcaseFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, List<FeaturedPropertyEntity>>(
        HomeShowcaseFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, HomeBrandContentEntity>>
  getHomeBrandContent() async {
    try {
      final response = await datasource.getHomeBrandContent();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, HomeBrandContentEntity>(
          HomeShowcaseFailure(),
        );
      }

      return SuccessResponse<Failure, HomeBrandContentEntity>(
        HomeBrandContentModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, HomeBrandContentEntity>(
        HomeShowcaseFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, HomeBrandContentEntity>(
        HomeShowcaseFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, PropertySearchResultEntity>>
  searchPublishedProperties({
    required Map<String, String> queryParameters,
  }) async {
    try {
      final response = await datasource.searchPublishedProperties(
        queryParameters: queryParameters,
      );
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, PropertySearchResultEntity>(
          HomeShowcaseFailure(),
        );
      }

      return SuccessResponse<Failure, PropertySearchResultEntity>(
        PropertySearchResultModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, PropertySearchResultEntity>(
        HomeShowcaseFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, PropertySearchResultEntity>(
        HomeShowcaseFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
