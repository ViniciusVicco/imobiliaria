import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final void Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading) return;
    widget.onSubmit(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Entrar', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: DSSpacing.sm),
              Text(
                'Use seu email e senha de corretor ou administrador.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DSColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              TextField(
                controller: _emailController,
                enabled: !widget.isLoading,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: DSRadius.sm),
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              TextField(
                controller: _passwordController,
                enabled: !widget.isLoading,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(borderRadius: DSRadius.sm),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: DSSpacing.lg),
              FilledButton.icon(
                onPressed: widget.isLoading ? null : _submit,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
