import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/authentication/authentication_module.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_controller.dart';
import 'package:legend_core/legend_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.routeData});

  final ModuleRouteData? routeData;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState
    extends StateController<AuthenticationModule, LoginPage, LoginController> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resumeValidSession(
        redirectRoute: widget.routeData?.queryParameters['redirect'],
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  });
                }

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: DSColors.surfaceContainer,
                    borderRadius: DSRadius.md,
                    border: Border.all(color: DSColors.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    child: AutofillGroup(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Entrar',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: DSSpacing.sm),
                          Text(
                            'Use seu email e senha de corretor ou administrador.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: DSColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: DSSpacing.lg),
                          TextField(
                            controller: _emailController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const <String>[
                              AutofillHints.email,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: DSRadius.sm,
                              ),
                            ),
                          ),
                          const SizedBox(height: DSSpacing.md),
                          TextField(
                            controller: _passwordController,
                            enabled: !isLoading,
                            obscureText: true,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(
                                borderRadius: DSRadius.sm,
                              ),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: DSSpacing.lg),
                          FilledButton.icon(
                            onPressed: isLoading ? null : _submit,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: const Text('Entrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() {
    return controller.submit(
      email: _emailController.text,
      password: _passwordController.text,
      redirectRoute: widget.routeData?.queryParameters['redirect'],
    );
  }
}
