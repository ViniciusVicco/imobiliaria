import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
      final credential = await datasource.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return ErrorResponse<Failure, AuthenticatedUserEntity>(
          AuthFailure('Nao foi possivel carregar o usuario autenticado.'),
        );
      }

      return _buildSession(firebaseUser);
    } on FirebaseAuthException catch (error) {
      return ErrorResponse<Failure, AuthenticatedUserEntity>(
        AuthFailure(_mapFirebaseAuthMessage(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, AuthenticatedUserEntity>(AuthFailure());
    }
  }

  Future<DualResponse<Failure, AuthenticatedUserEntity?>>
  getCurrentSession() async {
    try {
      final firebaseUser = datasource.currentUser;
      if (firebaseUser == null) {
        return SuccessResponse<Failure, AuthenticatedUserEntity?>(null);
      }

      final result = await _buildSession(firebaseUser);
      return _mapNullableSessionResponse(result);
    } catch (_) {
      return ErrorResponse<Failure, AuthenticatedUserEntity?>(AuthFailure());
    }
  }

  Stream<DualResponse<Failure, AuthenticatedUserEntity?>>
  watchCurrentSession() async* {
    await for (final firebaseUser in datasource.authStateChanges()) {
      if (firebaseUser == null) {
        yield SuccessResponse<Failure, AuthenticatedUserEntity?>(null);
        continue;
      }

      final result = await _buildSession(firebaseUser);
      yield _mapNullableSessionResponse(result);
    }
  }

  Future<DualResponse<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return SuccessResponse<Failure, void>(null);
    } catch (_) {
      return ErrorResponse<Failure, void>(
        AuthFailure('Nao foi possivel sair da conta agora.'),
      );
    }
  }

  Future<DualResponse<Failure, AuthenticatedUserEntity>> _buildSession(
    User firebaseUser,
  ) async {
    try {
      final profile = await datasource.getUserProfile(firebaseUser.uid);
      if (!profile.exists) {
        return ErrorResponse<Failure, AuthenticatedUserEntity>(
          AuthFailure('Perfil de acesso nao encontrado.'),
        );
      }

      return SuccessResponse<Failure, AuthenticatedUserEntity>(
        AuthenticatedUserModel.fromFirebase(
          firebaseUser: firebaseUser,
          profile: profile,
        ),
      );
    } catch (_) {
      return ErrorResponse<Failure, AuthenticatedUserEntity>(
        AuthFailure('Nao foi possivel carregar o perfil de acesso.'),
      );
    }
  }

  DualResponse<Failure, AuthenticatedUserEntity?> _mapNullableSessionResponse(
    DualResponse<Failure, AuthenticatedUserEntity> result,
  ) {
    late final DualResponse<Failure, AuthenticatedUserEntity?> response;
    result.getResult(
      onSuccess: (user) {
        response = SuccessResponse<Failure, AuthenticatedUserEntity?>(user);
      },
      onError: (error) {
        response = ErrorResponse<Failure, AuthenticatedUserEntity?>(error);
      },
    );
    return response;
  }

  String _mapFirebaseAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Informe um email valido.',
      'user-disabled' => 'Este usuario esta desativado.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email ou senha invalidos.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um momento e tente novamente.',
      _ => 'Nao foi possivel autenticar com esses dados.',
    };
  }
}
