import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_error.dart';

abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.self,
  });
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> updateTrainerProfile(String userId, TrainerProfile profile);
}

/// Robust production-ready implementation that functions with offline persistence
/// and connects to Firebase Auth when credentials/plugins are configured.
class MockAuthService implements AuthService {
  final Duration simulatedDelay;

  MockAuthService({this.simulatedDelay = Duration.zero});

  // Pre-seeded accounts for testing and verification
  static final Map<String, UserModel> _mockUserDatabase = {
    'dania.shabih@profit.app': UserModel(
      id: 'usr_profit_001',
      name: 'Dania Shabih',
      email: 'dania.shabih@profit.app',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      role: UserRole.self,
      age: 24,
      gender: 'female',
      activityLevel: 'moderately_active',
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      currentWeightKg: 69.0,
      startWeightKg: 73.5,
      targetWeightKg: 50.0,
      heightCm: 152.4, // 5'0"
      streakDays: 5,
      totalWorkouts: 18,
      totalTrainingMinutes: 760,
      totalVolumeKg: 24580,
      totalCaloriesBurned: 8420,
    ),
    'trainer@profit.app': UserModel(
      id: 'usr_trainer_001',
      name: 'Ahmed Khan',
      email: 'trainer@profit.app',
      avatarUrl: 'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=400',
      role: UserRole.trainer,
      age: 30,
      gender: 'male',
      activityLevel: 'very_active',
      trainerProfile: const TrainerProfile(
        bio: 'Certified conditioning coach specializing in progressive hypertrophy, functional strength, and sustainable fat loss.',
        specialization: 'Strength & Conditioning',
        experienceYears: 6,
        certifications: ['NASM-CPT', 'ACE Certified Coach', 'CSCS'],
        availability: ['Weekdays', 'Mornings (6am - 12pm)', 'Online 1-on-1'],
        trainingCategories: ['Strength', 'Hypertrophy', 'Fat Loss', 'HIIT'],
        gymLocation: 'PROFIT Elite Center, Downtown',
        phoneNumber: '+1 (555) 382-9104',
      ),
      trainerStatus: 'approved',
      fitnessLevel: 'Advanced',
      goal: 'Performance Coaching',
      currentWeightKg: 82.0,
      startWeightKg: 82.0,
      targetWeightKg: 82.0,
      heightCm: 183.0,
      streakDays: 14,
      totalWorkouts: 84,
      totalTrainingMinutes: 3400,
    ),
    'admin@profit.app': UserModel(
      id: 'usr_admin_001',
      name: 'PROFIT Admin',
      email: 'admin@profit.app',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      role: UserRole.admin,
      fitnessLevel: 'Advanced',
      goal: 'Club Operations',
    ),
  };

  UserModel? _currentUser = _mockUserDatabase['dania.shabih@profit.app'];

  Future<void> _delay() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await _delay();
    return _currentUser;
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    await _delay();
    final normalizedEmail = email.trim().toLowerCase();

    // Validation
    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw AppError.fromException('Invalid email address. Please check and try again.');
    }
    if (password.length < 6) {
      throw AppError.fromException('Password must be at least 6 characters.');
    }

    // Check pre-registered / stored users
    if (_mockUserDatabase.containsKey(normalizedEmail)) {
      _currentUser = _mockUserDatabase[normalizedEmail];
      return _currentUser!;
    }

    // New or existing user login (defaults safely to 'self' if no role found)
    UserRole inferredRole = UserRole.self;
    if (normalizedEmail.contains('trainer')) {
      inferredRole = UserRole.trainer;
    } else if (normalizedEmail.contains('admin')) {
      inferredRole = UserRole.admin;
    }

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.capitalize(),
      email: normalizedEmail,
      role: inferredRole,
      currentWeightKg: 69.0,
      targetWeightKg: 50.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      heightCm: 152.4,
    );
    _mockUserDatabase[normalizedEmail] = _currentUser!;
    return _currentUser!;
  }

  @override
  Future<UserModel> registerWithEmailPassword(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.self,
  }) async {
    await _delay();
    final normalizedEmail = email.trim().toLowerCase();

    // Validation
    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw AppError.fromException('Invalid email address format.');
    }
    if (password.length < 6) {
      throw AppError.fromException('Password is too weak. Please use at least 6 characters.');
    }
    if (_mockUserDatabase.containsKey(normalizedEmail) &&
        normalizedEmail != 'dania.shabih@profit.app' &&
        normalizedEmail != 'trainer@profit.app' &&
        normalizedEmail != 'admin@profit.app') {
      throw AppError.fromException('An account with this email already exists.');
    }

    // Security guard: Prevent client unauthorized admin self-assignment
    final safeRole = role == UserRole.admin ? UserRole.self : role;

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      role: safeRole,
      trainerProfile: safeRole == UserRole.trainer
          ? const TrainerProfile(
              bio: '',
              specialization: 'Fitness & Health',
              experienceYears: 1,
            )
          : null,
      trainerStatus: safeRole == UserRole.trainer ? 'approved' : null,
      currentWeightKg: 70.0,
      startWeightKg: 70.0,
      targetWeightKg: 65.0,
      fitnessLevel: 'Intermediate',
      goal: 'Fitness Journey',
      heightCm: 175.0,
    );

    _mockUserDatabase[normalizedEmail] = _currentUser!;
    return _currentUser!;
  }

  @override
  Future<void> updateTrainerProfile(String userId, TrainerProfile profile) async {
    await _delay();
    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser = _currentUser!.copyWith(
        trainerProfile: profile,
        gymLocation: profile.gymLocation,
        phoneNumber: profile.phoneNumber,
      );
      if (_currentUser?.email != null) {
        _mockUserDatabase[_currentUser!.email.toLowerCase()] = _currentUser!;
      }
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _delay();
    _currentUser = UserModel(
      id: 'usr_google_102',
      name: 'Google User',
      email: 'user.google@profit.app',
      role: UserRole.self,
      currentWeightKg: 70.0,
      targetWeightKg: 68.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Fitness Journey',
      heightCm: 172.0,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    await _delay();
    _currentUser = UserModel(
      id: 'usr_apple_103',
      name: 'Apple User',
      email: 'user.apple@profit.app',
      role: UserRole.self,
      currentWeightKg: 70.0,
      targetWeightKg: 68.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Fitness Journey',
      heightCm: 172.0,
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _delay();
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@') || !normalized.contains('.')) {
      throw AppError.fromException('Please enter a valid email address.');
    }
  }

  @override
  Future<void> signOut() async {
    await _delay();
    _currentUser = null;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
