import 'package:firebase_auth/firebase_auth.dart';

/// Centralized user-friendly error representation for PROFIT.
/// Maps low-level Firebase, network, and database errors into clear, actionable messages.
class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  /// Factory parser that translates Firebase Auth, Firestore, and platform exceptions
  /// into user-friendly strings without leaking internal stack traces.
  factory AppError.fromException(dynamic error) {
    if (error is AppError) return error;

    // Handle FirebaseAuthException directly by error code
    if (error is FirebaseAuthException) {
      switch (error.code.toLowerCase()) {
        case 'invalid-email':
          return const AppError(
            message: 'Please enter a valid email address.',
            code: 'invalid-email',
          );
        case 'user-disabled':
          return const AppError(
            message: 'This account has been disabled. Please contact PROFIT support.',
            code: 'user-disabled',
          );
        case 'user-not-found':
          return const AppError(
            message: 'No account found with this email address. Please sign up.',
            code: 'user-not-found',
          );
        case 'wrong-password':
          return const AppError(
            message: 'Incorrect password. Please verify your details.',
            code: 'wrong-password',
          );
        case 'invalid-credential':
          return const AppError(
            message: 'Incorrect email or password. Please verify your details.',
            code: 'invalid-credential',
          );
        case 'email-already-in-use':
          return const AppError(
            message: 'An account with this email address already exists. Please log in instead.',
            code: 'email-already-in-use',
          );
        case 'operation-not-allowed':
          return const AppError(
            message: 'Email & password sign-in is not enabled. Please contact support.',
            code: 'operation-not-allowed',
          );
        case 'weak-password':
          return const AppError(
            message: 'Password must be at least 6 characters long.',
            code: 'weak-password',
          );
        case 'network-request-failed':
          return const AppError(
            message: 'Unable to connect to the server. Please check your internet connection.',
            code: 'network-request-failed',
          );
        case 'too-many-requests':
          return const AppError(
            message: 'Too many attempts. Please wait a few moments and try again.',
            code: 'too-many-requests',
          );
      }
    }

    final raw = error.toString().toLowerCase();

    // Firebase Auth & Common String Matching
    if (raw.contains('invalid-email') || raw.contains('invalid email')) {
      return const AppError(
        message: 'Please enter a valid email address.',
        code: 'invalid-email',
      );
    }

    if (raw.contains('email-already-in-use') ||
        raw.contains('already exists') ||
        raw.contains('email already in use')) {
      return const AppError(
        message: 'An account with this email address already exists. Please log in instead.',
        code: 'email-already-in-use',
      );
    }

    if (raw.contains('weak-password') ||
        raw.contains('password is too weak') ||
        raw.contains('at least 6 characters')) {
      return const AppError(
        message: 'Password must be at least 6 characters long.',
        code: 'weak-password',
      );
    }

    if (raw.contains('wrong-password') ||
        raw.contains('user-not-found') ||
        raw.contains('invalid-credential') ||
        raw.contains('invalid login credentials')) {
      return const AppError(
        message: 'Incorrect email or password. Please verify your details.',
        code: 'invalid-credentials',
      );
    }

    if (raw.contains('network-request-failed') ||
        raw.contains('socketexception') ||
        raw.contains('clientexception') ||
        raw.contains('network failure')) {
      return const AppError(
        message: 'Unable to connect to the server. Please check your internet connection.',
        code: 'network-error',
      );
    }

    if (raw.contains('user-disabled')) {
      return const AppError(
        message: 'This account has been disabled. Please contact PROFIT support.',
        code: 'user-disabled',
      );
    }

    if (raw.contains('too-many-requests')) {
      return const AppError(
        message: 'Too many attempts. Please wait a few moments and try again.',
        code: 'too-many-requests',
      );
    }

    if (raw.contains('permission-denied') || raw.contains('unauthorized')) {
      return const AppError(
        message: 'You do not have permission to perform this action.',
        code: 'permission-denied',
      );
    }

    // Default cleaned exception
    String cleanMsg = error.toString();
    if (cleanMsg.startsWith('Exception: ')) {
      cleanMsg = cleanMsg.substring('Exception: '.length);
    }

    return AppError(
      message: cleanMsg.isNotEmpty ? cleanMsg : 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }

  @override
  String toString() => message;
}
