import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../../theme/app_colors.dart';

/// User-friendly error banner component for authentication flows.
/// Guarantees that raw technical/Firebase errors are sanitized into
/// clear, actionable, friendly messages.
class ErrorMessage extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry margin;

  const ErrorMessage({
    super.key,
    required this.error,
    this.onDismiss,
    this.margin = const EdgeInsets.only(bottom: 18),
  });

  /// Extracts a human-friendly string from any error type
  static String? getFriendlyMessage(dynamic error) {
    if (error == null) return null;
    if (error is String) {
      if (error.trim().isEmpty) return null;
      return AppError.fromException(error).message;
    }
    return AppError.fromException(error).message;
  }

  @override
  Widget build(BuildContext context) {
    final message = getFriendlyMessage(error);

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: message != null && message.isNotEmpty
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: message != null && message.isNotEmpty
          ? Container(
              margin: margin,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.35),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(),
      secondChild: const SizedBox.shrink(),
    );
  }
}
