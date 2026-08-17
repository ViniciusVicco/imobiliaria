import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_layout.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersPage extends StatefulWidget {
  const AdminBrokersPage({super.key});

  @override
  State<AdminBrokersPage> createState() => _AdminBrokersPageState();
}

class _AdminBrokersPageState
    extends StateController<MainModule, AdminBrokersPage, AdminBrokersController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBrokers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Gerenciar corretores',
      currentRoute: MainRoutes.adminUsers,
      child: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Corretores',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openCreateBrokerDialog(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Criar novo corretor'),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.lg),
                Expanded(
                  child: switch (state) {
                    AppStateEnum.isLoading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    AppStateEnum.hasError => _AdminBrokersErrorState(
                      message:
                          controller.store.errorMessage ??
                          'Nao foi possivel carregar os corretores.',
                      onRetry: controller.loadBrokers,
                    ),
                    AppStateEnum.hasSuccess => _AdminBrokersList(
                      brokers: controller.store.brokers,
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreateBrokerDialog(BuildContext context) async {
    final wasCreated = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateBrokerDialog(controller: controller),
    );

    if (wasCreated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corretor criado e convite enviado.')),
      );
    }
  }
}

class _AdminBrokersList extends StatelessWidget {
  const _AdminBrokersList({required this.brokers});

  final List<AdminBrokerEntity> brokers;

  @override
  Widget build(BuildContext context) {
    if (brokers.isEmpty) {
      return const Center(
        child: Text('Nenhum corretor cadastrado.'),
      );
    }

    return ListView.separated(
      itemCount: brokers.length,
      separatorBuilder: (context, index) => const SizedBox(height: DSSpacing.sm),
      itemBuilder: (context, index) {
        final broker = brokers[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DSColors.surfaceContainer,
            borderRadius: DSRadius.md,
            border: Border.all(color: DSColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Row(
              children: <Widget>[
                const Icon(Icons.badge_outlined, color: DSColors.primary),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        broker.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        '${broker.email} | ${broker.phone.isEmpty ? 'Sem telefone' : broker.phone}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DSColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Text(
                  '${broker.totalProperties} imoveis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminBrokersErrorState extends StatelessWidget {
  const _AdminBrokersErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: DSColors.primary, size: 40),
          const SizedBox(height: DSSpacing.md),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: DSSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _CreateBrokerDialog extends StatefulWidget {
  const _CreateBrokerDialog({required this.controller});

  final AdminBrokersController controller;

  @override
  State<_CreateBrokerDialog> createState() => _CreateBrokerDialogState();
}

class _CreateBrokerDialogState extends State<_CreateBrokerDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailConfirmationController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailConfirmationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar novo corretor'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: DSSpacing.sm),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: DSSpacing.sm),
            TextField(
              controller: _emailConfirmationController,
              decoration: const InputDecoration(labelText: 'Confirmar e-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: DSSpacing.sm),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'A senha temporaria sera gerada pelo sistema e enviada por e-mail.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Criar corretor'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final wasCreated = await widget.controller.createBroker(
      name: _nameController.text,
      email: _emailController.text,
      emailConfirmation: _emailConfirmationController.text,
      phone: _phoneController.text,
    );

    if (wasCreated && mounted) {
      Navigator.of(context).pop(true);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.store.errorMessage ??
                'Nao foi possivel criar o corretor.',
          ),
        ),
      );
    }
  }
}
