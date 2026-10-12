import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/self_trainer_cycle_provider.dart';
import '../../services/bmi_service.dart';
import '../../services/nutrition_service.dart';
import '../../core/utils/fitness_calculators.dart';
import '../../core/animations/animations.dart';
import '../main_navigation.dart';

/// Clean, responsive multi-step Personal Fitness Setup Wizard for PROFIT.
///
/// Flow:
/// Screen 1: Basic Information (Full Name, numeric Age with validation)
/// Screen 2: Gender (Male, Female, Prefer not to say)
/// Screen 3: Height (cm or ft/in selector, normalized to cm)
/// Screen 4: Current Weight (kg, unit toggle, normalized to kg, explanation)
/// Screen 5: Fitness Goal (Lose Weight, Build Muscle, Maintain Weight, Improve Fitness, Improve Strength)
/// Screen 6: Automatic BMI Calculation (Screening disclaimer, visual badge, dynamic recalculation)
/// Screen 7: Target Weight (Suggested healthy range, safe boundary warnings)
/// Screen 8: Workout Preferences (Days/week: 2-6, Duration: 30-90 min, Target focus)
/// Screen 9: Nutrition / Protein Target (Existing calculation logic: protein g/day & calorie targets)
/// Screen 10: Profile Review Screen (Full summary card, Edit button, Complete Profile button)
///
/// Stores partial progress to Cloud Firestore on every step.
class FitnessSetupWizardScreen extends StatefulWidget {
  final int initialStep;

  const FitnessSetupWizardScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  State<FitnessSetupWizardScreen> createState() => _FitnessSetupWizardScreenState();
}

class _FitnessSetupWizardScreenState extends State<FitnessSetupWizardScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 10;
  static const int _coreDataSteps = 8;

  // Step 1: Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(text: '25');
  int _age = 25;
  String? _ageError;

  // Step 2: Gender
  String _gender = 'Male';

  // Step 3: Height
  bool _isFeetInches = false;
  int _heightFeet = 5;
  int _heightInches = 7;
  double _heightCm = 170.0;

  // Step 4: Weight
  double _currentWeightKg = 70.0;

  // Step 5: Fitness Goal
  String _selectedGoal = 'Lose Weight';

  // Step 7: Target Weight
  double _targetWeightKg = 65.0;

  // Step 8: Workout Preferences
  int? _trainingDays;
  int _workoutDuration = 45; // 30, 45, 60, 90 minutes
  String _workoutTarget = 'Weight Loss';

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: widget.initialStep);

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
          _ageController.text = user.age.toString();
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
        if (user.goal.isNotEmpty) {
          _selectedGoal = _normalizeGoalName(user.goal);
        }
        if (user.targetWeightKg > 0) {
          _targetWeightKg = user.targetWeightKg;
        } else {
          _updateTargetWeightSuggestion();
        }
        if (user.hasEnteredWorkoutPreferences && user.trainingDaysPerWeek > 0) {
          _trainingDays = user.trainingDaysPerWeek;
        }
        if (user.workoutDuration != null && user.workoutDuration! > 0) {
          _workoutDuration = user.workoutDuration!;
        }

        // Resume from first incomplete step if default initial step 0 was passed
        if (widget.initialStep == 0 && !user.isProfileCompleted) {
          final resumeStep = _findFirstIncompleteStep(user);
          if (resumeStep != _currentStep && resumeStep < _totalSteps) {
            _currentStep = resumeStep;
            _pageController.jumpToPage(resumeStep);
          }
        }
        setState(() {});
      }
    });
  }

  String _normalizeGoalName(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('lose') || lower.contains('fat')) return 'Lose Weight';
    if (lower.contains('muscle') || lower.contains('hypertrophy')) return 'Build Muscle';
    if (lower.contains('maintain')) return 'Maintain Weight';
    if (lower.contains('strength')) return 'Improve Strength';
    return 'Improve Fitness';
  }

  int _findFirstIncompleteStep(UserModel user) {
    if (user.name.isEmpty || user.age == null || user.age! <= 0) return 0; // Screen 1
    if (user.gender == null || user.gender!.isEmpty) return 1; // Screen 2
    if (!user.hasEnteredHeight && user.heightCm <= 0) return 2; // Screen 3
    if (!user.hasEnteredWeight && user.currentWeightKg <= 0) return 3; // Screen 4
    if (!user.hasEnteredGoal) return 4; // Screen 5
    // Screen 6 is auto BMI review
    if (!user.hasEnteredTargetWeight) return 6; // Screen 7
    if (!user.hasEnteredWorkoutPreferences) return 7; // Screen 8
    return 8; // Screen 9 (Nutrition)
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
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

  /// Automatically persists partial progress to Cloud Firestore and local state
  Future<void> _persistCurrentStepProgress() async {
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    if (user == null) return;

    try {
      final updatedName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : user.name;
      final proteinRecommendation = FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: _currentWeightKg,
        fitnessGoal: _selectedGoal,
      );

      final updatedUser = user.copyWith(
        name: updatedName,
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        goal: _selectedGoal,
        trainingDaysPerWeek: _trainingDays ?? 0,
        workoutDuration: _workoutDuration,
        proteinTarget: proteinRecommendation.targetGrams,
        hasEnteredHeight: _currentStep >= 2,
        hasEnteredWeight: _currentStep >= 3,
        hasEnteredGoal: _currentStep >= 4,
        hasEnteredTargetWeight: _currentStep >= 6,
        hasEnteredWorkoutPreferences: _currentStep >= 7 && _trainingDays != null,
      );

      await authProv.saveUserProfile(updatedUser);
    } catch (_) {
      // Local state is preserved even if network sync is delayed
    }
  }

  bool get _canContinue {
    if (_currentStep == 7) {
      return _trainingDays != null;
    }
    return true;
  }

  bool _validateStep(int step) {
    if (step == 0) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your full name.'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      final ageText = _ageController.text.trim();
      final parsedAge = int.tryParse(ageText);
      if (parsedAge == null || parsedAge < 14 || parsedAge > 95) {
        setState(() {
          _ageError = 'Please enter a valid age between 14 and 95.';
        });
        return false;
      }
      _age = parsedAge;
      setState(() => _ageError = null);
    }
    return true;
  }

  void _nextPage() async {
    if (!_validateStep(_currentStep)) return;

    // Persist completed fields so far to Cloud Firestore
    await _persistCurrentStepProgress();

    if (_currentStep < _totalSteps - 1) {
      if (_currentStep == 3 || _currentStep == 4) {
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

  void _jumpToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    final authProv = context.read<AuthProvider>();
    final cycleProv = context.read<SelfTrainerCycleProvider>();
    final user = authProv.user;
    if (user == null) return;

    setState(() => _isGenerating = true);

    try {
      final finalName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : user.name;
      final proteinRecommendation = FitnessCalculators.calculateDailyProteinRecommendation(
        weightKg: _currentWeightKg,
        fitnessGoal: _selectedGoal,
      );

      // 1. Generate full fitness plan, workout routine, and nutrition targets via CycleProvider
      await cycleProv.completeFitnessSetup(
        userId: user.id,
        fullName: finalName,
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        goalType: _selectedGoal,
        trainingDaysPerWeek: _trainingDays ?? 4,
        workoutDuration: _workoutDuration,
        proteinTarget: proteinRecommendation.targetGrams,
      );

      // 2. Mark profile as completed in Auth user profile
      final updatedUser = user.copyWith(
        name: finalName,
        age: _age,
        gender: _gender,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        goal: _selectedGoal,
        trainingDaysPerWeek: _trainingDays ?? 4,
        workoutDuration: _workoutDuration,
        proteinTarget: proteinRecommendation.targetGrams,
        fitnessSetupCompleted: true,
        profileCompleted: true,
        hasEnteredHeight: true,
        hasEnteredWeight: true,
        hasEnteredGoal: true,
        hasEnteredTargetWeight: true,
        hasEnteredWorkoutPreferences: true,
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
            content: Text('Failed to complete profile: $e'),
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

    // Progress computation:
    // Core data steps 1-8 are indexed 0-7. Steps 8 (Nutrition) and 9 (Review) are 100% complete.
    final double progressValue;
    if (_currentStep < _coreDataSteps) {
      progressValue = (_currentStep + 1) / _coreDataSteps;
    } else {
      progressValue = 1.0;
    }

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
                // Clean unclipped Progress Indicator with dynamic step counter
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _currentStep < _coreDataSteps
                                  ? 'Step ${_currentStep + 1} of $_coreDataSteps'
                                  : (_currentStep == 8 ? 'Nutrition Targets' : 'Profile Review'),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryLime,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentStep < _coreDataSteps
                                ? '${((_currentStep + 1) / _coreDataSteps * 100).round()}% Complete'
                                : '100% Complete',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLime),
                          minHeight: 5,
                        ),
                      ),
                    ],
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
                      _buildStep2Gender(isDark),
                      _buildStep3Height(isDark),
                      _buildStep4Weight(isDark),
                      _buildStep5Goal(isDark),
                      _buildStep6BmiCalculation(isDark),
                      _buildStep7TargetWeight(isDark),
                      _buildStep8WorkoutPreferences(isDark),
                      _buildStep9NutritionTargets(isDark),
                      _buildStep10ReviewScreen(isDark),
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

  // =========================================================================
  // SCREEN 1 — BASIC INFORMATION (Name & numeric Age)
  // =========================================================================
  Widget _buildStep1BasicInfo(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 1,
            title: "Let's get to know you",
            subtitle: 'This helps us personalize your fitness journey.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Text('Full Name', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: _inputDecoration('e.g. Dania Shabih', isDark),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          Text('Age', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: _inputDecoration('e.g. 25', isDark).copyWith(
              errorText: _ageError,
              suffixText: 'years old',
              suffixStyle: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            onChanged: (val) {
              final parsed = int.tryParse(val.trim());
              if (parsed != null && parsed >= 14 && parsed <= 95) {
                setState(() {
                  _age = parsed;
                  _ageError = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: _cardDecoration(isDark),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick adjust age',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLime),
                      onPressed: () {
                        if (_age > 14) {
                          setState(() {
                            _age--;
                            _ageController.text = _age.toString();
                            _ageError = null;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_age',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLime),
                      onPressed: () {
                        if (_age < 95) {
                          setState(() {
                            _age++;
                            _ageController.text = _age.toString();
                            _ageError = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 2 — GENDER
  // =========================================================================
  Widget _buildStep2Gender(bool isDark) {
    final options = [
      (label: 'Male', icon: Icons.male_rounded),
      (label: 'Female', icon: Icons.female_rounded),
      (label: 'Prefer not to say', icon: Icons.person_outline_rounded),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 2,
            title: 'What is your gender?',
            subtitle: 'Gender informs baseline caloric expenditure and metabolic estimates.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          ...options.map((opt) {
            final isSelected = _gender == opt.label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PressableScale(
                onTap: () => setState(() => _gender = opt.label),
                child: AnimatedContainer(
                  duration: AppAnimationConstants.fast,
                  curve: AppAnimationConstants.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLime.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLime
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLime
                              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          opt.icon,
                          color: isSelected ? Colors.black : AppColors.primaryLime,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primaryLime : Colors.grey,
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

  // =========================================================================
  // SCREEN 3 — HEIGHT (cm OR ft/in)
  // =========================================================================
  Widget _buildStep3Height(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 3,
            title: 'How tall are you?',
            subtitle: 'Height is essential for calculating your Body Mass Index and healthy weight span.',
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Measurement Unit', style: _labelStyle(isDark)),
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
          const SizedBox(height: 20),
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
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Row(
                children: [
                  Icon(Icons.straighten_rounded, size: 16, color: AppColors.primaryLime),
                  const SizedBox(width: 6),
                  Text(
                    'Stored standard: ${_heightCm.toStringAsFixed(1)} cm',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
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
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 4 — CURRENT WEIGHT
  // =========================================================================
  Widget _buildStep4Weight(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 4,
            title: "What's your current weight?",
            subtitle: "We'll use this to calculate your BMI and personalize your fitness targets.",
            isDark: isDark,
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 24),
          _buildHealthDisclaimer(
            'Normalized in kilograms. Weight calibrations are used alongside height to safely determine energy needs and protein targets.',
            isDark,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 5 — FITNESS GOAL
  // =========================================================================
  Widget _buildStep5Goal(bool isDark) {
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
      (
        title: 'Improve Strength',
        description: 'Increase maximal force output, neural adaptation, and power.',
        icon: Icons.bolt_rounded,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 5,
            title: "What's your main goal?",
            subtitle: 'Select your primary focus. PROFIT will tailor your routine and nutrition accordingly.',
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

  // =========================================================================
  // SCREEN 6 — BMI CALCULATION (Automatic, visual indicator, disclaimer)
  // =========================================================================
  Widget _buildStep6BmiCalculation(bool isDark) {
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
            stepNumber: 6,
            title: 'Your BMI',
            subtitle: 'Automatically calculated from your entered height and weight.',
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
            'Important: BMI is a general screening indicator based on height and weight. It does not measure direct muscle mass or body fat percentage, and is not a medical diagnosis.',
            isDark,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 7 — TARGET WEIGHT (Suggested range, safe boundaries)
  // =========================================================================
  Widget _buildStep7TargetWeight(bool isDark) {
    final healthyRange = BmiService.getHealthyWeightRange(_heightCm);
    final targetBmi = BmiService.calculateBmi(_targetWeightKg, _heightCm);
    final isTargetPotentiallyUnsafe = targetBmi < 18.0 || targetBmi > 32.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 7,
            title: "What's your target weight?",
            subtitle: 'Evidence-based target range tailored to your height and body metrics.',
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
                  'Your Target Weight',
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
                          if (_targetWeightKg > 35.0) {
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
                          if (_targetWeightKg < 200.0) {
                            setState(() => _targetWeightKg = double.parse((_targetWeightKg + 0.5).toStringAsFixed(1)));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isTargetPotentiallyUnsafe) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning, width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Target weight appears outside the standard healthy range. Please consider a sustainable target for optimal health.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildHealthDisclaimer(
            'Target weights are flexible milestones. PROFIT allows you to update your target as your fitness journey progresses.',
            isDark,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 8 — WORKOUT PREFERENCES (Days/week, Duration, Focus)
  // =========================================================================
  Widget _buildStep8WorkoutPreferences(bool isDark) {
    final daysOptions = [
      (days: 2, title: '2 Days / Week', desc: 'Full Body frequency. Ideal for busy schedules and recovery.'),
      (days: 3, title: '3 Days / Week', desc: 'Upper / Lower / Full Body. Balanced stimulus and rest.'),
      (days: 4, title: '4 Days / Week', desc: 'Antagonist Split (Chest+Tri, Back+Bi, Legs, Shoulders+Core).'),
      (days: 5, title: '5 Days / Week', desc: 'Hypertrophy & Conditioning with active recovery days.'),
      (days: 6, title: '6 Days / Week', desc: 'Push / Pull / Legs double cycle. High frequency volume.'),
    ];

    final durations = [30, 45, 60, 90];
    final targets = ['Weight Loss', 'Muscle Building', 'Strength', 'General Fitness'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 8,
            title: "Let's build your workout routine",
            subtitle: 'Choose your weekly commitment. You can adapt this anytime.',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          Text('How many days can you train per week?', style: _labelStyle(isDark)),
          const SizedBox(height: 12),
          ...daysOptions.map((opt) {
            final selected = _trainingDays == opt.days;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _trainingDays = opt.days),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLime.withValues(alpha: 0.12)
                          : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
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
                            child: Text(
                              '${opt.days}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: selected ? Colors.black : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(
                                opt.desc,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected ? Icons.check_circle_rounded : Icons.radio_button_off,
                          color: selected ? AppColors.primaryLime : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('Preferred workout duration', style: _labelStyle(isDark)),
          const SizedBox(height: 10),
          Row(
            children: durations.map((dur) {
              final isSel = _workoutDuration == dur;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _workoutDuration = dur),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSel ? AppColors.primaryLime : Colors.transparent,
                      foregroundColor: isSel ? Colors.black : (isDark ? Colors.white : Colors.black),
                      side: BorderSide(
                        color: isSel ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('$dur min', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Target Routine Focus', style: _labelStyle(isDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: targets.map((t) {
              final isSel = _workoutTarget == t;
              return ChoiceChip(
                label: Text(t),
                selected: isSel,
                onSelected: (_) => setState(() => _workoutTarget = t),
                selectedColor: AppColors.primaryLime,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.black : (isDark ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 9 — NUTRITION / PROTEIN TARGET (Existing calculation logic)
  // =========================================================================
  Widget _buildStep9NutritionTargets(bool isDark) {
    final proteinRec = FitnessCalculators.calculateDailyProteinRecommendation(
      weightKg: _currentWeightKg,
      fitnessGoal: _selectedGoal,
    );
    final nutritionTargets = NutritionService.calculateDailyTargets(
      weightKg: _currentWeightKg,
      heightCm: _heightCm,
      age: _age,
      gender: _gender,
      goalType: _selectedGoal,
      trainingDaysPerWeek: _trainingDays ?? 4,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'CALCULATED NUTRITION TARGETS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.primaryLime,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Daily Protein Target',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Evidence-based macronutrient targets calibrated to your body weight and training focus.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Large highlight card for Daily Protein
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryLime, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.egg_alt_rounded, color: AppColors.primaryLime, size: 36),
                const SizedBox(height: 8),
                Text(
                  '${proteinRec.targetGrams.round()} g/day',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'Recommended Daily Protein (${proteinRec.minGrams.round()} – ${proteinRec.maxGrams.round()} g)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Daily Calories & Macros Overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target Calories', style: _labelStyle(isDark)),
                    Text(
                      '${nutritionTargets.targetCalories} kcal',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryLime),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Carbs', '${nutritionTargets.targetCarbsGrams.round()} g', isDark),
                    _buildStatCol('Protein', '${nutritionTargets.targetProteinGrams.round()} g', isDark),
                    _buildStatCol('Fat', '${nutritionTargets.targetFatGrams.round()} g', isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildHealthDisclaimer(
            'Calorie and macronutrient estimates are calculated via the Mifflin-St Jeor equation and standard sports nutrition guidelines.',
            isDark,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SCREEN 10 — PROFILE REVIEW SCREEN
  // =========================================================================
  Widget _buildStep10ReviewScreen(bool isDark) {
    final bmi = BmiService.calculateBmi(_currentWeightKg, _heightCm);
    final bmiCategory = BmiService.getBmiCategory(bmi);
    final proteinRec = FitnessCalculators.calculateDailyProteinRecommendation(
      weightKg: _currentWeightKg,
      fitnessGoal: _selectedGoal,
    );

    final summaryItems = [
      ('Name', _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Athlete', 0),
      ('Age', '$_age', 0),
      ('Gender', _gender, 1),
      ('Height', '${_heightCm.toStringAsFixed(1)} cm', 2),
      ('Current Weight', '${_currentWeightKg.toStringAsFixed(1)} kg', 3),
      ('Target Weight', '${_targetWeightKg.toStringAsFixed(1)} kg', 6),
      ('BMI', bmi.toStringAsFixed(1), 5),
      ('BMI Category', bmiCategory, 5),
      ('Fitness Goal', _selectedGoal, 4),
      ('Workout Schedule', '$_trainingDays days/week', 7),
      ('Workout Duration', '$_workoutDuration min', 7),
      ('Daily Protein Target', '${proteinRec.targetGrams.round()} g/day', 8),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryLime),
                label: const Text('Edit Steps', style: TextStyle(color: AppColors.primaryLime, fontWeight: FontWeight.w700)),
                onPressed: () => _jumpToStep(0),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Review all your metrics before finalizing your personalized fitness cycle.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark),
            child: Column(
              children: summaryItems.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == summaryItems.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _jumpToStep(item.$3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.$1,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BOTTOM BAR CTA (Back & Continue / Complete Profile)
  // =========================================================================
  Widget _buildBottomBar(bool isDark) {
    final isReviewStep = _currentStep == _totalSteps - 1;

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
      child: isReviewStep
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: () => _jumpToStep(0),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(88, 54),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _AnimatedContinueButton(
                    isEnabled: true,
                    isDark: isDark,
                    label: 'Complete Profile',
                    onPressed: _completeProfile,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                if (_currentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PressableScale(
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(88, 54),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Text(
                          'Back',
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
                    isEnabled: _canContinue,
                    isDark: isDark,
                    label: 'Continue',
                    onPressed: _canContinue ? _nextPage : null,
                  ),
                ),
              ],
            ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
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
              'Crafting Your Personalized Fitness Trajectory',
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
            'STEP $stepNumber OF $_coreDataSteps',
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
      label: widget.label,
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
                      color: enabled ? Colors.black : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: enabled ? Colors.black : (isDark ? Colors.white24 : Colors.black26),
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
