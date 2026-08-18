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
  const AdminPropertiesPage({super.key, this.reviewOnly = false});

  final bool reviewOnly;

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
      controller.loadProperties(
        status: widget.reviewOnly ? 'pending_review' : null,
      );
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
      currentRoute: widget.reviewOnly
          ? MainRoutes.adminReview
          : MainRoutes.adminProperties,
      notificationCount: controller.store.unreadNotifications,
      child: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.reviewOnly ? 'Pendencias de aprovacao' : 'Imoveis',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: DSSpacing.md),
                Wrap(
                  spacing: DSSpacing.md,
                  runSpacing: DSSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    if (!widget.reviewOnly)
                      PropertyStatusTabs(
                        selectedStatus: controller.store.selectedStatus,
                        onChanged: (status) =>
                            controller.loadProperties(status: status),
                      ),
                    if (!widget.reviewOnly)
                      FilterChip(
                        selected: controller.store.featured,
                        label: const Text('Destacados'),
                        avatar: const Icon(Icons.star_outline),
                        onSelected: (value) =>
                            controller.loadProperties(featured: value),
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
                      loadMediaFile: controller.loadMediaFile,
                      onCreate: widget.reviewOnly ? null : _createDraft,
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
                      onApprove: widget.reviewOnly
                          ? (property) => controller.approve(property.id)
                          : null,
                      onReject: widget.reviewOnly
                          ? (property) => _reject(property)
                          : null,
                      onStatusChange: (property, status) => controller
                          .updateStatus(id: property.id, status: status),
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

  Future<void> _reject(BrokerPropertyEntity property) async {
    final noteController = TextEditingController();
    final note = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar imovel'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Observacao para o corretor (opcional)',
            hintText: 'Informe o que precisa ser corrigido.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
    noteController.dispose();
    if (note == null) return;
    final ok = await controller.reject(id: property.id, note: note);
    if (ok && mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imovel devolvido para correcao.')),
      );
  }
}
