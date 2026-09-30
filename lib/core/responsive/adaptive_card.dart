import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'breakpoints.dart';

/// An adaptive, Material 3 styled card that scales internal padding and border radii
/// based on screen size, preventing cramped UI on small phones and sparse UI on tablets.
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedBorderColor;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.onTap,
    this.isSelected = false,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ??
        ResponsiveBreakpoints.value<double>(
          context,
          small: 16.0,
          standard: 20.0,
          tablet: 24.0,
        );

    final cardPadding = padding ??
        EdgeInsets.all(
          ResponsiveBreakpoints.value<double>(
            context,
            small: 14.0,
            standard: 18.0,
            tablet: 22.0,
          ),
        );

    final defaultBg = isDark ? AppColors.darkSurface : AppColors.gray100;
    final defaultSelectedBorder = selectedBorderColor ?? AppColors.primaryLime;

    final effectiveBorder = border ??
        Border.all(
          color: isSelected
              ? defaultSelectedBorder
              : (isDark ? AppColors.darkBorder : AppColors.gray200),
          width: isSelected ? 2.0 : 1.0,
        );

    final cardDecoration = BoxDecoration(
      color: backgroundColor ?? (isSelected
          ? defaultSelectedBorder.withOpacity(isDark ? 0.12 : 0.08)
          : defaultBg),
      borderRadius: BorderRadius.circular(radius),
      border: effectiveBorder,
    );

    Widget cardContent = Container(
      padding: cardPadding,
      decoration: cardDecoration,
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
