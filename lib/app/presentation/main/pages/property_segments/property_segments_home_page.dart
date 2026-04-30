import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomePage
    extends StatelessController<MainModule, PropertySegmentsHomeController> {
  PropertySegmentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seletta Imobiliaria')),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, _) {
          final isLoading = state == AppStateEnum.isLoading;

          final errorMessage =
              state == AppStateEnum.hasError ? controller.store.consumeErrorMessage() : null;

          if (errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            });
          }

          const segments = <_SegmentCardData>[
            _SegmentCardData(
              title: 'Apartamentos e casas',
              subtitle: 'Imoveis residenciais para morar ou alugar.',
              buttonLabel: 'Ver opcoes',
              route: MainRoutes.residential,
              imageUrl:
                  'https://images.unsplash.com/photo-1460317442991-0ec209397118?auto=format&fit=crop&w=1200&q=80',
            ),
            _SegmentCardData(
              title: 'Ver pontos comerciais',
              subtitle: 'Lojas, salas e centros para operacao comercial.',
              buttonLabel: 'Explorar',
              route: MainRoutes.commercial,
              imageUrl:
                  'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
            ),
            _SegmentCardData(
              title: 'Investimentos na planta',
              subtitle: 'Projetos em desenvolvimento para ganho patrimonial.',
              buttonLabel: 'Descobrir',
              route: MainRoutes.investments,
              imageUrl:
                  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
            ),
            _SegmentCardData(
              title: 'Anunciar meu imovel',
              subtitle: 'Cadastre fotos e detalhes para publicar hoje mesmo.',
              buttonLabel: 'Anunciar',
              route: MainRoutes.announceProperty,
              imageUrl:
                  'https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?auto=format&fit=crop&w=1200&q=80',
            ),
          ];

          return Stack(
            children: <Widget>[
              const Positioned.fill(
                child: IgnorePointer(
                  child: _ParticlesBackground(),
                ),
              ),
              SingleChildScrollView(
                child: DSPageLayoutContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Encontre o proximo imovel ideal',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        'Quatro caminhos para morar, investir ou anunciar com uma experiencia fluida.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: DSColors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      _AnimatedSegmentGrid(
                        segments: segments,
                        enabled: !isLoading,
                        onPressed: (route) => controller.onSegmentPressed(
                          targetRoute: route,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: DSColors.surface.withOpacity(0.45),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedSegmentGrid extends StatefulWidget {
  const _AnimatedSegmentGrid({
    required this.segments,
    required this.onPressed,
    required this.enabled,
  });

  final List<_SegmentCardData> segments;
  final ValueChanged<String> onPressed;
  final bool enabled;

  @override
  State<_AnimatedSegmentGrid> createState() => _AnimatedSegmentGridState();
}

class _AnimatedSegmentGridState extends State<_AnimatedSegmentGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 760
                ? 2
                : 1;

        final childAspectRatio = crossAxisCount == 1 ? 1.38 : 1.26;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.segments.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: DSSpacing.md,
            crossAxisSpacing: DSSpacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final start = (index * 0.14).clamp(0.0, 1.0);
            final end = (start + 0.55).clamp(0.0, 1.0);
            final animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            );
            final segment = widget.segments[index];

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final opacity = animation.value;
                final offsetY = (1 - opacity) * 32;
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, offsetY),
                    child: child,
                  ),
                );
              },
              child: _SegmentCard(
                data: segment,
                enabled: widget.enabled,
                onTap: () => widget.onPressed(segment.route),
              ),
            );
          },
        );
      },
    );
  }
}

class _SegmentCardData {
  const _SegmentCardData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.route,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final String route;
  final String imageUrl;
}

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({
    required this.data,
    required this.onTap,
    required this.enabled,
  });

  final _SegmentCardData data;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cardBackground = DSColors.surfaceContainerHigh.withOpacity(0.75);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: DSRadius.lg,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: DSRadius.lg,
              border: Border.all(
                color: DSColors.outline.withOpacity(0.25),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: DSRadius.lg,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: data.imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 350),
                    placeholder: (_, __) => ColoredBox(color: cardBackground),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: DSColors.surfaceContainer,
                      child: const Icon(Icons.home_work_outlined),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          DSColors.surface.withOpacity(0.2),
                          DSColors.surface.withOpacity(0.82),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          data.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: DSColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: DSSpacing.xs),
                        Text(
                          data.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: DSColors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: DSSpacing.md),
                        FilledButton(
                          onPressed: enabled ? onTap : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: DSColors.primary,
                            foregroundColor: DSColors.onPrimary,
                          ),
                          child: Text(data.buttonLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticlesBackground extends StatefulWidget {
  const _ParticlesBackground();

  @override
  State<_ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<_ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List<_Particle>.generate(18, _createParticle);
  }

  _Particle _createParticle(int index) {
    final random = index + 1;
    return _Particle(
      seedX: ((random * 37) % 100) / 100,
      seedY: ((random * 53) % 100) / 100,
      radius: 2.0 + ((random * 13) % 11) / 2,
      speed: 0.4 + ((random * 23) % 7) / 10,
      opacity: 0.12 + ((random * 19) % 10) / 100,
      drift: 10 + ((random * 17) % 25).toDouble(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => RepaintBoundary(
        child: CustomPaint(
          painter: _ParticlePainter(
            progress: _controller.value,
            particles: _particles,
          ),
        ),
      ),
    );
  }
}

@immutable
class _Particle {
  const _Particle({
    required this.seedX,
    required this.seedY,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.drift,
  });

  final double seedX;
  final double seedY;
  final double radius;
  final double speed;
  final double opacity;
  final double drift;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..style = PaintingStyle.fill;
    for (final particle in particles) {
      final animatedY = (particle.seedY + progress * particle.speed * 0.15) % 1.2;
      final dx = particle.seedX * size.width +
          (sin((progress + particle.seedY) * 6.28318) * particle.drift);
      final dy = (animatedY * size.height) - (size.height * 0.1);
      basePaint.color = (particle.seedX > 0.5 ? DSColors.secondary : DSColors.primary)
          .withOpacity(particle.opacity);
      canvas.drawCircle(Offset(dx, dy), particle.radius, basePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || !listEquals(oldDelegate.particles, particles);
  }
}
