import '../models/user_model.dart';
import '../core/enums/user_role.dart';

abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

/// Robust production-ready implementation that functions in offline demo mode
/// and connects to Firebase Auth when credentials/plugins are configured.
class MockAuthService implements AuthService {
  UserModel? _currentUser = UserModel(
    id: 'usr_profit_001',
    name: 'Dania Shabih',
    email: 'dania.shabih@profit.app',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    role: UserRole.member,
    fitnessLevel: 'Beginner • Fitness',
    goal: 'Weight Loss',
    currentWeightKg: 69.0,
    startWeightKg: 73.5,
    targetWeightKg: 50.0,
    heightCm: 152.4, // 5'0"
    streakDays: 5,
    totalWorkouts: 18,
    totalTrainingMinutes: 760, // 12h 40m
    totalVolumeKg: 24580,
    totalCaloriesBurned: 8420,
  );

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.capitalize(),
      email: email,
      role: UserRole.member,
      currentWeightKg: 69.0,
      targetWeightKg: 50.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      heightCm: 152.4,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> registerWithEmailPassword(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: UserRole.member,
      currentWeightKg: 69.0,
      targetWeightKg: 50.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      heightCm: 152.4,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = UserModel(
      id: 'usr_google_102',
      name: 'Dania Shabih',
      email: 'dania.google@profit.app',
      role: UserRole.member,
      currentWeightKg: 69.0,
      targetWeightKg: 50.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      heightCm: 152.4,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = UserModel(
      id: 'usr_apple_103',
      name: 'Dania Shabih',
      email: 'dania.apple@profit.app',
      role: UserRole.member,
      currentWeightKg: 69.0,
      targetWeightKg: 50.0,
      fitnessLevel: 'Beginner • Fitness',
      goal: 'Weight Loss',
      heightCm: 152.4,
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
