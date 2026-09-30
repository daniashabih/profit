import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit/core/enums/user_role.dart';
import 'package:profit/core/errors/app_error.dart';
import 'package:profit/models/user_model.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/services/auth_service.dart';
import 'package:profit/screens/auth/sign_in_screen.dart';
import 'package:profit/screens/auth/sign_up_screen.dart';
import 'package:profit/screens/auth/forgot_password_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
  });

  group('Production Authentication System - Unit & Domain Tests', () {
    late MockAuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      authService = MockAuthService();
      authProvider = AuthProvider(authService: authService);
    });

    test('User registration creates profile with self_trainer role and Firestore fields', () async {
      final success = await authProvider.register(
        'Jordan Smith',
        'jordan@profit.app',
        'Secret123!',
        role: UserRole.self,
      );

      expect(success, isTrue);
      final user = authProvider.user;
      expect(user, isNotNull);
      expect(user!.fullName, equals('Jordan Smith'));
      expect(user.name, equals('Jordan Smith'));
      expect(user.email, equals('jordan@profit.app'));
      expect(user.role, equals(UserRole.self));
      expect(user.role.isSelfTrainer, isTrue);

      // Verify Firestore payload format
      final firestoreMap = user.toFirestoreMap();
      expect(firestoreMap['role'], equals('self_trainer'));
      expect(firestoreMap['fullName'], equals('Jordan Smith'));
      expect(firestoreMap['uid'], isNotEmpty);
      expect(firestoreMap['createdAt'], isNotEmpty);
      expect(firestoreMap['updatedAt'], isNotEmpty);
    });

    test('UserModel.fromMap parses role "self_trainer" into UserRole.self', () {
      final json = {
        'uid': 'usr_firestore_999',
        'fullName': 'Avery Lee',
        'name': 'Avery Lee',
        'email': 'avery@profit.app',
        'role': 'self_trainer',
        'profileImage': 'https://profit.app/avatar.jpg',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final parsedUser = UserModel.fromMap(json);
      expect(parsedUser.id, equals('usr_firestore_999'));
      expect(parsedUser.uid, equals('usr_firestore_999'));
      expect(parsedUser.fullName, equals('Avery Lee'));
      expect(parsedUser.profileImage, equals('https://profit.app/avatar.jpg'));
      expect(parsedUser.role, equals(UserRole.self));
      expect(parsedUser.role.isSelfTrainer, isTrue);
    });

    test('AppError translates raw technical exception strings to user-friendly messages', () {
      final errEmailInUse = AppError.fromException('FirebaseAuthException: email-already-in-use');
      expect(errEmailInUse.message, contains('already exists'));

      final errInvalidEmail = AppError.fromException('invalid-email address provided');
      expect(errInvalidEmail.message, contains('valid email address'));

      final errWeakPassword = AppError.fromException('weak-password exception');
      expect(errWeakPassword.message, contains('at least 6 characters'));

      final errInvalidCredentials = AppError.fromException('invalid-credential');
      expect(errInvalidCredentials.message, contains('Incorrect email or password'));

      final errNetwork = AppError.fromException('network-request-failed');
      expect(errNetwork.message, contains('internet connection'));
    });

    test('Sign Out clears user and authentication state', () async {
      await authProvider.signIn('dania.shabih@profit.app', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });

    test('Forgot Password service triggers reset email', () async {
      final success = await authProvider.sendPasswordReset('dania.shabih@profit.app');
      expect(success, isTrue);
    });
  });

  group('Production Authentication System - UI & Widget Tests', () {
    late MockAuthService authService;
    late AuthProvider authProvider;
    late RoleProvider roleProvider;

    setUp(() {
      authService = MockAuthService();
      authProvider = AuthProvider(authService: authService);
      roleProvider = RoleProvider();
    });

    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<RoleProvider>.value(value: roleProvider),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('SignInScreen renders all fields, toggles, and CTAs', (tester) async {
      await tester.pumpWidget(createTestApp(const SignInScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders fields, role cards, and validates input', (tester) async {
      await tester.pumpWidget(createTestApp(const SignUpScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Create Account 🚀'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Self Trainer'), findsOneWidget);
      expect(find.text('Trainer'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Tap submit with empty fields to trigger validation
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders input, back link, and success message on submit', (tester) async {
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Reset Password 🔑'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      // Enter valid email and submit
      await tester.enterText(find.byType(TextFormField), 'athlete@profit.app');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Password Reset Email Sent'), findsOneWidget);
      expect(find.textContaining('Password reset email has been sent'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });
  });
}
