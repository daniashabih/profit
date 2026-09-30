import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/breakpoints.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/profit_logo.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_text_field.dart';
import 'trainer_dashboard_screen.dart';

class TrainerOnboardingScreen extends StatefulWidget {
  final UserModel? user;

  const TrainerOnboardingScreen({super.key, this.user});

  @override
  State<TrainerOnboardingScreen> createState() => _TrainerOnboardingScreenState();
}

class _TrainerOnboardingScreenState extends State<TrainerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _gymController;
  int _experienceYears = 3;

  String _selectedSpecialization = 'Strength & Conditioning';
  final List<String> _specializations = const [
    'Strength & Conditioning',
    'Hypertrophy & Bodybuilding',
    'Weight Loss & Transformation',
    'Athletic Performance',
    'Functional & Mobility',
    'Nutrition Coaching',
  ];

  final List<String> _availableCategories = const [
    'Strength',
    'Hypertrophy',
    'HIIT',
    'Weight Loss',
    'Cardio',
    'Mobility',
  ];
  final Set<String> _selectedCategories = {'Strength', 'Hypertrophy'};

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phoneNumber ?? '');
    _bioController = TextEditingController(
      text: u?.trainerProfile?.bio ??
          'Passionate coach committed to helping athletes build strength and sustainable health.',
    );
    _gymController = TextEditingController(
      text: u?.gymLocation ?? 'PROFIT Elite Center, Downtown',
    );
    if (u?.trainerProfile?.experienceYears != null && u!.trainerProfile!.experienceYears > 0) {
      _experienceYears = u.trainerProfile!.experienceYears;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _gymController.dispose();
    super.dispose();
  }

  Future<void> _handleSave({bool isSkipping = false}) async {
    final authProv = context.read<AuthProvider>();

    final profile = TrainerProfile(
      bio: isSkipping ? '' : _bioController.text.trim(),
      specialization: _selectedSpecialization,
      experienceYears: _experienceYears,
      certifications: const [],
      availability: const [],
      trainingCategories: _selectedCategories.toList(),
      gymLocation: isSkipping ? null : _gymController.text.trim(),
      phoneNumber: isSkipping ? null : _phoneController.text.trim(),
    );

    await authProv.updateTrainerProfile(profile);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TrainerDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final horizontalPadding = ResponsiveBreakpoints.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Trainer Setup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => _handleSave(isSkipping: true),
            child: Text(
              'Skip for Now',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveBreakpoints.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Brand Logo
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: ProFitLogo(size: 54, showText: true, fontSize: 20),
                      ),
                    ),

                    const Text(
                      'Complete Your Coach Profile 🏋️‍♂️',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set up your professional credentials to start connecting with PROFIT members.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar / Profile photo preview
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryLime, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryLime.withOpacity(0.2),
                              child: const Icon(
                                Icons.sports_gymnastics_rounded,
                                size: 44,
                                color: AppColors.primaryLime,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLime,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    FitFlowTextField(
                      controller: _nameController,
                      label: 'Full Name *',
                      hintText: 'e.g. Coach Alex',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter your name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    FitFlowTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'coach@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    FitFlowTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Optional)',
                      hintText: '+1 (555) 000-0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Specialization Dropdown
                    Text(
                      'Primary Specialization *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSpecialization,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                          items: _specializations.map((spec) {
                            return DropdownMenuItem<String>(
                              value: spec,
                              child: Text(spec, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSpecialization = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Years of Experience Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Years of Experience',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_experienceYears Years Active',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                              color: AppColors.primaryLime,
                              onPressed: () {
                                if (_experienceYears > 1) {
                                  setState(() => _experienceYears--);
                                }
                              },
                            ),
                            Text('$_experienceYears', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              color: AppColors.primaryLime,
                              onPressed: () {
                                if (_experienceYears < 40) {
                                  setState(() => _experienceYears++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Training Categories Chips
                    Text(
                      'Training Categories',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCategories.map((cat) {
                        final isSelected = _selectedCategories.contains(cat);
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryLime.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryLime,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.primaryLime : (isDark ? Colors.white : Colors.black87),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryLime : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(cat);
                              } else {
                                _selectedCategories.remove(cat);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Gym / Location
                    FitFlowTextField(
                      controller: _gymController,
                      label: 'Gym or Studio Location',
                      hintText: 'e.g. PROFIT Elite Center, Downtown',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    FitFlowTextField(
                      controller: _bioController,
                      label: 'Trainer Bio',
                      hintText: 'Share your background, achievements, and training philosophy...',
                      prefixIcon: Icons.edit_note_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    FitFlowButton(
                      text: 'Complete Setup & Launch Dashboard →',
                      isLoading: authProv.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _handleSave(isSkipping: false);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
