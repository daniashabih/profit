import 'package:flutter/material.dart';
import '../enums/user_role.dart';
import '../../screens/main_navigation.dart';
import '../../screens/trainer/trainer_dashboard_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';

/// Returns the primary root dashboard screen based on authenticated user role.
/// - [UserRole.self]: Opens the SELF athlete experience (workout tracking, nutrition, profile).
/// - [UserRole.trainer]: Opens the TRAINER coach experience (client management, program design).
/// - [UserRole.admin]: Opens the internal ADMIN console.
Widget getRoleBasedHomeScreen(UserRole role) {
  switch (role) {
    case UserRole.self:
      return const MainNavigation();
    case UserRole.trainer:
      return const TrainerDashboardScreen();
    case UserRole.admin:
      return const AdminDashboardScreen();
  }
}
