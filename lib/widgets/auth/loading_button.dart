import 'package:flutter/material.dart';
import 'primary_button.dart';

/// Button with built-in asynchronous loading management
/// or explicit loading boolean support.
class LoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isOutlined;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onPressedAsync,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 54.0,
    this.width,
    this.borderRadius = 16.0,
    this.isOutlined = false,
  }) : assert(
          onPressed != null || onPressedAsync != null,
          'Either onPressed or onPressedAsync must be provided',
        );

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _internalLoading = false;

  Future<void> _handlePress() async {
    if (widget.isLoading || _internalLoading) return;

    if (widget.onPressedAsync != null) {
      setState(() => _internalLoading = true);
      try {
        await widget.onPressedAsync!();
      } finally {
        if (mounted) {
          setState(() => _internalLoading = false);
        }
      }
    } else if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLoading = widget.isLoading || _internalLoading;

    return PrimaryButton(
      text: widget.text,
      onPressed: _handlePress,
      isLoading: effectiveLoading,
      icon: widget.icon,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      height: widget.height,
      width: widget.width,
      borderRadius: widget.borderRadius,
      isOutlined: widget.isOutlined,
    );
  }
}
