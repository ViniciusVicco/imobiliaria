import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Staggers only the blocks discovered in the same frame, not the whole page.
class BrandRevealBatch {
  Duration? _frame;
  int _count = 0;

  Duration nextDelay() {
    final frame = SchedulerBinding.instance.currentFrameTimeStamp;
    if (_frame != frame) {
      _frame = frame;
      _count = 0;
    }
    final delay = Duration(milliseconds: _count.clamp(0, 3) * 80);
    _count++;
    return delay;
  }
}

class PropertyBrandReveal extends StatefulWidget {
  const PropertyBrandReveal({
    super.key,
    required this.batch,
    required this.child,
  });

  final BrandRevealBatch batch;
  final Widget child;

  @override
  State<PropertyBrandReveal> createState() => _PropertyBrandRevealState();
}

class _PropertyBrandRevealState extends State<PropertyBrandReveal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  final _layoutKey = GlobalKey();
  ScrollPosition? _position;
  Timer? _delay;
  bool _revealed = false;
  bool _checkPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_position != position) {
      _position?.removeListener(_scheduleCheck);
      _position = position;
      _position?.addListener(_scheduleCheck);
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _revealed = true;
      _delay?.cancel();
      _controller.value = 1;
    }
    _scheduleCheck();
  }

  @override
  void didChangeMetrics() => _scheduleCheck();

  void _scheduleCheck() {
    if (_revealed || _checkPending) return;
    _checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPending = false;
      if (mounted && !_revealed) _checkVisibility();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _checkVisibility() {
    final box = _layoutKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return;
    final viewport = RenderAbstractViewport.maybeOf(box);
    final viewportBox = viewport is RenderBox ? viewport as RenderBox : null;
    if (viewportBox != null) {
      final origin = box.localToGlobal(Offset.zero, ancestor: viewportBox);
      final bounds = origin & box.size;
      if (!bounds.overlaps(Offset.zero & viewportBox.size)) return;
    }
    _revealed = true;
    final delay = widget.batch.nextDelay();
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _delay = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_scheduleCheck);
    _delay?.cancel();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    // Measure this stationary box, never the translated child. Keeping semantics
    // available also makes the content readable before the visual reveal.
    return SizedBox(
      key: _layoutKey,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) => Opacity(
          opacity: _progress.value,
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, -24 * (1 - _progress.value)),
            child: child,
          ),
        ),
      ),
    );
  }
}
