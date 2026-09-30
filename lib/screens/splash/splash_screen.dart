import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../core/utils/role_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth/auth_widgets.dart';
import '../../widgets/common/profit_logo.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    final authProv = context.read<AuthProvider>();
    await authProv.isInitialized;
    if (!mounted) return;

    Widget nextScreen;
    if (!authProv.hasOnboarded) {
      nextScreen = const OnboardingScreen();
    } else if (authProv.isAuthenticated) {
      final role = authProv.user?.role ?? UserRole.self;
      context.read<RoleProvider>().setRole(role);
      nextScreen = getRoleBasedHomeScreen(role);
    } else {
      nextScreen = const SignInScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => nextScreen,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Brand Logo & Title
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: const ProFitLogo(
                    size: 96,
                    showText: true,
                    showTagline: true,
                    fontSize: 38,
                    taglineFontSize: 15,
                    textColor: Colors.white,
                    logoColor: Colors.white,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // CTA Button: "Get Started →"
              FadeTransition(
                opacity: _fadeAnim,
                child: PrimaryButton(
                  text: 'Get Started →',
                  height: 56,
                  borderRadius: 28,
                  onPressed: _navigateToNext,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
