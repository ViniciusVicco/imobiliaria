import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/authentication/authentication_module.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_controller.dart';
import 'package:legend_core/legend_core.dart';

import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.routeData});

  final ModuleRouteData? routeData;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState
    extends StateController<AuthenticationModule, LoginPage, LoginController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resumeValidSession(
        redirectRoute: widget.routeData?.queryParameters['redirect'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso restrito')),
      body: DSPageLayoutContainer(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ValueListenableBuilder<AppStateEnum>(
              valueListenable: controller.store.state,
              builder: (context, state, child) {
                final isLoading = state == AppStateEnum.isLoading;
                final errorMessage = state == AppStateEnum.hasError
                    ? controller.store.consumeErrorMessage()
                    : null;

                if (errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(errorMessage)));
                  });
                }

                return LoginForm(
                  isLoading: isLoading,
                  onSubmit: (email, password) => controller.submit(
                    email: email,
                    password: password,
                    redirectRoute:
                        widget.routeData?.queryParameters['redirect'],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
