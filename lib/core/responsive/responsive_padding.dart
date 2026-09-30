import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Applies adaptive padding based on device screen classification.
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? small;
  final double? standard;
  final double? tablet;
  final bool horizontalOnly;
  final bool verticalOnly;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.small,
    this.standard,
    this.tablet,
    this.horizontalOnly = false,
    this.verticalOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final paddingValue = ResponsiveBreakpoints.value<double>(
      context,
      small: small ?? 16.0,
      standard: standard ?? 24.0,
      tablet: tablet ?? 32.0,
    );

    EdgeInsets edgeInsets;
    if (horizontalOnly) {
      edgeInsets = EdgeInsets.symmetric(horizontal: paddingValue);
    } else if (verticalOnly) {
      edgeInsets = EdgeInsets.symmetric(vertical: paddingValue);
    } else {
      edgeInsets = EdgeInsets.all(paddingValue);
    }

    return Padding(
      padding: edgeInsets,
      child: child,
    );
  }
}
