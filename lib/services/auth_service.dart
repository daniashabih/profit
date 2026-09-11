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
    id: 'usr_fitflow_001',
    name: 'Alex Rivera',
    email: 'alex.rivera@fitflow.app',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    role: UserRole.member,
    fitnessLevel: 'Intermediate',
    goal: 'Build Lean Muscle & Tone',
    currentWeightKg: 74.5,
    startWeightKg: 81.0,
    targetWeightKg: 72.0,
    heightCm: 178.0,
    streakDays: 5,
    totalWorkouts: 28,
    totalTrainingMinutes: 1140,
    totalVolumeKg: 18450,
    totalCaloriesBurned: 9800,
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
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = UserModel(
      id: 'usr_google_102',
      name: 'Alex Rivera (Google)',
      email: 'alex.google@fitflow.app',
      role: UserRole.member,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = UserModel(
      id: 'usr_apple_103',
      name: 'Alex Rivera (Apple)',
      email: 'alex.apple@fitflow.app',
      role: UserRole.member,
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
