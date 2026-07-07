import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_properties_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/widgets/property_management_widgets.dart';
import 'package:legend_core/legend_core.dart';

class BrokerPropertiesPage extends StatefulWidget {
  const BrokerPropertiesPage({super.key});

  @override
  State<BrokerPropertiesPage> createState() => _BrokerPropertiesPageState();
}

class _BrokerPropertiesPageState
    extends
        StateController<
          MainModule,
          BrokerPropertiesPage,
          BrokerPropertiesController
        > {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus imoveis')),
      body: ValueListenableBuilder<AppStateEnum>(
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
                        'Meus imoveis',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _createDraft,
                      icon: const Icon(Icons.add_home_work_outlined),
                      label: const Text('Novo imovel'),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                PropertyStatusTabs(
                  selectedStatus: controller.store.selectedStatus,
                  onChanged: (status) =>
                      controller.loadProperties(status: status),
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
                      loadMediaFile: controller.loadMediaFile,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(controller.store.errorMessage!)));
    }
  }

  Future<void> _openForm([BrokerPropertyEntity? property]) async {
    final wasSaved = await showDialog<bool>(
      context: context,
      builder: (context) => PropertyFormDialog(
        title: property == null ? 'Novo imovel' : 'Editar imovel',
        initialValue: property?.toForm() ?? BrokerPropertyFormEntity.empty(),
        onSave: (form) =>
            controller.saveProperty(id: property?.id, property: form),
      ),
    );

    if (wasSaved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Imovel salvo.')));
    } else if (mounted && controller.store.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(controller.store.errorMessage!)));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status atualizado.')));
    }
  }
}
