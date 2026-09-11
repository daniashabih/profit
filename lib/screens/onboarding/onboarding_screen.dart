import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/profit_logo.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'A Healthier You\nIs Possible',
      subtitle:
          'Build better habits, reach your goals\nand become the best version of yourself.',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
    ),
    _OnboardingData(
      title: 'Train Smarter\nEvery Day',
      subtitle:
          'Eliminate guesswork with numbered workout journeys,\ninteractive set tracking, and smart rest timers.',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    ),
    _OnboardingData(
      title: 'Track Your\nMilestones',
      subtitle:
          'Monitor body measurements, volume lifted, and\nstay accountable with motivating daily streaks.',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<AuthProvider>().completeOnboarding();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ProFitLogo(
                    size: 26,
                    showText: true,
                    isHorizontal: true,
                    fontSize: 16,
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Page View with Headline on top, Image in center
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Headline
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const Spacer(),

                        // Center Visual with Lime Graphic Shape Accent (matching Screen 2)
                        Center(
                          child: SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Organic Lime blob background accent
                                Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLime.withOpacity(isDark ? 0.25 : 0.8),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(140),
                                      topRight: Radius.circular(100),
                                      bottomLeft: Radius.circular(110),
                                      bottomRight: Radius.circular(160),
                                    ),
                                  ),
                                ),
                                // Athlete photo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    page.imageUrl,
                                    height: 280,
                                    width: 260,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      height: 280,
                                      width: 260,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurface
                                            : AppColors.gray100,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.fitness_center_rounded,
                                          size: 64,
                                          color: AppColors.primaryLime,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls: Dots, Next Button, Skip Link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                children: [
                  // 3 Progress Dots (Screen 2 mockup style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (idx) {
                      final isSelected = _currentPage == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLime
                              : (isDark ? AppColors.darkBorder : AppColors.gray300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next Pill Button
                  FitFlowButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    height: 54,
                    borderRadius: 27,
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 12),

                  // Centered Skip Link
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String subtitle;
  final String imageUrl;

  _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}
