import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_text_field.dart';

/// Password input field with an accessible visibility toggle
/// and consistent modern styling.
class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hintText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool initialObscured;

  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.initialObscured = true,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.initialObscured;
  }

  void _toggleVisibility() {
    setState(() => _obscured = !_obscured);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscured,
      keyboardType: _obscured ? TextInputType.text : TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: iconColor,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
        splashRadius: 20,
        onPressed: _toggleVisibility,
      ),
    );
  }
}
