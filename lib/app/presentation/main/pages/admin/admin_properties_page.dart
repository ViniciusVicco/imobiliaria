import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_layout.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_properties_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/widgets/property_management_widgets.dart';
import 'package:legend_core/legend_core.dart';

class AdminPropertiesPage extends StatefulWidget {
  const AdminPropertiesPage({super.key});

  @override
  State<AdminPropertiesPage> createState() => _AdminPropertiesPageState();
}

class _AdminPropertiesPageState
    extends
        StateController<
          MainModule,
          AdminPropertiesPage,
          AdminPropertiesController
        > {
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProperties();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Gerenciar imoveis',
      currentRoute: MainRoutes.adminProperties,
      child: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Imoveis',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: DSSpacing.md),
                Wrap(
                  spacing: DSSpacing.md,
                  runSpacing: DSSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    PropertyStatusTabs(
                      selectedStatus: controller.store.selectedStatus,
                      onChanged: (status) =>
                          controller.loadProperties(status: status),
                    ),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _queryController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          suffixIcon: IconButton(
                            tooltip: 'Buscar',
                            onPressed: () => controller.loadProperties(
                              query: _queryController.text,
                            ),
                            icon: const Icon(Icons.search),
                          ),
                        ),
                        onSubmitted: (value) =>
                            controller.loadProperties(query: value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                Expanded(
                  child: switch (state) {
                    AppStateEnum.isLoading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    AppStateEnum.hasError => PropertyManagementErrorState(
                      message:
                          controller.store.errorMessage ??
                          'Nao foi possivel carregar os imoveis.',
                      onRetry: controller.loadProperties,
                    ),
                    AppStateEnum.hasSuccess => PropertyManagementGrid(
                      properties: controller.store.properties,
                      showBroker: true,
                      onCreate: _createDraft,
                      onEdit: controller.openEditForm,
                      onMarkSold: (property) => _confirmStatus(
                        property: property,
                        status: 'sold',
                        message: 'Sinalizar venda deste imovel?',
                      ),
                      onDeactivate: (property) => _confirmStatus(
                        property: property,
                        status: 'inactive',
                        message: 'Remover este imovel da vitrine publica?',
                      ),
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

  Future<void> _createDraft() async {
    final wasCreated = await controller.createDraftAndOpenForm();
    if (!wasCreated && mounted && controller.store.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.store.errorMessage!)),
      );
    }
  }

  Future<void> _confirmStatus({
    required BrokerPropertyEntity property,
    required String status,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar acao'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final wasUpdated = await controller.updateStatus(
      id: property.id,
      status: status,
    );
    if (wasUpdated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado.')),
      );
    }
  }
}
