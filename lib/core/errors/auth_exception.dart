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
    
    if (message.contains('NETWORK_ERROR')) {
      return 'Network error. Please check your connection.';
    } else if (message.contains('SIGN_IN_CANCELLED')) {
      return 'Sign-in was cancelled.';
    } else if (message.contains('SIGN_IN_CURRENTLY_IN_PROGRESS')) {
      return 'Sign-in is already in progress.';
    } else if (message.contains('DEVELOPER_ERROR')) {
      return 'Developer error. Please configure Google Sign-In properly.';
    }
    
    return 'Google Sign-In failed. Please try again.';
  }
}
