import 'package:flutter/material.dart';
import 'app_animation_constants.dart';

/// Interactive wrapper providing a subtle, athletic scale-down feedback on press.
/// Conforms to Section 17 & 18:
/// - Normal: Stable (1.0)
/// - Pressed: Subtle scale down (~0.975)
/// - Released: Smooth return to normal (1.0)
/// - Respects reduced motion preferences
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.975,
    this.duration = AppAnimationConstants.fast,
    this.curve = AppAnimationConstants.easeOut,
    this.enabled = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didUpdateWidget(PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressedScale != widget.pressedScale ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.pressedScale,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    if (AppAnimationConstants.shouldReduceMotion(context)) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppAnimationConstants.shouldReduceMotion(context)) {
      if (widget.onTap != null || widget.onLongPress != null) {
        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        );
      }
      return widget.child;
    }

    Widget content = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Listener(
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),
      child: content,
    );
  }
}
