import 'package:flutter/material.dart';
import 'app_animation_constants.dart';

/// Smoothly interpolates an integer value with an optional prefix and suffix.
/// Perfect for streak days, calories, reps, and sets.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = AppAnimationConstants.slow,
    this.curve = AppAnimationConstants.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    if (AppAnimationConstants.shouldReduceMotion(context)) {
      return Text('$prefix$value$suffix', style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, val, child) {
        return Text(
          '$prefix${val.round()}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Smoothly interpolates a double/decimal value with specified decimal places.
/// Perfect for weight (kg), body fat (%), and distance (km).
class AnimatedDoubleCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int fractionDigits;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedDoubleCounter({
    super.key,
    required this.value,
    this.style,
    this.fractionDigits = 1,
    this.prefix = '',
    this.suffix = '',
    this.duration = AppAnimationConstants.slow,
    this.curve = AppAnimationConstants.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    if (AppAnimationConstants.shouldReduceMotion(context)) {
      return Text(
        '$prefix${value.toStringAsFixed(fractionDigits)}$suffix',
        style: style,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, val, child) {
        return Text(
          '$prefix${val.toStringAsFixed(fractionDigits)}$suffix',
          style: style,
        );
      },
    );
  }
}
