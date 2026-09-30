import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../core/responsive/breakpoints.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../main_navigation.dart';
import '../trainer/trainer_onboarding_screen.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final UserRole initialRole;

  const RoleSelectionScreen({
    super.key,
    this.name = '',
    this.email = '',
    this.password = '',
    this.initialRole = UserRole.self,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  Future<void> _handleContinue() async {
    final authProv = context.read<AuthProvider>();
    final roleProv = context.read<RoleProvider>();

    // If registration credentials were already entered on the registration form
    if (widget.name.trim().isNotEmpty && widget.email.trim().isNotEmpty) {
      final success = await authProv.register(
        widget.name.trim(),
        widget.email.trim(),
        widget.password.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      if (success) {
        roleProv.setRole(_selectedRole);

        if (_selectedRole == UserRole.trainer) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => TrainerOnboardingScreen(user: authProv.user),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to PROFIT, ${widget.name.trim()}! 💪'),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // If user navigated to role selection first, navigate to registration with selected role pre-filled
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterScreen(initialRole: _selectedRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final horizontalPadding = ResponsiveBreakpoints.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveBreakpoints.maxContentWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24 > 0
                          ? constraints.maxHeight - 24
                          : 0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PROFIT Brand Logo
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: ProFitLogo(
                                size: 56,
                                showText: true,
                                showTagline: true,
                                fontSize: 22,
                              ),
                            ),
                          ),

                          // Prompt Question
                          const Text(
                            'How do you want to use PROFIT?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose your experience to personalize workouts, meal planning, or coaching tools.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error banner if any
                          if (authProv.errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.error, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authProv.errorMessage!,
                                      style: const TextStyle(
                                          color: AppColors.error, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Role Card 1: SELF
                          _buildRoleCard(
                            role: UserRole.self,
                            title: 'SELF',
                            subtitle:
                                'Track your own workouts, nutrition and fitness progress.',
                            icon: Icons.fitness_center_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),

                          // Role Card 2: TRAINER
                          _buildRoleCard(
                            role: UserRole.trainer,
                            title: 'TRAINER',
                            subtitle:
                                'Manage clients, workouts, nutrition and fitness progress.',
                            icon: Icons.sports_gymnastics_rounded,
                            isDark: isDark,
                          ),

                          const Spacer(),
                          const SizedBox(height: 16),

                          // Continue Button
                          FitFlowButton(
                            text: 'Continue',
                            height: 54,
                            borderRadius: 27,
                            isLoading: authProv.isLoading,
                            onPressed: _handleContinue,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedRole = role);
        },
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLime.withOpacity(isDark ? 0.12 : 0.08)
                : (isDark ? AppColors.darkSurface : AppColors.gray100),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryLime
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryLime.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLime.withOpacity(0.22)
                      : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.primaryLime
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: isSelected
                            ? AppColors.primaryLime
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Selected Radio / Checkmark Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryLime : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryLime
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF0F172A),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
