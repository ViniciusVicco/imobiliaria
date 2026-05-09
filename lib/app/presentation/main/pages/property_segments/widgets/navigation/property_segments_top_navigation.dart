import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/assets/custom_assets.dart';

class PropertySegmentsTopNavigation extends StatelessWidget {
  const PropertySegmentsTopNavigation({
    super.key,
    required this.onNewDevelopmentsPressed,
    required this.onContactPressed,
    required this.onAboutPressed,
    required this.onMissionPressed,
    required this.onWhatsappPressed,
  });

  final VoidCallback onNewDevelopmentsPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onAboutPressed;
  final VoidCallback onMissionPressed;
  final VoidCallback onWhatsappPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DSColors.brandLogoBackground,
            borderRadius: DSRadius.md,
            border: Border.all(color: DSColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.md,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 820;
                final logo = _LogoMark(isCompact: isCompact);
                final links = _NavigationLinks(
                  isCompact: isCompact,
                  onNewDevelopmentsPressed: onNewDevelopmentsPressed,
                  onContactPressed: onContactPressed,
                  onAboutPressed: onAboutPressed,
                  onMissionPressed: onMissionPressed,
                );
                final whatsappButton = _WhatsappButton(
                  onPressed: onWhatsappPressed,
                );

                if (isCompact) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(child: logo),
                      const SizedBox(height: DSSpacing.sm),
                      Center(child: whatsappButton),
                      const SizedBox(height: DSSpacing.md),
                      links,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    SizedBox(height: 220, child: logo),
                    const SizedBox(width: DSSpacing.lg),
                    Expanded(child: Center(child: links)),
                    const SizedBox(width: DSSpacing.lg),
                    whatsappButton,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return SizedBox(
        height: 80,
        child: SvgPicture.asset(CustomAssets.icons.selettaIcon),
      );
    }
    return Image.asset(
      CustomAssets.logo.logoSelettaClean,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.high,
    );
  }
}

class _NavigationLinks extends StatelessWidget {
  const _NavigationLinks({
    required this.isCompact,
    required this.onNewDevelopmentsPressed,
    required this.onContactPressed,
    required this.onAboutPressed,
    required this.onMissionPressed,
  });

  final bool isCompact;
  final VoidCallback onNewDevelopmentsPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onAboutPressed;
  final VoidCallback onMissionPressed;

  @override
  Widget build(BuildContext context) {
    final linkButtons = <Widget>[
      _NavigationLinkButton(
        onPressed: onNewDevelopmentsPressed,
        label: 'Novidades na planta',
      ),
      _NavigationLinkButton(onPressed: onContactPressed, label: 'Contatos'),
      _NavigationLinkButton(onPressed: onAboutPressed, label: 'Sobre nos'),
      _NavigationLinkButton(onPressed: onMissionPressed, label: 'Missao'),
    ];

    if (isCompact) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - DSSpacing.xs) / 2;
          return Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: linkButtons
                .map((button) => SizedBox(width: itemWidth, child: button))
                .toList(),
          );
        },
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.xs,
      children: linkButtons,
    );
  }
}

class _NavigationLinkButton extends StatelessWidget {
  const _NavigationLinkButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _WhatsappButton extends StatelessWidget {
  const _WhatsappButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        ),
        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: DSColors.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      icon: const Icon(BootstrapIcons.whatsapp),
      label: const Text('Contate-nos'),
    );
  }
}
