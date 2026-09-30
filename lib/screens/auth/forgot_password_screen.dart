import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/breakpoints.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth/auth_widgets.dart';

/// Clean, simple Forgot Password screen for PROFIT.
/// Guides the user through a frictionless reset request and presents
/// a comfortable confirmation state upon email dispatch.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSent = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProv = context.read<AuthProvider>();
    if (authProv.isLoading) return;

    final email = _emailController.text.trim();
    final success = await authProv.sendPasswordReset(email);

    if (success && mounted) {
      setState(() {
        _isSent = true;
        _sentEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final horizontalPadding = ResponsiveBreakpoints.horizontalPadding(context);
    final textSecondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveBreakpoints.maxContentWidth,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: _isSent
                    ? _buildSuccessView(isDark)
                    : _buildFormView(authProv, textSecondaryColor, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // Success Icon Badge
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryLime.withOpacity(isDark ? 0.15 : 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryLime.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
            size: 40,
          ),
        ),
        const SizedBox(height: 28),

        // Heading
        const Text(
          'Password Reset Email Sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle message
        Text(
          'Password reset email has been sent. Please check your inbox at $_sentEmail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 36),

        // Primary Action: Back to Sign In
        PrimaryButton(
          text: 'Back to Sign In',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 18),

        // Secondary Action: Resend link
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _isSent = false);
            },
            child: Text(
              'Didn\'t receive the email? Try again',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(
    AuthProvider authProv,
    Color textSecondaryColor,
    bool isDark,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo
          const Center(
            child: AuthHeader(
              title: 'Reset Password 🔑',
              subtitle:
                  'Enter your email and we\'ll send you a link to reset your password.',
              logoSize: 64,
              centerContent: false,
              showTagline: false,
            ),
          ),
          const SizedBox(height: 28),

          // Error Message banner
          ErrorMessage(
            error: authProv.errorMessage,
          ),

          // Email Field
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'name@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleReset(),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(val.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Primary Send Reset Link Button
          PrimaryButton(
            text: 'Send Reset Link',
            isLoading: authProv.isLoading,
            onPressed: authProv.isLoading ? null : _handleReset,
          ),
          const SizedBox(height: 24),

          // Return to Sign In
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: Text(
                  'Remember your password? Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primaryLime
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
