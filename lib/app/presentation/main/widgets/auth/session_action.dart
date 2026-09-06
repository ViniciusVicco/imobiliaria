import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/session_controller.dart';
import 'package:legend_core/legend_core.dart';

class SessionAction extends StatefulWidget {
  const SessionAction({super.key, this.compact = false});

  final bool compact;

  @override
  State<SessionAction> createState() => _SessionActionState();
}

class _SessionActionState
    extends StateController<MainModule, SessionAction, SessionController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppStateEnum>(
      valueListenable: controller.store.state,
      builder: (context, state, child) {
        final user = controller.store.user;
        final isLoading = state == AppStateEnum.isLoading;
        if (isLoading) {
          return _loadingButton();
        }
        if (user == null) {
          return _loginButton();
        }
        return _authenticatedButton(user);
      },
    );
  }

  Widget _loadingButton() {
    return OutlinedButton(
      onPressed: null,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _loginButton() {
    return OutlinedButton.icon(
      onPressed: () =>
          Module.get<MainModule>().navigator.pushNamed(MainRoutes.login),
      icon: const Icon(Icons.login),
      label: const Text('Entrar'),
    );
  }

  Widget _authenticatedButton(AuthenticatedUserEntity user) {
    final label = user.name.trim().isEmpty ? 'Minha conta' : user.name.trim();
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'dashboard') {
          Module.get<MainModule>().navigator.pushNamed(
            user.isAdmin ? MainRoutes.admin : MainRoutes.broker,
          );
        } else if (value == 'logout') {
          _confirmLogout();
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'dashboard',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.dashboard_outlined),
            title: Text('Acessar painel'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text('Sair de $label'),
          ),
        ),
      ],
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person),
          label: Text(widget.compact ? 'Minha conta' : label),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da aplicação?'),
        content: const Text('Sua sessão será encerrada neste dispositivo.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    final errorMessage = await controller.logout();
    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
