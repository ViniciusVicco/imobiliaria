import 'dart:async';

import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/users/datasources/auth_datasource.dart';
import 'package:imobiliaria/app/data/users/failures/auth_failure.dart';
import 'package:imobiliaria/app/data/users/models/authenticated_user_model.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class AuthRepository {
  AuthRepository({required this.datasource});

  final AuthDatasource datasource;

  Future<DualResponse<Failure, AuthenticatedUserEntity>>
  signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await datasource.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final body = response.data;
      final accessToken = body['accessToken'] as String?;
      final userJson = body['user'] as Map<String, dynamic>?;

      if (!response.hasSuccess || accessToken == null || userJson == null) {
        return ErrorResponse<Failure, AuthenticatedUserEntity>(
          AuthFailure('Nao foi possivel carregar o usuario autenticado.'),
        );
      }

      final tokenResponse = await datasource.saveAccessToken(accessToken);
      if (!tokenResponse.hasSuccess) {
        return ErrorResponse<Failure, AuthenticatedUserEntity>(
          AuthFailure('Nao foi possivel salvar a sessao autenticada.'),
        );
      }

      return SuccessResponse<Failure, AuthenticatedUserEntity>(
        AuthenticatedUserModel.fromJson(userJson),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, AuthenticatedUserEntity>(
        AuthFailure(_mapApiAuthMessage(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, AuthenticatedUserEntity>(AuthFailure());
    }
  }

  Future<DualResponse<Failure, AuthenticatedUserEntity?>>
  getCurrentSession() async {
    try {
      final accessTokenResponse = await datasource.getAccessToken();
      final accessToken = accessTokenResponse.data;
      if (!accessTokenResponse.hasSuccess ||
          accessToken == null ||
          accessToken.isEmpty) {
        return SuccessResponse<Failure, AuthenticatedUserEntity?>(null);
      }

      final response = await datasource.getCurrentUserProfile(
        accessToken: accessToken,
      );
      final body = response.data;

      if (!response.hasSuccess) {
        await datasource.clearAccessToken();
        return SuccessResponse<Failure, AuthenticatedUserEntity?>(null);
      }

      return SuccessResponse<Failure, AuthenticatedUserEntity?>(
        AuthenticatedUserModel.fromJson(body),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403 ||
          error.response?.statusCode == 404) {
        await datasource.clearAccessToken();
        return SuccessResponse<Failure, AuthenticatedUserEntity?>(null);
      }

      return ErrorResponse<Failure, AuthenticatedUserEntity?>(
        AuthFailure('Nao foi possivel carregar o perfil de acesso.'),
      );
    } catch (_) {
      return ErrorResponse<Failure, AuthenticatedUserEntity?>(AuthFailure());
    }
  }

  Stream<DualResponse<Failure, AuthenticatedUserEntity?>>
  watchCurrentSession() async* {
    yield await getCurrentSession();
  }

  Future<DualResponse<Failure, void>> signOut() async {
    try {
      final response = await datasource.clearAccessToken();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, void>(
          AuthFailure('Nao foi possivel sair da conta agora.'),
        );
      }
      return SuccessResponse<Failure, void>(null);
    } catch (_) {
      return ErrorResponse<Failure, void>(
        AuthFailure('Nao foi possivel sair da conta agora.'),
      );
    }
  }

  String _mapApiAuthMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    String errorMessage = '';
    if (data is Map<String, dynamic> && data['error'] != null) {
      errorMessage = data['message'];
    }

    // final errorMessage = data is Map<String, dynamic>
    //   ? (data['error'] as Map<String, dynamic>?) != null?['message'] as String?
    //  : null:false:

    if (errorMessage.isNotEmpty) {
      return errorMessage;
    }

    return switch (statusCode) {
      500 => 'Login ou senha fora do padrão.',
      400 => 'Confira os dados informados.',
      401 => 'Email ou senha invalidos.',
      403 => 'Este usuario esta inativo.',
      _ => 'Nao foi possivel autenticar com esses dados.',
    };
  }
}
