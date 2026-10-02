import 'package:flutter/material.dart';
import 'app_animation_constants.dart';

/// Reusable staggered entrance animation.
/// Fades and slides the child widget smoothly into view with an incremental delay based on [index].
/// Automatically bypasses motion when the user requests reduced motion.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration stepDelay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = Duration.zero,
    this.stepDelay = AppAnimationConstants.staggerStep,
    this.duration = AppAnimationConstants.entrance,
    this.offset = const Offset(0, 16),
    this.curve = AppAnimationConstants.easeOut,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    final totalDelay = widget.baseDelay + (widget.stepDelay * widget.index);
    if (totalDelay == Duration.zero) {
      if (mounted) _controller.forward();
    } else {
      Future.delayed(totalDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppAnimationConstants.shouldReduceMotion(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
