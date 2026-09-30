import 'package:flutter/material.dart';

/// Helper widget that ensures text scale factor stays within safe bounds
/// (e.g. 0.85 to 1.35) so high-contrast accessibility font sizes do not break layout boundaries.
class ResponsiveTextScale extends StatelessWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const ResponsiveTextScale({
    super.key,
    required this.child,
    this.minScale = 0.85,
    this.maxScale = 1.35,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final clampedTextScale = mediaQuery.textScaler.clamp(
      minScaleFactor: minScale,
      maxScaleFactor: maxScale,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedTextScale),
      child: child,
    );
  }
}
