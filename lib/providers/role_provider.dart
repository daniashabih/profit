import 'package:flutter/material.dart';
import '../core/enums/user_role.dart';

class RoleProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.self;

  UserRole get currentRole => _currentRole;
  bool get isSelf => _currentRole == UserRole.self;
  bool get isMember => isSelf; // Backward compatibility alias
  bool get isTrainer => _currentRole == UserRole.trainer;
  bool get isAdmin => _currentRole == UserRole.admin;

  void setRole(UserRole role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }
}
