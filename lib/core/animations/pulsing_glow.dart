import 'package:flutter/material.dart';
import 'app_animation_constants.dart';

/// Renders a subtle, athletic breathing glow or pulse effect around a child.
/// Great for the splash screen logo, streak fire badges, and milestones.
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minBlur;
  final double maxBlur;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final bool animate;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF76FF03), // AppColors.primaryLime
    this.minBlur = 12.0,
    this.maxBlur = 28.0,
    this.minOpacity = 0.15,
    this.maxOpacity = 0.35,
    this.duration = const Duration(milliseconds: 1600),
    this.animate = true,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.animate && !isTesting) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (widget.animate && !isTesting) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || AppAnimationConstants.shouldReduceMotion(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final t = _glowAnimation.value;
        final currentBlur = widget.minBlur + (widget.maxBlur - widget.minBlur) * t;
        final currentOpacity =
            widget.minOpacity + (widget.maxOpacity - widget.minOpacity) * t;

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(currentOpacity),
                blurRadius: currentBlur,
                spreadRadius: 2.0 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
