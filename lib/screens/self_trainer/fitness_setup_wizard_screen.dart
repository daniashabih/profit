import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../services/bmi_service.dart';
import '../../core/animations/animations.dart';
import '../main_navigation.dart';

/// Personal Fitness Setup Wizard for Self Trainer Athletes.
/// Guides new athletes through basic info, height & weight, goal, automatic BMI,
/// suggested target weight range, and weekly training days.
class FitnessSetupWizardScreen extends StatefulWidget {
  const FitnessSetupWizardScreen({super.key});

  @override
  State<FitnessSetupWizardScreen> createState() => _FitnessSetupWizardScreenState();
}

class _FitnessSetupWizardScreenState extends State<FitnessSetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 6;

  // Step 1: Basic Info
  final TextEditingController _nameController = TextEditingController();
  int _age = 26;
  String _gender = 'Female';

  // Step 2: Body Measurements
  bool _isFeetInches = false;
  int _heightFeet = 5;
  int _heightInches = 0;
  double _heightCm = 152.4;
  double _currentWeightKg = 69.0;

  // Step 3: Fitness Goal
  String _selectedGoal = 'Lose Weight';

  // Step 5: Target Weight
  double _targetWeightKg = 58.0;

  // Step 6: Training Days
  int? _trainingDays;

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        if (user.name.isNotEmpty) {
          _nameController.text = user.name;
        }
        if (user.age != null && user.age! > 0) {
          _age = user.age!;
        }
        if (user.gender != null && user.gender!.isNotEmpty) {
          _gender = user.gender!;
        }
        if (user.heightCm > 0) {
          _heightCm = user.heightCm;
          _heightFeet = (_heightCm / 30.48).floor();
          _heightInches = ((_heightCm % 30.48) / 2.54).round();
        }
        if (user.currentWeightKg > 0) {
          _currentWeightKg = user.currentWeightKg;
        }
        _updateTargetWeightSuggestion();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _updateTargetWeightSuggestion() {
    final suggestion = BmiService.suggestTargetWeight(
      currentWeightKg: _currentWeightKg,
      heightCm: _heightCm,
      goalType: _selectedGoal,
    );
    _targetWeightKg = suggestion.suggestedInitialTargetKg;
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      if (_currentStep == 1 || _currentStep == 2) {
        _updateTargetWeightSuggestion();
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generatePlanAndFinish() async {
    if (_trainingDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a workout frequency to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProv = context.read<AuthProvider>();
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    final user = authProv.user;
    if (user == null) return;

    setState(() => _isGenerating = true);

    try {
      final finalName = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : user.name;

      await cycleProv.completeFitnessSetup(
        userId: user.id,
        fullName: finalName,
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        goalType: _selectedGoal,
        trainingDaysPerWeek: _trainingDays!,
      );

      // Update auth user profile locally and in Firestore
      final updatedUser = user.copyWith(
        name: finalName,
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        goal: _selectedGoal,
        fitnessSetupCompleted: true,
        trainingDaysPerWeek: _trainingDays!,
      );
      await authProv.saveUserProfile(updatedUser);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) => const MainNavigation(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate fitness plan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _isGenerating ? null : _prevPage,
              )
            : null,
        title: Text(
          'Personal Fitness Setup',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: _isGenerating
          ? SafeArea(child: _buildGeneratingState(isDark))
          : Column(
              children: [
                // Clean unclipped Progress Indicator with proper spacing
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                      minHeight: 4,
                    ),
                  ),
                ),
                // Expanded scrollable PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (step) => setState(() => _currentStep = step),
                    children: [
                      _buildStep1BasicInfo(isDark),
                      _buildStep2Measurements(isDark),
                      _buildStep3Goal(isDark),
                      _buildStep4BmiCalculation(isDark),
                      _buildStep5TargetWeight(isDark),
                      _buildStep6TrainingDays(isDark),
                    ],
                  ),
                ),
                // Fixed Bottom CTA area anchored inside SafeArea
                SafeArea(
                  top: false,
                  child: _buildBottomBar(isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildGeneratingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Crafting Your Personalized Fitness Cycle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Calculating metabolic targets, structuring target muscles, and selecting optimal exercises from Firestore library...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: BASIC INFORMATION
  Widget _buildStep1BasicInfo(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 1,
            title: "Let's Get to Know You",
            subtitle: 'PROFIT personalizes your fitness trajectory to your demographics.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Text('Full Name', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: _inputDecoration('e.g. Dania Shabih', isDark),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: _cardDecoration(isDark),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PressableScale(
                            onTap: () {
                              if (_age > 14) setState(() => _age--);
                            },
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLime),
                              onPressed: () {
                                if (_age > 14) setState(() => _age--);
                              },
                            ),
                          ),
                          Text(
                            '$_age',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          PressableScale(
                            onTap: () {
                              if (_age < 95) setState(() => _age++);
                            },
                            child: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLime),
                              onPressed: () {
                                if (_age < 95) setState(() => _age++);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Gender', style: _labelStyle(isDark)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGenderChip('Female', Icons.female_rounded, isDark),
              const SizedBox(width: 12),
              _buildGenderChip('Male', Icons.male_rounded, isDark),
              const SizedBox(width: 12),
              _buildGenderChip('Other', Icons.person_outline_rounded, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String gender, IconData icon, bool isDark) {
    final selected = _gender == gender;
    return Expanded(
      child: PressableScale(
        onTap: () => setState(() => _gender = gender),
        child: AnimatedContainer(
          duration: AppAnimationConstants.fast,
          curve: AppAnimationConstants.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryLime.withValues(alpha: 0.15)
                : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLime
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primaryLime : Colors.grey, size: 24),
              const SizedBox(height: 6),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 2: BODY MEASUREMENTS
  Widget _buildStep2Measurements(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 2,
            title: 'Your Body Measurements',
            subtitle: 'Accurate measurements power the automatic BMI and target calculations.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Height', style: _labelStyle(isDark)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildUnitToggle(
                      label: 'Ft + In',
                      selected: _isFeetInches,
                      onTap: () => setState(() => _isFeetInches = true),
                    ),
                    _buildUnitToggle(
                      label: 'Cm',
                      selected: !_isFeetInches,
                      onTap: () => setState(() => _isFeetInches = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isFeetInches) ...[
            Row(
              children: [
                Expanded(
                  child: _buildMeasurementPicker(
                    label: 'Feet',
                    value: '$_heightFeet ft',
                    onMinus: () {
                      if (_heightFeet > 3) {
                        setState(() {
                          _heightFeet--;
                          _heightCm = double.parse(
                              ((_heightFeet * 12 + _heightInches) * 2.54).toStringAsFixed(1));
                        });
                      }
                    },
                    onPlus: () {
                      if (_heightFeet < 7) {
                        setState(() {
                          _heightFeet++;
                          _heightCm = double.parse(
                              ((_heightFeet * 12 + _heightInches) * 2.54).toStringAsFixed(1));
                        });
                      }
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementPicker(
                    label: 'Inches',
                    value: '$_heightInches in',
                    onMinus: () {
                      if (_heightInches > 0) {
                        setState(() {
                          _heightInches--;
                          _heightCm = double.parse(
                              ((_heightFeet * 12 + _heightInches) * 2.54).toStringAsFixed(1));
                        });
                      }
                    },
                    onPlus: () {
                      if (_heightInches < 11) {
                        setState(() {
                          _heightInches++;
                          _heightCm = double.parse(
                              ((_heightFeet * 12 + _heightInches) * 2.54).toStringAsFixed(1));
                        });
                      }
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Normalized: ${_heightCm.toStringAsFixed(1)} cm',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54),
            ),
          ] else ...[
            _buildMeasurementPicker(
              label: 'Height in cm',
              value: '${_heightCm.toStringAsFixed(1)} cm',
              onMinus: () {
                if (_heightCm > 100) {
                  setState(() {
                    _heightCm = double.parse((_heightCm - 1.0).toStringAsFixed(1));
                    _heightFeet = (_heightCm / 30.48).floor();
                    _heightInches = ((_heightCm % 30.48) / 2.54).round();
                  });
                }
              },
              onPlus: () {
                if (_heightCm < 240) {
                  setState(() {
                    _heightCm = double.parse((_heightCm + 1.0).toStringAsFixed(1));
                    _heightFeet = (_heightCm / 30.48).floor();
                    _heightInches = ((_heightCm % 30.48) / 2.54).round();
                  });
                }
              },
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 28),
          Text('Current Body Weight', style: _labelStyle(isDark)),
          const SizedBox(height: 12),
          _buildMeasurementPicker(
            label: 'Weight in kg',
            value: '${_currentWeightKg.toStringAsFixed(1)} kg',
            onMinus: () {
              if (_currentWeightKg > 35) {
                setState(() => _currentWeightKg = double.parse((_currentWeightKg - 0.5).toStringAsFixed(1)));
              }
            },
            onPlus: () {
              if (_currentWeightKg < 250) {
                setState(() => _currentWeightKg = double.parse((_currentWeightKg + 0.5).toStringAsFixed(1)));
              }
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLime : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementPicker({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration(isDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLime, size: 28),
            onPressed: onMinus,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLime, size: 28),
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }

  // STEP 3: FITNESS GOAL
  Widget _buildStep3Goal(bool isDark) {
    final goals = [
      (
        title: 'Lose Weight',
        description: 'Burn fat progressively with calorie deficit and metabolic volume.',
        icon: Icons.local_fire_department_rounded,
      ),
      (
        title: 'Build Muscle',
        description: 'Optimize hypertrophy and strength with progressive overload.',
        icon: Icons.fitness_center_rounded,
      ),
      (
        title: 'Maintain Weight',
        description: 'Retain current weight, improve endurance and body recomposition.',
        icon: Icons.balance_rounded,
      ),
      (
        title: 'Improve Fitness',
        description: 'Boost stamina, mobility, conditioning, and overall energy.',
        icon: Icons.favorite_rounded,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 3,
            title: 'What is your primary goal?',
            subtitle: 'PROFIT tailors your workout volume and daily nutrition to this focus.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          ...goals.map((g) {
            final selected = _selectedGoal == g.title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGoal = g.title),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLime.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryLime
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLime
                              : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLime
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          g.icon,
                          color: selected ? Colors.black : AppColors.primaryLime,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              g.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? AppColors.primaryLime : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 4: AUTOMATIC BMI CALCULATION
  Widget _buildStep4BmiCalculation(bool isDark) {
    final bmi = BmiService.calculateBmi(_currentWeightKg, _heightCm);
    final category = BmiService.getBmiCategory(bmi);
    final healthyRange = BmiService.getHealthyWeightRange(_heightCm);

    Color badgeColor;
    if (category == 'Healthy Weight') {
      badgeColor = AppColors.success;
    } else if (category == 'Overweight') {
      badgeColor = AppColors.warning;
    } else if (category == 'Obese') {
      badgeColor = AppColors.error;
    } else {
      badgeColor = Colors.orange;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 4,
            title: 'Your Calculated BMI',
            subtitle: 'Automatically calculated from your weight and height.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkCardBackground, AppColors.darkSurface]
                    : [AppColors.lightCardBackground, AppColors.lightSurface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'BODY MASS INDEX',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor, width: 1.5),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _buildStatCol('Height', '${_heightCm.toStringAsFixed(1)} cm', isDark)),
                    Expanded(child: _buildStatCol('Weight', '${_currentWeightKg.toStringAsFixed(1)} kg', isDark)),
                    Expanded(child: _buildStatCol('Healthy Span', '${healthyRange.minKg}–${healthyRange.maxKg} kg', isDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHealthDisclaimer(
            'BMI is a standardized population screening metric calculated purely from height and weight. It does not measure direct muscle composition.',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String title, String value, bool isDark) {
    return Column(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // STEP 5: TARGET WEIGHT & HEALTH SAFETY
  Widget _buildStep5TargetWeight(bool isDark) {
    final healthyRange = BmiService.getHealthyWeightRange(_heightCm);
    final suggestion = BmiService.suggestTargetWeight(
      currentWeightKg: _currentWeightKg,
      heightCm: _heightCm,
      goalType: _selectedGoal,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 5,
            title: 'Your Suggested Target Weight',
            subtitle: 'Evidence-based target range tailored to your goal.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Current Weight', style: _labelStyle(isDark)),
                    ),
                    Text(
                      '${_currentWeightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Suggested Healthy Range',
                        style: _labelStyle(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${healthyRange.minKg} – ${healthyRange.maxKg} kg',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Your Initial Target Weight',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLime, size: 32),
                        onPressed: () {
                          if (_targetWeightKg > healthyRange.minKg - 5.0) {
                            setState(() => _targetWeightKg = double.parse((_targetWeightKg - 0.5).toStringAsFixed(1)));
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_targetWeightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLime, size: 32),
                        onPressed: () {
                          if (_targetWeightKg < _currentWeightKg + 20.0) {
                            setState(() => _targetWeightKg = double.parse((_targetWeightKg + 0.5).toStringAsFixed(1)));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  suggestion.rationale,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHealthDisclaimer(
            'Health Safety Notice: Target weights are non-prescriptive fitness estimates. PROFIT does not generate extreme crash diets or unsafe weight-loss plans. Consult a healthcare professional before making major lifestyle changes.',
            isDark,
          ),
        ],
      ),
    );
  }

  // STEP 6: TRAINING DAYS PER WEEK
  Widget _buildStep6TrainingDays(bool isDark) {
    final daysOptions = [
      (
        days: 2,
        title: '2 Days / Week',
        desc: 'Full Body frequency. Ideal for busy schedules and recovery.',
      ),
      (
        days: 3,
        title: '3 Days / Week',
        desc: 'Upper / Lower / Full Body. Balanced stimulus and rest.',
      ),
      (
        days: 4,
        title: '4 Days / Week',
        desc: 'Antagonist Split (Chest+Tri, Back+Bi, Legs, Shoulders+Core).',
      ),
      (
        days: 5,
        title: '5 Days / Week',
        desc: 'Hypertrophy & Conditioning with active recovery days.',
      ),
      (
        days: 6,
        title: '6 Days / Week',
        desc: 'Push / Pull / Legs double cycle. High frequency volume.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 6,
            title: 'How many days per week do you want to train?',
            subtitle: 'Choose your weekly commitment. You can adapt this anytime.',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          ...daysOptions.map((opt) {
            final selected = _trainingDays == opt.days;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() => _trainingDays = opt.days);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    constraints: const BoxConstraints(minHeight: 74),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLime.withValues(alpha: 0.12)
                          : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryLime
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryLime
                                : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryLime
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? Colors.black
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                              child: Text('${opt.days}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                opt.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.desc,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            selected ? Icons.check_circle_rounded : Icons.radio_button_off,
                            key: ValueKey<bool>(selected),
                            color: selected
                                ? AppColors.primaryLime
                                : (isDark ? Colors.white38 : Colors.black38),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // FIXED BOTTOM CTA AREA
  Widget _buildBottomBar(bool isDark) {
    final isLastStep = _currentStep == _totalSteps - 1;
    final isStepValid = isLastStep ? (_trainingDays != null) : true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: isLastStep
          ? _AnimatedContinueButton(
              isEnabled: isStepValid,
              isDark: isDark,
              label: 'Continue',
              onPressed: isStepValid ? _generatePlanAndFinish : null,
            )
          : Row(
              children: [
                if (_currentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PressableScale(
                      onTap: _prevPage,
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Text(
                          'Back',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _AnimatedContinueButton(
                    isEnabled: true,
                    isDark: isDark,
                    label: 'Continue',
                    onPressed: _nextPage,
                  ),
                ),
              ],
            ),
    );
  }

  // REUSABLE UI HELPERS
  Widget _buildStepHeader({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLime.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'STEP $stepNumber OF $_totalSteps',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.primaryLime,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthDisclaimer(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primaryLime, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black38),
      filled: true,
      fillColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryLime, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _AnimatedContinueButton extends StatefulWidget {
  final bool isEnabled;
  final bool isDark;
  final String label;
  final VoidCallback? onPressed;

  const _AnimatedContinueButton({
    required this.isEnabled,
    required this.isDark,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_AnimatedContinueButton> createState() => _AnimatedContinueButtonState();
}

class _AnimatedContinueButtonState extends State<_AnimatedContinueButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;
    final isDark = widget.isDark;

    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? widget.label : '${widget.label}. Please select a workout frequency to proceed',
      child: Listener(
        onPointerDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onPointerUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onPointerCancel: enabled ? (_) => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed && enabled ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? widget.onPressed : null,
              style: ButtonStyle(
                elevation: WidgetStateProperty.resolveWith<double>((states) {
                  if (states.contains(WidgetState.disabled)) return 0;
                  if (states.contains(WidgetState.pressed)) return 1;
                  return 2;
                }),
                shadowColor: WidgetStateProperty.all(
                  AppColors.primaryLime.withValues(alpha: 0.35),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return isDark ? const Color(0xFF1E241E) : Colors.grey.shade300;
                  }
                  return AppColors.primaryLime;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return isDark ? Colors.white38 : Colors.black38;
                  }
                  return Colors.black;
                }),
                shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
                  final isDis = states.contains(WidgetState.disabled);
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDis
                        ? BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1)
                        : BorderSide.none,
                  );
                }),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      color: enabled
                          ? Colors.black
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: enabled
                        ? Colors.black
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

