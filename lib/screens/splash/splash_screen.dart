import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_navigation.dart';

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

  void _navigateToNext() {
    if (!mounted) return;
    final authProv = context.read<AuthProvider>();

    Widget nextScreen;
    if (!authProv.hasOnboarded) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const MainNavigation();
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
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Fitness Image (matching Mockup Screen 1)
          Image.network(
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=1000',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF0F1216),
            ),
          ),

          // Gradient overlay for dark cinematic effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  const Color(0xFF0F1216).withOpacity(0.85),
                  const Color(0xFF0F1216),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.55, 0.9],
              ),
            ),
          ),

          // Content
          SafeArea(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ProFitLogo(
                            size: 96,
                            showText: true,
                            showTagline: true,
                            fontSize: 38,
                            taglineFontSize: 15,
                            textColor: Colors.white,
                            logoColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CTA Button: "Get Started →" (Screen 1 in mockup)
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: FitFlowButton(
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
        ],
      ),
    );
  }
}
