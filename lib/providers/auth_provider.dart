import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_error.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  bool _hasOnboarded = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get hasOnboarded => _hasOnboarded;
  String? get errorMessage => _errorMessage;

  AuthProvider({required AuthService authService}) : _authService = authService {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasOnboarded = prefs.getBool(AppConstants.keyHasOnboarded) ?? false;
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = AppError.fromException(e).message;
    } finally {
      _isLoading = false;
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

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
