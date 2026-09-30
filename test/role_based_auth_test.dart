import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/core/utils/role_router.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/models/trainer_member_model.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/services/auth_service.dart';
import 'package:profit/providers/progress_provider.dart';
import 'package:profit/repositories/progress_repository.dart';
import 'package:profit/screens/main_navigation.dart';
import 'package:profit/screens/profile/profile_screen.dart';
import 'package:profit/screens/trainer/trainer_dashboard_screen.dart';
import 'package:profit/screens/admin/admin_dashboard_screen.dart';
import 'package:profit/screens/auth/role_selection_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
  });

  group('Section 12: Role-Based Authentication & Navigation Tests', () {
    late MockAuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
      authService = MockAuthService();
      authProvider = AuthProvider(authService: authService);
    });

    test('Flow A: New Self Signup sets role = self and opens self home', () async {
      final success = await authProvider.register(
        'Self Athlete Test',
        'newself@profit.app',
        'Password123!',
        role: UserRole.self,
      );

      expect(success, isTrue);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.role, equals(UserRole.self));
      expect(authProvider.user!.role.isSelf, isTrue);
      expect(authProvider.user!.name, equals('Self Athlete Test'));

      final homeScreen = getRoleBasedHomeScreen(authProvider.user!.role);
      expect(homeScreen, isA<MainNavigation>());
    });

    test('Flow B: New Trainer Signup sets role = trainer and opens trainer dashboard', () async {
      final success = await authProvider.register(
        'Trainer Test',
        'newtrainer@profit.app',
        'Password123!',
        role: UserRole.trainer,
      );

      expect(success, isTrue);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.role, equals(UserRole.trainer));
      expect(authProvider.user!.role.isTrainer, isTrue);
      expect(authProvider.user!.trainerStatus, equals('approved'));

      final homeScreen = getRoleBasedHomeScreen(authProvider.user!.role);
      expect(homeScreen, isA<TrainerDashboardScreen>());
    });

    test('Flow C: Existing Self Login opens Self Dashboard', () async {
      final success = await authProvider.signIn('dania.shabih@profit.app', 'Password123!');

      expect(success, isTrue);
      expect(authProvider.user!.role, equals(UserRole.self));
      final screen = getRoleBasedHomeScreen(authProvider.user!.role);
      expect(screen, isA<MainNavigation>());
    });

    test('Flow D: Existing Trainer Login opens Trainer Dashboard', () async {
      final success = await authProvider.signIn('trainer@profit.app', 'Password123!');

      expect(success, isTrue);
      expect(authProvider.user!.role, equals(UserRole.trainer));
      expect(authProvider.user!.trainerProfile, isNotNull);
      expect(authProvider.user!.trainerProfile!.specialization, equals('Strength & Conditioning'));
      final screen = getRoleBasedHomeScreen(authProvider.user!.role);
      expect(screen, isA<TrainerDashboardScreen>());
    });

    test('Flow E: Existing Admin Login opens Admin Dashboard', () async {
      final success = await authProvider.signIn('admin@profit.app', 'Password123!');

      expect(success, isTrue);
      expect(authProvider.user!.role, equals(UserRole.admin));
      final screen = getRoleBasedHomeScreen(authProvider.user!.role);
      expect(screen, isA<AdminDashboardScreen>());
    });

    test('Flow F: Logout then Login again restores correct role', () async {
      // 1. Sign in as trainer
      await authProvider.signIn('trainer@profit.app', 'Password123!');
      expect(authProvider.user!.role, equals(UserRole.trainer));

      // 2. Sign out
      await authProvider.signOut();
      expect(authProvider.user, isNull);
      expect(authProvider.isAuthenticated, isFalse);

      // 3. Sign in as self
      await authProvider.signIn('dania.shabih@profit.app', 'Password123!');
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.role, equals(UserRole.self));
    });

    test('Flow G: Invalid signup displays clear validation messages', () async {
      // Invalid email
      final invalidEmailSuccess = await authProvider.register(
        'Bad Email',
        'invalid-email-address',
        'Password123!',
      );
      expect(invalidEmailSuccess, isFalse);
      expect(authProvider.errorMessage, contains('valid email'));

      // Weak password (< 6 chars)
      final weakPassSuccess = await authProvider.register(
        'Good Name',
        'valid@profit.app',
        '123',
      );
      expect(weakPassSuccess, isFalse);
      expect(authProvider.errorMessage, contains('at least 6 characters'));
    });

    test('Flow H: Legacy / existing user documents without role safely default to self', () {
      // Map with no role field at all
      final mapNoRole = {
        'id': 'legacy_01',
        'name': 'Old User',
        'email': 'old@profit.app',
      };
      final userNoRole = UserModel.fromMap(mapNoRole);
      expect(userNoRole.role, equals(UserRole.self));
      expect(userNoRole.role.isSelf, isTrue);

      // Map with null role
      final mapNullRole = {
        'id': 'legacy_02',
        'name': 'Null Role User',
        'email': 'null@profit.app',
        'role': null,
      };
      final userNullRole = UserModel.fromMap(mapNullRole);
      expect(userNullRole.role, equals(UserRole.self));

      // Map with unexpected/empty role
      final mapEmptyRole = {
        'id': 'legacy_03',
        'name': 'Empty Role User',
        'email': 'empty@profit.app',
        'role': '',
      };
      final userEmptyRole = UserModel.fromMap(mapEmptyRole);
      expect(userEmptyRole.role, equals(UserRole.self));

      // Map with legacy 'member' role string seamlessly maps to UserRole.self
      final mapLegacyMember = {
        'id': 'legacy_04',
        'name': 'Legacy Member',
        'email': 'member@profit.app',
        'role': 'member',
      };
      final userLegacyMember = UserModel.fromMap(mapLegacyMember);
      expect(userLegacyMember.role, equals(UserRole.self));
      expect(userLegacyMember.role, equals(UserRole.member)); // backward-compatibility alias
    });

    test('Flow I: Client cannot self-elevate to admin during signup', () async {
      final success = await authProvider.register(
        'Sneaky User',
        'sneaky@profit.app',
        'Password123!',
        role: UserRole.admin,
      );

      expect(success, isTrue);
      // Guard demotes unauthorized admin signup to self
      expect(authProvider.user!.role, equals(UserRole.self));
    });

    test('Section 7: Trainer-Member Relationship model serialization', () {
      final rel = TrainerMemberModel(
        id: 'rel_001',
        trainerId: 'trainer_01',
        memberId: 'member_01',
        memberName: 'Alex Rivera',
        memberEmail: 'alex@profit.app',
        status: 'active',
        assignedPlan: 'Upper/Lower Split',
        progressPercent: 0.85,
        clientWeightKg: 78.0,
        clientHeightCm: 180.0,
      );

      final map = rel.toMap();
      expect(map['trainerId'], equals('trainer_01'));
      expect(map['memberId'], equals('member_01'));
      expect(map['clientId'], equals('member_01'));
      expect(map['status'], equals('active'));
      expect(map['clientWeightKg'], equals(78.0));

      final fromMap = TrainerMemberModel.fromMap(map);
      expect(fromMap.trainerId, equals('trainer_01'));
      expect(fromMap.clientId, equals('member_01'));
      expect(fromMap.assignedPlan, equals('Upper/Lower Split'));
      expect(fromMap.clientBmi, closeTo(24.1, 0.1));
    });
  });

  group('Widget Tests: Role Selection & Trainer Dashboard UI', () {
    testWidgets('RoleSelectionScreen displays both SELF and TRAINER options', (WidgetTester tester) async {
      final authService = MockAuthService();
      final authProvider = AuthProvider(authService: authService);
      final roleProvider = RoleProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: roleProvider),
          ],
          child: const MaterialApp(
            home: RoleSelectionScreen(
              name: 'John Doe',
              email: 'john@profit.app',
              password: 'Password123!',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header Question
      expect(find.text('How do you want to use PROFIT?'), findsOneWidget);

      // Verify Option 1: SELF
      expect(find.text('SELF'), findsOneWidget);
      expect(find.text('Track your own workouts, nutrition and fitness progress.'), findsOneWidget);

      // Verify Option 2: TRAINER
      expect(find.text('TRAINER'), findsOneWidget);
      expect(find.text('Manage clients, workouts, nutrition and fitness progress.'), findsOneWidget);

      // Verify Continue Button
      expect(find.text('Continue'), findsOneWidget);

      // Tap on TRAINER to verify selection change
      await tester.tap(find.text('TRAINER'));
      await tester.pumpAndSettle();

      // Checkmark icon appears
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('TrainerDashboardScreen renders tabs, profile summary, metrics, and actions', (WidgetTester tester) async {
      final authService = MockAuthService();
      final authProvider = AuthProvider(authService: authService);
      final roleProvider = RoleProvider();

      // Set user to trainer
      await authProvider.signIn('trainer@profit.app', 'Password123!');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: roleProvider),
          ],
          child: const MaterialApp(
            home: TrainerDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Trainer Badge
      expect(find.text('TRAINER'), findsOneWidget);

      // Verify Navigation Tabs
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Plans'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Key Metrics
      expect(find.text('Total Members'), findsOneWidget);
      expect(find.text('Active Members'), findsOneWidget);
      expect(find.text('Workout Plans'), findsOneWidget);

      // Verify Quick Actions
      expect(find.text('Create Plan'), findsOneWidget);
      expect(find.text('View Members'), findsOneWidget);
      expect(find.text('Manage Plans'), findsOneWidget);
      expect(find.text('View Progress'), findsOneWidget);
    });

    testWidgets('ProfileScreen hides role badge for self users (no SELF or ROLE: SELF)', (WidgetTester tester) async {
      final authService = MockAuthService();
      final authProvider = AuthProvider(authService: authService);
      final roleProvider = RoleProvider();
      final progressProvider = ProgressProvider(progressRepo: LocalProgressRepository());

      // Sign in as standard self user (e.g. Google user)
      await authProvider.signInWithGoogle();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: roleProvider),
            ChangeNotifierProvider.value(value: progressProvider),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that neither 'SELF' nor 'ROLE: SELF' is shown
      expect(find.text('SELF'), findsNothing);
      expect(find.text('ROLE: SELF'), findsNothing);
      expect(find.text('Google User'), findsOneWidget);
    });

    testWidgets('ProfileScreen shows TRAINER and ROLE: TRAINER for trainer users', (WidgetTester tester) async {
      final authService = MockAuthService();
      final authProvider = AuthProvider(authService: authService);
      final roleProvider = RoleProvider();
      final progressProvider = ProgressProvider(progressRepo: LocalProgressRepository());

      // Register as trainer
      await authProvider.register(
        'Ahmed Khan',
        'trainer_widget_test@profit.app',
        'Password123!',
        role: UserRole.trainer,
      );
      roleProvider.setRole(UserRole.trainer);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: roleProvider),
            ChangeNotifierProvider.value(value: progressProvider),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that TRAINER and ROLE: TRAINER are shown
      expect(find.text('TRAINER'), findsOneWidget);
      expect(find.text('ROLE: TRAINER'), findsOneWidget);
      expect(find.text('Ahmed Khan'), findsOneWidget);
    });
  });
}
