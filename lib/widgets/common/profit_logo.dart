import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// Official PROFIT Logo Component
/// Displays the official white/dark fitness silhouette with lightning bolt design
/// preserving original shape and proportions across all screen sizes.
class ProFitLogo extends StatelessWidget {
  /// Width and height of the silhouette image
  final double size;

  /// Whether to display the "PROFIT" brand name
  final bool showText;

  /// Whether to display the official tagline "Your Fitness. Your Progress."
  final bool showTagline;

  /// Font size for the brand name
  final double fontSize;

  /// Font size for the tagline (defaults to fontSize * 0.44)
  final double? taglineFontSize;

  /// Horizontal layout (side-by-side) vs Vertical layout (stacked)
  final bool isHorizontal;

  /// Custom text color for the brand name
  final Color? textColor;

  /// Custom logo tint color (defaults to white on dark themes, dark slate on light themes)
  final Color? logoColor;

  /// Whether to enclose the logo in a rounded badge container
  final bool showContainer;

  /// Safe padding inside container when showContainer is true
  final EdgeInsetsGeometry? containerPadding;

  const ProFitLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showTagline = false,
    this.fontSize = 28,
    this.taglineFontSize,
    this.isHorizontal = false,
    this.textColor,
    this.logoColor,
    this.showContainer = false,
    this.containerPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveLogoColor = logoColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    final effectiveTextColor = textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    final effectiveTaglineColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    Widget logoImage = Image.asset(
      'assets/images/logo/profit_logo_white.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: effectiveLogoColor,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );

    if (showContainer) {
      logoImage = Container(
        width: size,
        height: size,
        padding: containerPadding ?? EdgeInsets.all(size * 0.16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A20) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(
            color: AppColors.primaryLime.withOpacity(0.8),
            width: size > 48 ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLime.withOpacity(0.2),
              blurRadius: size * 0.35,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo/profit_logo_white.png',
          fit: BoxFit.contain,
          color: effectiveLogoColor,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    if (!showText) {
      return logoImage;
    }

    final effectiveTaglineSize = taglineFontSize ?? (fontSize * 0.44).clamp(11.0, 16.0);

    final titleText = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'PRO',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
            color: effectiveTextColor,
          ),
        ),
        Text(
          'FIT',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
            color: effectiveTextColor,
          ),
        ),
      ],
    );

    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isHorizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        titleText,
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            AppConstants.appTagline,
            textAlign: isHorizontal ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: effectiveTaglineSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: effectiveTaglineColor,
            ),
          ),
        ],
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoImage,
          SizedBox(width: size * 0.22),
          textColumn,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoImage,
        SizedBox(height: size * 0.16),
        textColumn,
      ],
    );
  }
}
