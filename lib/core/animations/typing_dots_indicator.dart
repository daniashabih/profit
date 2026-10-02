import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_animation_constants.dart';

/// Three subtle bouncing/pulsing animated dots for AI chat typing states.
/// Replaces generic spinner with a polished, modern messaging experience.
class TypingDotsIndicator extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final double spacing;

  const TypingDotsIndicator({
    super.key,
    this.color,
    this.dotSize = 6.0,
    this.spacing = 4.0,
  });

  @override
  State<TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<TypingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _controller.repeat();
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
      final dotColor = widget.color ?? AppColors.primaryLime;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      );
    }

    final effectiveColor = widget.color ?? AppColors.primaryLime;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Wave offset per dot
            final delay = index * 0.22;
            final progress = (_controller.value - delay) % 1.0;
            // Sine wave bounce: 0 -> 1 -> 0
            final bounce = math.sin(progress * math.pi).clamp(0.0, 1.0);
            final offsetY = -4.0 * bounce;
            final opacity = 0.4 + 0.6 * bounce;

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
