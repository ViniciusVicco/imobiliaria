import 'package:legend_core/legend_core.dart';

class UserProfileDatasource {
  UserProfileDatasource({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  Future<DataSourceResponse<Map<String, dynamic>>> getProfile() async {
    final response = await _restClient.get<Map<String, dynamic>>('/me');
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      '/me/profile',
      data: data,
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      '/me/password',
      data: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirmation': newPasswordConfirmation,
      },
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> uploadAvatar({
    required String fileName,
    required String mimeType,
    required String contentBase64,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      '/me/avatar',
      data: <String, dynamic>{
        'fileName': fileName,
        'mimeType': mimeType,
        'contentBase64': contentBase64,
      },
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }
}
