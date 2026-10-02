import 'package:flutter/material.dart';
import '../../core/animations/pressable_scale.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Primary action button for PROFIT authentication and key user flows.
/// Features a solid high-contrast lime brand background in dark mode,
/// comfortable height, smooth ripple, and an integrated loading state.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 54.0,
    this.width,
    this.borderRadius = AppTheme.buttonRadius,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg =
        isDark ? AppColors.primaryLime : const Color(0xFF111827);
    final defaultFg =
        isDark ? const Color(0xFF111827) : Colors.white;

    final effectiveBg = backgroundColor ?? defaultBg;
    final effectiveFg = textColor ?? defaultFg;

    if (isOutlined) {
      final borderColor =
          isDark ? AppColors.darkBorder : AppColors.lightBorder;
      final outlinedText =
          textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

      return PressableScale(
        enabled: !isLoading && onPressed != null,
        child: SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: outlinedText,
              side: BorderSide(color: borderColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(outlinedText),
                    ),
                  )
                : _buildContent(outlinedText),
          ),
        ),
      );
    }

    return PressableScale(
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBg,
            foregroundColor: effectiveFg,
            disabledBackgroundColor: effectiveBg.withOpacity(0.55),
            disabledForegroundColor: effectiveFg.withOpacity(0.7),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
                  ),
                )
              : _buildContent(effectiveFg),
        ),
      ),
    );
  }

  Widget _buildContent(Color contentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: contentColor,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 20, color: contentColor),
        ],
      ],
    );
  }
}
