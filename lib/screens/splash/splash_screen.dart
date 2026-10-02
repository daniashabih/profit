import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/animations/app_animation_constants.dart';
import '../../core/animations/pulsing_glow.dart';
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
  late Animation<double> _logoFadeAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _taglineFadeAnim;
  late Animation<Offset> _taglineSlideAnim;
  late Animation<double> _buttonFadeAnim;
  late Animation<Offset> _buttonSlideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // 1. Logo fades in from 0.0 -> 0.55
    _logoFadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    // Logo smoothly scales from 0.85 -> 1.0
    _logoScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Tagline fades and slides in slightly after the logo (0.35 -> 0.80)
    _taglineFadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
    );

    _taglineSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
    ));

    // 3. CTA button slides & fades in (0.60 -> 1.0)
    _buttonFadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    );

    _buttonSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    ));

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
      final user = authProv.user!;
      final role = user.role;
      context.read<RoleProvider>().setRole(role);

      if (role == UserRole.self) {
        RoleRouter.navigateToRoleHome(context, user);
        return;
      } else {
        RoleRouter.navigateToRoleHome(context, user);
        return;
      }
    } else {
      nextScreen = const SignInScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: AppAnimationConstants.medium,
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

              // Brand Logo & Title with ambient glow pulse
              FadeTransition(
                opacity: _logoFadeAnim,
                child: ScaleTransition(
                  scale: _logoScaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulsingGlow(
                        glowColor: AppColors.primaryLime,
                        minBlur: 14,
                        maxBlur: 32,
                        minOpacity: 0.12,
                        maxOpacity: 0.32,
                        child: const ProFitLogo(
                          size: 96,
                          showText: false,
                          logoColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // PROFIT Brand Name
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'FIT',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Sequential Tagline Entrance
              FadeTransition(
                opacity: _taglineFadeAnim,
                child: SlideTransition(
                  position: _taglineSlideAnim,
                  child: const Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // CTA Button: "Get Started →"
              FadeTransition(
                opacity: _buttonFadeAnim,
                child: SlideTransition(
                  position: _buttonSlideAnim,
                  child: PrimaryButton(
                    text: 'Get Started →',
                    height: 56,
                    borderRadius: 28,
                    onPressed: _navigateToNext,
                  ),
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
