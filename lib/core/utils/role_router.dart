import 'package:flutter/material.dart';
import '../enums/user_role.dart';
import '../../screens/main_navigation.dart';
import '../../screens/trainer/trainer_dashboard_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';

/// Returns the primary root dashboard screen based on authenticated user role.
/// - [UserRole.self] ('self_trainer'): Opens the Self Trainer athlete experience.
/// - [UserRole.trainer] ('trainer'): Opens the Trainer coaching portal.
/// - [UserRole.admin] ('admin'): Opens the internal Admin console.
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
