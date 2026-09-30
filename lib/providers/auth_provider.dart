import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_error.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  bool _hasOnboarded = false;
  String? _errorMessage;

  late final Future<void> isInitialized;
  StreamSubscription? _authSubscription;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get hasOnboarded => _hasOnboarded;
  String? get errorMessage => _errorMessage;

  AuthProvider({required AuthService authService}) : _authService = authService {
    isInitialized = _init();
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        if (_user != null) {
          _user = null;
          notifyListeners();
        }
      } else if (_user == null || _user!.id != firebaseUser.uid) {
        try {
          _user = await _authService.getCurrentUser();
          notifyListeners();
        } catch (_) {}
      }
    });
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasOnboarded = prefs.getBool(AppConstants.keyHasOnboarded) ?? false;
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
    } finally {
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    _hasOnboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasOnboarded, true);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.signInWithEmailPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.self,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.registerWithEmailPassword(
        name,
        email,
        password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrainerProfile(TrainerProfile profile) async {
    if (_user == null) return false;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.updateTrainerProfile(_user!.id, profile);
      _user = _user!.copyWith(
        trainerProfile: profile,
        gymLocation: profile.gymLocation,
        phoneNumber: profile.phoneNumber,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.signInWithApple();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateUserProfile(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Persists full profile updates to Cloud Firestore users/{uid}
  Future<bool> saveUserProfile(UserModel updated) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (Firebase.apps.isNotEmpty) {
        await FirestoreService().createUserProfile(updated);
      }
      _user = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates specific profile details and saves them to Firestore
  Future<bool> updateProfileDetails({
    String? name,
    String? goal,
    double? currentWeightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    if (_user == null) return false;
    final updated = _user!.copyWith(
      name: name ?? _user!.name,
      goal: goal ?? _user!.goal,
      currentWeightKg: currentWeightKg ?? _user!.currentWeightKg,
      heightCm: heightCm ?? _user!.heightCm,
      age: age ?? _user!.age,
      gender: gender ?? _user!.gender,
      activityLevel: activityLevel ?? _user!.activityLevel,
    );
    return saveUserProfile(updated);
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
