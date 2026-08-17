import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/auth_guard_controller.dart';
import 'package:legend_core/legend_core.dart';

class AuthGuardPage extends StatefulWidget {
  const AuthGuardPage({
    super.key,
    required this.requiredRole,
    required this.requestedRoute,
    required this.child,
  });

  final UserRole requiredRole;
  final String requestedRoute;
  final Widget child;

  @override
  State<AuthGuardPage> createState() => _AuthGuardPageState();
}

class _AuthGuardPageState
    extends StateController<MainModule, AuthGuardPage, AuthGuardController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureAccess(
        requiredRole: widget.requiredRole,
        requestedRoute: widget.requestedRoute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppStateEnum>(
      valueListenable: controller.store.state,
      builder: (context, state, child) {
        if (state == AppStateEnum.hasSuccess) {
          return widget.child;
        }

        if (state == AppStateEnum.hasError) {
          return _AccessBlockedPage(
            message: controller.store.message ?? 'Acesso bloqueado.',
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _AccessBlockedPage extends StatelessWidget {
  const _AccessBlockedPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso restrito')),
      body: DSPageLayoutContainer(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DSColors.surfaceContainer,
              borderRadius: DSRadius.md,
              border: Border.all(color: DSColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: DSColors.primary,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
