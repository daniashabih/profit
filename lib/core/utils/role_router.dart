import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../enums/user_role.dart';
import '../../models/user_model.dart';
import '../../screens/main_navigation.dart';
import '../../screens/trainer/trainer_dashboard_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../providers/self_trainer_cycle_provider.dart';

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

class RoleRouter {
  static void navigateToRoleHome(BuildContext context, UserModel user, {bool isSignUp = false}) {
    final role = user.role;

    if (role == UserRole.self) {
      context.read<SelfTrainerCycleProvider>().initializeForUser(user);
    }

    final destination = getRoleBasedHomeScreen(role);

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }
}
