import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/utils/role_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth/auth_widgets.dart';
/// Clean, minimal, premium Sign Up screen for PROFIT.
/// Keeps registration simple, intuitive, and comfortable across devices.
class SignUpScreen extends StatefulWidget {
  final UserRole initialRole;

  const SignUpScreen({
    super.key,
    this.initialRole = UserRole.self,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProv = context.read<AuthProvider>();
    if (authProv.isLoading) return;

    final roleProv = context.read<RoleProvider>();

    final success = await authProv.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      roleProv.setRole(_selectedRole);

      if (authProv.user != null) {
        RoleRouter.navigateToRoleHome(context, authProv.user!, isSignUp: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
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
                  vertical: 12,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const AuthHeader(
                        title: 'Create Account 🚀',
                        subtitle:
                            'Start your fitness journey with Profit.',
                        logoSize: 64,
                        centerContent: false,
                        showTagline: false,
                      ),
                      const SizedBox(height: 24),

                      // Error message banner
                      ErrorMessage(
                        error: authProv.errorMessage,
                      ),

                      // Role Selection (Athlete vs Trainer)
                      Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleCard(
                              title: 'Self Trainer',
                              subtitle: 'Track your own fitness',
                              role: UserRole.self,
                              icon: Icons.person_rounded,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildRoleCard(
                              title: 'Trainer',
                              subtitle: 'Manage client athletes',
                              role: UserRole.trainer,
                              icon: Icons.sports_rounded,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Full Name Field
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'e.g. Alex Rivera',
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_emailFocusNode);
                        },
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (val.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      AppTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        label: 'Email Address',
                        hintText: 'name@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
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
                      const SizedBox(height: 16),

                      // Password Field
                      PasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        label: 'Password',
                        hintText: 'Minimum 6 characters',
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_confirmPasswordFocusNode);
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      PasswordField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSignUp(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      PrimaryButton(
                        text: 'Create Account',
                        isLoading: authProv.isLoading,
                        onPressed:
                            authProv.isLoading ? null : _handleSignUp,
                      ),
                      const SizedBox(height: 24),

                      // Already have an account -> Sign In
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.primaryLime
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required UserRole role,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLime.withOpacity(isDark ? 0.12 : 0.15)
              : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLime
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryLime
                          : const Color(0xFF111827))
                      : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
                  size: 22,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryLime,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF111827))
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
