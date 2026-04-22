import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';

/// Wraps a child in a slow looping scale-up/down animation.
///
/// Used to draw attention to in-progress states (e.g. waiting for a payment
/// to be scanned). Pass [enabled] = false to freeze the child at scale 1.
class PulseScale extends StatefulWidget {
  const PulseScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.minScale = 1.0,
    this.maxScale = 1.08,
    this.duration = AppMotion.pulse,
  });

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;
  final Duration duration;

  @override
  State<PulseScale> createState() => _PulseScaleState();
}

class _PulseScaleState extends State<PulseScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: widget.minScale,
    end: widget.maxScale,
  ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.press));

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulseScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
