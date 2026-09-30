import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profit/providers/auth_provider.dart';
import 'package:profit/providers/role_provider.dart';
import 'package:profit/services/auth_service.dart';
import 'package:profit/widgets/auth/auth_widgets.dart';
import 'package:profit/screens/auth/sign_in_screen.dart';
import 'package:profit/screens/auth/sign_up_screen.dart';
import 'package:profit/screens/auth/forgot_password_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'profit_has_onboarded': true});
  });

  Widget wrapInApp(Widget child, {AuthProvider? authProvider, RoleProvider? roleProvider}) {
    final mockAuth = MockAuthService();
    final auth = authProvider ?? AuthProvider(authService: mockAuth);
    final role = roleProvider ?? RoleProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<RoleProvider>.value(value: role),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Reusable Auth Components Tests', () {
    testWidgets('AppTextField renders label, hint, and handles input', (tester) async {
      final controller = TextEditingController();
      String submittedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              label: 'Test Label',
              hintText: 'Test Hint',
              prefixIcon: Icons.email,
              onSubmitted: (val) => submittedText = val,
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'hello@profit.app');
      expect(controller.text, 'hello@profit.app');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedText, 'hello@profit.app');
    });

    testWidgets('PasswordField toggles obscureText and changes icon', (tester) async {
      final controller = TextEditingController(text: 'secret_pass');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordField(
              controller: controller,
              label: 'User Password',
            ),
          ),
        ),
      );

      expect(find.text('User Password'), findsOneWidget);
      // Initially obscure
      final initialEditableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(initialEditableText.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap toggle to show password
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      final revealedEditableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(revealedEditableText.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap toggle again to hide password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      final hiddenEditableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(hiddenEditableText.obscureText, isTrue);
    });

    testWidgets('PrimaryButton displays text, handles clicks, and shows loader when isLoading', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Submit Workout',
              isLoading: false,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Workout'), findsOneWidget);
      await tester.tap(find.text('Submit Workout'));
      expect(tapped, isTrue);

      // When loading
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Submit Workout',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Workout'), findsNothing);
    });

    testWidgets('LoadingButton performs async action with loading state', (tester) async {
      int executedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              text: 'Async Action',
              onPressedAsync: () async {
                await Future.delayed(const Duration(milliseconds: 50));
                executedCount++;
              },
            ),
          ),
        ),
      );

      expect(find.text('Async Action'), findsOneWidget);
      await tester.tap(find.text('Async Action'));
      await tester.pump(const Duration(milliseconds: 10));

      // In loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(executedCount, 1);
      expect(find.text('Async Action'), findsOneWidget);
    });

    testWidgets('AuthHeader renders title, subtitle, and logo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(
              title: 'Welcome Champion',
              subtitle: 'Ready to crush today’s routine?',
              showLogo: true,
            ),
          ),
        ),
      );

      expect(find.text('Welcome Champion'), findsOneWidget);
      expect(find.text('Ready to crush today’s routine?'), findsOneWidget);
      expect(find.text('PRO'), findsWidgets);
      expect(find.text('FIT'), findsWidgets);
    });

    testWidgets('ErrorMessage converts raw Firebase exception strings to clean friendly text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorMessage(
              error: 'FirebaseAuthException: invalid-credential',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Incorrect email or password. Please verify your details.'), findsOneWidget);
      expect(find.textContaining('FirebaseAuthException'), findsNothing);
    });
  });

  group('Complete Auth Flow & UX Tests', () {
    testWidgets('SignInScreen responds to invalid email and empty inputs without overflow', (tester) async {
      // Set to small phone screen dimensions (e.g. 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapInApp(const SignInScreen()));
      await tester.pumpAndSettle();

      // Ensure zero overflow on small phone screen
      expect(tester.takeException(), isNull);

      // Tap Sign In with empty fields
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'name@example.com'), 'not-an-email');
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('SignUpScreen allows selecting Self Trainer vs Trainer role', (tester) async {
      await tester.pumpWidget(wrapInApp(const SignUpScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Self Trainer'), findsOneWidget);
      expect(find.text('Trainer'), findsOneWidget);

      // Tap Trainer role card
      await tester.tap(find.text('Trainer'));
      await tester.pumpAndSettle();

      // Tap Self Trainer role card
      await tester.tap(find.text('Self Trainer'));
      await tester.pumpAndSettle();

      // Enter mismatched passwords
      await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Alex Rivera'), 'Alex Runner');
      await tester.enterText(find.widgetWithText(TextFormField, 'name@example.com'), 'alex@profit.app');
      await tester.enterText(find.widgetWithText(TextFormField, 'Minimum 6 characters'), 'Password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Re-enter your password'), 'MismatchPass');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen transitions to success state and allows retry', (tester) async {
      await tester.pumpWidget(wrapInApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      // Form validation on empty submit
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Valid email entry
      await tester.enterText(find.byType(TextFormField), 'recovery@profit.app');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Password Reset Email Sent'), findsOneWidget);
      expect(find.textContaining('recovery@profit.app'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);

      // Tap "Didn't receive the email? Try again" to return to form
      await tester.tap(find.text('Didn\'t receive the email? Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password 🔑'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });
  });
}
