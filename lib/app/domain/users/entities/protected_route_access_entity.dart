import 'authenticated_user_entity.dart';

class ProtectedRouteAccessEntity {
  const ProtectedRouteAccessEntity({
    required this.status,
    this.redirectRoute,
    this.message,
    this.user,
  });

  final ProtectedRouteAccessStatus status;
  final String? redirectRoute;
  final String? message;
  final AuthenticatedUserEntity? user;

  bool get canAccess => status == ProtectedRouteAccessStatus.allowed;
}

enum ProtectedRouteAccessStatus { allowed, redirect, blocked }
