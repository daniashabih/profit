import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../common/profit_logo.dart';

/// Clean, minimal brand header for authentication screens.
/// Houses the official PROFIT logo, prominent greeting/action title,
/// and a subtle supportive subtitle with balanced whitespace.
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;
  final double logoSize;
  final bool centerContent;
  final bool showTagline;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.logoSize = 64,
    this.centerContent = false,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alignment =
        centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centerContent ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ProFitLogo(
              size: logoSize,
              showText: true,
              showTagline: showTagline,
              fontSize: 26,
            ),
          ),
        ],
        Text(
          title,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
