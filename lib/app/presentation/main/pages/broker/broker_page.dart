import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/widgets/property_management_widgets.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/session_action.dart';
import 'package:intl/intl.dart';
import 'package:legend_core/legend_core.dart';

class BrokerPage extends StatefulWidget {
  const BrokerPage({super.key});

  @override
  State<BrokerPage> createState() => _BrokerPageState();
}

class _BrokerPageState
    extends StateController<MainModule, BrokerPage, BrokerController> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    final store = controller.store;
    store.nameController.addListener(store.markFormChanged);
    store.phoneController.addListener(store.markFormChanged);
    store.whatsappController.addListener(store.markFormChanged);
    store.creciController.addListener(store.markFormChanged);
    store.aboutController.addListener(store.markFormChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          if (state == AppStateEnum.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state == AppStateEnum.hasError &&
              controller.store.profile == null) {
            return _ErrorState(
              message:
                  controller.store.errorMessage ??
                  'Nao foi possivel carregar o painel.',
              onRetry: controller.load,
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _TopTabs(
                              selectedIndex: _tabIndex,
                              onChanged: (index) =>
                                  setState(() => _tabIndex = index),
                            ),
                          ),
                          const SizedBox(width: DSSpacing.md),
                          const SessionAction(compact: true),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (_tabIndex == 0)
                        _PropertiesTab(controller: controller)
                      else
                        _ProfileTab(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DSColors.outline)),
      ),
      child: Row(
        children: <Widget>[
          _TopTabButton(
            icon: Icons.real_estate_agent_outlined,
            label: 'MEUS IMOVEIS',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TopTabButton(
            icon: Icons.person_outline,
            label: 'MEU PERFIL',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? DSColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: selected ? DSColors.primary : DSColors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? DSColors.primary : DSColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertiesTab extends StatelessWidget {
  const _PropertiesTab({required this.controller});

  final BrokerController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _PropertiesHeader(controller: controller)),
          ],
        ),
        const SizedBox(height: 44),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: <Widget>[
            _StatusFilterButton(
              label: 'TODOS',
              count: store.statusCounts['all'] ?? 0,
              selected: store.selectedPropertyStatus.isEmpty,
              onTap: () => controller.loadProperties(''),
            ),
            _StatusFilterButton(
              label: 'PUBLICADOS',
              count: store.statusCounts['published'] ?? 0,
              selected: store.selectedPropertyStatus == 'published',
              onTap: () => controller.loadProperties('published'),
            ),
            _StatusFilterButton(
              label: 'PENDENTES',
              count: store.statusCounts['pending_review'] ?? 0,
              selected: store.selectedPropertyStatus == 'pending_review',
              onTap: () => controller.loadProperties('pending_review'),
            ),
            _StatusFilterButton(
              label: 'VENDIDOS',
              count: store.statusCounts['sold'] ?? 0,
              selected: store.selectedPropertyStatus == 'sold',
              onTap: () => controller.loadProperties('sold'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (store.properties.isEmpty)
          const _EmptyPropertiesState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1000
                  ? 3
                  : width >= 680
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.properties.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  mainAxisExtent: columns == 1 ? 540 : 520,
                ),
                itemBuilder: (context, index) => _PropertyCard(
                  property: store.properties[index],
                  loadMediaFile: controller.loadMediaFile,
                  onEdit: () =>
                      controller.openEditProperty(store.properties[index].id),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _PropertiesHeader extends StatelessWidget {
  const _PropertiesHeader({required this.controller});

  final BrokerController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final titleStyle =
            (isCompact
                    ? Theme.of(context).textTheme.headlineLarge
                    : Theme.of(context).textTheme.displaySmall)
                ?.copyWith(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                );
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Painel do Corretor',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie seu portfolio de ativos imobiliarios de alto padrao.',
              maxLines: isCompact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: DSColors.secondary),
            ),
          ],
        );
        final button = FilledButton.icon(
          onPressed: controller.openNewProperty,
          icon: const Icon(Icons.add_home_work_outlined, size: 18),
          label: const Text('CADASTRAR NOVO IMOVEL'),
          style: FilledButton.styleFrom(
            fixedSize: isCompact ? null : const Size(280, 58),
            minimumSize: Size(isCompact ? double.infinity : 280, 58),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[title, const SizedBox(height: 24), button],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: title),
            const SizedBox(width: 32),
            button,
          ],
        );
      },
    );
  }
}

class _StatusFilterButton extends StatelessWidget {
  const _StatusFilterButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(128, 36),
        foregroundColor: selected ? DSColors.primary : DSColors.secondary,
        side: BorderSide(color: selected ? DSColors.primary : DSColors.outline),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
      ),
      child: Text('$label ($count)'),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.loadMediaFile,
    required this.onEdit,
  });

  final BrokerPropertyEntity property;
  final PropertyMediaFileLoader loadMediaFile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isSold = property.status == 'sold';
    final coverMedia = _coverMedia(property);
    final coverUrl = _coverUrl(property, coverMedia);
    return Opacity(
      opacity: isSold ? 0.62 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          border: Border.all(color: DSColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: coverUrl.isEmpty
                      ? const _ImagePlaceholder()
                      : PropertyManagementCoverImage(
                          mediaId: coverMedia?.id ?? '',
                          fallbackUrl: coverUrl,
                          fit: BoxFit.cover,
                          loadMediaFile: loadMediaFile,
                        ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: _StatusBadge(status: property.status),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: DSColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${property.neighborhood}, ${property.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DSColors.secondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _CardMetric(
                          label: 'AREA UTIL',
                          value: '${property.areaM2} m2',
                        ),
                      ),
                      Expanded(
                        child: _CardMetric(
                          label: 'VALOR',
                          value: isSold
                              ? 'Vendido'
                              : NumberFormat.currency(
                                  locale: 'pt_BR',
                                  symbol: 'R\$',
                                  decimalDigits: 0,
                                ).format(property.price),
                          highlight: !isSold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: isSold ? null : onEdit,
                      icon: Icon(
                        isSold ? Icons.inventory_2_outlined : Icons.edit,
                        size: 14,
                      ),
                      label: Text(isSold ? 'ARQUIVADO' : 'EDITAR'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PropertyMediaEntity? _coverMedia(BrokerPropertyEntity property) {
    final coverUrl = property.coverUrl.trim();
    for (final media in property.media) {
      if (!media.isImage || !media.isActive) continue;
      if (media.url.trim() == coverUrl || media.publicUrl.trim() == coverUrl) {
        return media;
      }
    }

    for (final media in property.media) {
      if (media.isImage && media.isActive) return media;
    }
    return null;
  }

  String _coverUrl(BrokerPropertyEntity property, PropertyMediaEntity? media) {
    final coverUrl = property.coverUrl.trim();
    if (coverUrl.isNotEmpty) return coverUrl;
    if (media == null) return '';
    return media.publicUrl.trim().isNotEmpty ? media.publicUrl : media.url;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'published' => 'PUBLICADO',
      'pending_review' => 'PENDENTE',
      'sold' => 'VENDIDO',
      _ => 'PENDENTE',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: status == 'published' ? DSColors.primary : const Color(0xFF9A6B12),
      child: Text(
        label,
        style: const TextStyle(
          color: DSColors.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CardMetric extends StatelessWidget {
  const _CardMetric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: DSColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: highlight ? DSColors.primary : DSColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.controller});

  final BrokerController controller;

  @override
  Widget build(BuildContext context) {
    final store = controller.store;
    final profile = store.profile;
    if (profile == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final side = SizedBox(
          width: isWide ? 370 : double.infinity,
          child: Column(
            children: <Widget>[
              _ProfileSummaryCard(
                profile: profile,
                isUploading: store.isUploadingAvatar,
                onAvatarTap: () => _uploadAvatar(context),
              ),
              const SizedBox(height: 24),
              _SecurityCard(onPasswordTap: () => _changePassword(context)),
            ],
          ),
        );
        final form = Expanded(
          child: _ProfileForm(controller: controller, profile: profile),
        );

        if (!isWide) {
          return Column(
            children: <Widget>[
              side,
              const SizedBox(height: 24),
              _ProfileForm(controller: controller, profile: profile),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[side, const SizedBox(width: 48), form],
        );
      },
    );
  }

  Future<void> _uploadAvatar(BuildContext context) async {
    final uploaded = await controller.pickAndUploadAvatar();
    if (!context.mounted || !uploaded) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Avatar atualizado.')));
  }

  Future<void> _changePassword(BuildContext context) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordDialog(controller: controller),
    );
    if (!context.mounted || changed != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha atualizada.')));
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
    required this.isUploading,
    required this.onAvatarTap,
  });

  final UserProfileEntity profile;
  final bool isUploading;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: isUploading ? null : onAvatarTap,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 190,
                  height: 190,
                  child: profile.avatarUrl.isEmpty
                      ? const _AvatarFallback()
                      : CachedNetworkImage(
                          imageUrl: profile.avatarUrl,
                          fit: BoxFit.cover,
                        ),
                ),
                if (isUploading) const CircularProgressIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${profile.brokerCode}',
            style: const TextStyle(
              color: DSColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 44),
          const Divider(height: 1),
          const SizedBox(height: 32),
          _SummaryRow(
            label: 'STATUS',
            value: profile.isActive ? 'ATIVO' : 'INATIVO',
            highlighted: profile.isActive,
          ),
          const SizedBox(height: 22),
          _SummaryRow(
            label: 'MEMBRO DESDE',
            value: _formatMemberSince(profile),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince(UserProfileEntity profile) {
    final date = DateTime.tryParse(profile.createdAt);
    if (date == null) return '-';
    const months = <String>[
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: DSColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: highlighted
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
              : EdgeInsets.zero,
          color: highlighted ? DSColors.primary.withValues(alpha: 0.22) : null,
          child: Text(
            value,
            style: TextStyle(
              color: highlighted ? DSColors.primary : DSColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.onPasswordTap});

  final VoidCallback onPasswordTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Seguranca',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onPasswordTap,
              icon: const Icon(Icons.lock_outline, size: 15),
              label: const Text('ALTERAR SENHA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({required this.controller, required this.profile});

  final BrokerController controller;
  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final store = controller.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PanelTitle('Informacoes Profissionais'),
              const SizedBox(height: 42),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProfileField(
                      label: 'NOME COMPLETO',
                      controller: store.nameController,
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _ProfileField(
                      label: 'CRECI (LICENCA PROFISSIONAL)',
                      controller: store.creciController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _ProfileField(
                label: 'SOBRE',
                controller: store.aboutController,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PanelTitle('Contatos Profissionais'),
              const SizedBox(height: 42),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProfileField(
                      label: 'WHATSAPP / MOBILE',
                      controller: store.whatsappController,
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _ProfileField(
                      label: 'E-MAIL CORPORATIVO',
                      initialValue: profile.email,
                      readOnly: true,
                      icon: Icons.mail_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _ProfileField(
                label: 'CELULAR',
                controller: store.phoneController,
                icon: Icons.smartphone_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 56),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: store.hasProfileChanges
                  ? controller.store.resetProfileForm
                  : null,
              child: const Text('CANCELAR'),
            ),
            const SizedBox(width: 48),
            FilledButton.icon(
              onPressed: store.hasProfileChanges && !store.isSavingProfile
                  ? () => _save(context)
                  : null,
              icon: const Icon(Icons.save_outlined, size: 15),
              label: Text(
                store.isSavingProfile ? 'SALVANDO...' : 'SALVAR ALTERACOES',
              ),
              style: FilledButton.styleFrom(
                fixedSize: const Size(300, 64),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.saveProfile();
    if (!context.mounted || !saved) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    this.controller,
    this.initialValue,
    this.readOnly = false,
    this.maxLines = 1,
    this.icon,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final bool readOnly;
  final int maxLines;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(color: DSColors.onPrimary),
      decoration: const InputDecoration(
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: DSColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        if (icon == null)
          field
        else
          Row(
            children: <Widget>[
              Icon(icon, color: DSColors.primary, size: 17),
              const SizedBox(width: 12),
              Expanded(child: field),
            ],
          ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.controller});

  final BrokerController controller;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar senha'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha atual'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova senha'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmationController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final changed = await widget.controller.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      newPasswordConfirmation: _confirmationController.text,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (changed) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(padding: const EdgeInsets.all(34), child: child),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.surfaceContainerHigh,
      child: const Icon(
        Icons.image_outlined,
        color: DSColors.secondary,
        size: 40,
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.surfaceContainerHigh,
      child: const Icon(
        Icons.person_outline,
        color: DSColors.secondary,
        size: 60,
      ),
    );
  }
}

class _EmptyPropertiesState extends StatelessWidget {
  const _EmptyPropertiesState();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nenhum imovel encontrado.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
