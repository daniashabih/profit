import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  Stream<User?> get authStateChanges;
}

/// Production-ready Firebase Authentication and Cloud Firestore service.
/// Connects directly to Google Firebase Auth and Cloud Firestore.
/// Password credentials are never stored in Firestore and are securely managed by Firebase Auth.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }

      // If document doesn't exist yet in Firestore, create default profile
      return await _createOrSyncFirestoreProfile(firebaseUser);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      throw AppError.fromException(e);
    }
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw const AppError(
        message: 'Please enter a valid email address.',
        code: 'invalid-email',
      );
    }
    if (cleanPassword.length < 6) {
      throw const AppError(
        message: 'Password must be at least 6 characters long.',
        code: 'weak-password',
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: cleanPassword,
      );

      final user = credential.user;
      if (user == null) {
        throw const AppError(message: 'Sign in failed. No user found.');
      }

      // Retrieve user's Firestore profile
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }

      // Fallback: If user exists in Auth but document was missing, sync doc
      return await _createOrSyncFirestoreProfile(user);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  @override
  Future<UserModel> registerWithEmailPassword(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.self,
  }) async {
    final cleanName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      throw const AppError(message: 'Please enter your full name.');
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw const AppError(
        message: 'Please enter a valid email address.',
        code: 'invalid-email',
      );
    }
    if (cleanPassword.length < 6) {
      throw const AppError(
        message: 'Password must be at least 6 characters long.',
        code: 'weak-password',
      );
    }

    // Client-side guard: Prevent unauthorized admin self-assignment
    final safeRole = role == UserRole.admin ? UserRole.self : role;
    final roleString = safeRole == UserRole.trainer ? 'trainer' : 'self_trainer';

    try {
      // 1. Create account with Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: cleanPassword,
      );

      final user = credential.user;
      if (user == null) {
        throw const AppError(message: 'Registration failed. Please try again.');
      }

      // 2. Update display name in Firebase Auth
      await user.updateDisplayName(cleanName);

      // 3. Create user document in Cloud Firestore: users/{uid}
      final nowIso = DateTime.now().toIso8601String();
      final userPayload = <String, dynamic>{
        'uid': user.uid,
        'id': user.uid,
        'fullName': cleanName,
        'name': cleanName,
        'email': normalizedEmail,
        'role': roleString,
        'profileImage': '',
        'avatarUrl': '',
        'createdAt': nowIso,
        'updatedAt': nowIso,
        'fitnessLevel': 'Beginner • Fitness',
        'goal': 'Fitness Journey',
        'currentWeightKg': 70.0,
        'startWeightKg': 70.0,
        'targetWeightKg': 68.0,
        'heightCm': 175.0,
        'streakDays': 0,
        'totalWorkouts': 0,
        'totalTrainingMinutes': 0,
        'totalVolumeKg': 0.0,
        'totalCaloriesBurned': 0,
        'membershipTier': 'FREE',
        'membershipDaysRemaining': 30,
        'membershipExpiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        if (safeRole == UserRole.trainer) 'trainerStatus': 'approved',
        if (safeRole == UserRole.trainer)
          'trainerProfile': const TrainerProfile(
            bio: '',
            specialization: 'Fitness & Health',
            experienceYears: 1,
          ).toMap(),
      };

      // Atomic merge into Cloud Firestore
      await _firestore.collection('users').doc(user.uid).set(
            userPayload,
            SetOptions(merge: true),
          );

      return UserModel.fromMap(userPayload);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw const AppError(
        message: 'Please enter a valid email address.',
        code: 'invalid-email',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  @override
  Future<void> updateTrainerProfile(String userId, TrainerProfile profile) async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(userId).update({
        'trainerProfile': profile.toMap(),
        if (profile.gymLocation != null) 'gymLocation': profile.gymLocation,
        if (profile.phoneNumber != null) 'phoneNumber': profile.phoneNumber,
        'updatedAt': nowIso,
      });
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Scaffolded for Google Sign-In with production-ready fallback
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await _createOrSyncFirestoreProfile(currentUser);
    }
    throw const AppError(
      message: 'Google Sign-In is not configured on this device yet.',
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await _createOrSyncFirestoreProfile(currentUser);
    }
    throw const AppError(
      message: 'Apple Sign-In is not configured on this device yet.',
    );
  }

  /// Internal helper to sync or create user profile in Firestore
  Future<UserModel> _createOrSyncFirestoreProfile(User user) async {
    final nowIso = DateTime.now().toIso8601String();
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'PROFIT User');

    final payload = <String, dynamic>{
      'uid': user.uid,
      'id': user.uid,
      'fullName': displayName,
      'name': displayName,
      'email': user.email ?? '',
      'role': 'self_trainer',
      'profileImage': user.photoURL ?? '',
      'avatarUrl': user.photoURL ?? '',
      'createdAt': nowIso,
      'updatedAt': nowIso,
      'fitnessLevel': 'Beginner • Fitness',
      'goal': 'Fitness Journey',
      'currentWeightKg': 70.0,
      'startWeightKg': 70.0,
      'targetWeightKg': 68.0,
      'heightCm': 175.0,
      'streakDays': 0,
      'totalWorkouts': 0,
      'totalTrainingMinutes': 0,
      'totalVolumeKg': 0.0,
      'totalCaloriesBurned': 0,
      'membershipTier': 'FREE',
      'membershipDaysRemaining': 30,
      'membershipExpiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    };

    await _firestore.collection('users').doc(user.uid).set(
          payload,
          SetOptions(merge: true),
        );

    return UserModel.fromMap(payload);
  }
}

/// MockAuthService for fast offline testing, widget test suites, and regression checks.
class MockAuthService implements AuthService {
  final Duration simulatedDelay;

  MockAuthService({this.simulatedDelay = Duration.zero});

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

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
      heightCm: 152.4,
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
        certifications: [],
        availability: [],
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

    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw AppError.fromException('Invalid email address. Please check and try again.');
    }
    if (password.length < 6) {
      throw AppError.fromException('Password must be at least 6 characters.');
    }

    if (_mockUserDatabase.containsKey(normalizedEmail)) {
      _currentUser = _mockUserDatabase[normalizedEmail];
      return _currentUser!;
    }

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
