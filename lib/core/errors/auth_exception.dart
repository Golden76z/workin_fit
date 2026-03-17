/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AuthException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Helper class for handling Firebase Auth exceptions
class AuthErrorHandler {
  /// Convert Firebase exception code to user-friendly message
  static String handleFirebaseAuthException(String code, {String? message}) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'cancelled':
        return 'Sign-in was cancelled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return message ?? 'Authentication error occurred.';
    }
  }

  /// Convert Google Sign-In exceptions
  static String handleGoogleSignInException(dynamic exception) {
    final message = exception.toString();
    
    if (message.contains('NETWORK_ERROR') || message.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (message.contains('SIGN_IN_CANCELLED') || message.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    } else if (message.contains('SIGN_IN_CURRENTLY_IN_PROGRESS')) {
      return 'Sign-in is already in progress.';
    } else if (message.contains('DEVELOPER_ERROR') || message.contains('sign_in_failed')) {
      return 'Google Sign-In configuration error. Please check:\n'
          '• SHA-1 fingerprint is added to Firebase (Android)\n'
          '• Google provider is enabled in Firebase\n'
          '• URL scheme is configured (iOS)';
    } else if (message.contains('PlatformException')) {
      if (message.contains('sign_in_failed')) {
        return 'Google Sign-In failed. Missing SHA-1 fingerprint or Google provider not enabled.';
      }
      return 'Platform error: ${message.split('PlatformException:').last.split(',').first}';
    } else if (message.contains('SIGN_IN_REQUIRED')) {
      return 'Please sign in to your Google account first.';
    } else if (message.contains('INVALID_ACCOUNT')) {
      return 'Invalid Google account. Please try again.';
    }
    
    // Return more detailed error for debugging
    return 'Google Sign-In failed: ${message.length > 100 ? "${message.substring(0, 100)}..." : message}';
  }
}
