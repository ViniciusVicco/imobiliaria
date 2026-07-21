import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/users/datasources/user_profile_datasource.dart';
import 'package:imobiliaria/app/data/users/failures/user_profile_failure.dart';
import 'package:imobiliaria/app/data/users/models/user_profile_model.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:legend_core/legend_core.dart';

class UserProfileRepository {
  UserProfileRepository({required this.datasource});

  final UserProfileDatasource datasource;

  Future<DualResponse<Failure, UserProfileEntity>> getProfile() {
    return _profile(() => datasource.getProfile());
  }

  Future<DualResponse<Failure, UserProfileEntity>> updateProfile(
    UserProfileUpdateEntity profile,
  ) {
    return _profile(() => datasource.updateProfile(profile.toJson()));
  }

  Future<DualResponse<Failure, UserProfileEntity>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _profile(
      () => datasource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      ),
    );
  }

  Future<DualResponse<Failure, UserProfileEntity>> uploadAvatar({
    required String fileName,
    required String mimeType,
    required String contentBase64,
  }) {
    return _profile(
      () => datasource.uploadAvatar(
        fileName: fileName,
        mimeType: mimeType,
        contentBase64: contentBase64,
      ),
    );
  }

  Future<DualResponse<Failure, UserProfileEntity>> _profile(
    Future<DataSourceResponse<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, UserProfileEntity>(UserProfileFailure());
      }

      return SuccessResponse<Failure, UserProfileEntity>(
        UserProfileModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, UserProfileEntity>(
        UserProfileFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, UserProfileEntity>(
        UserProfileFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
