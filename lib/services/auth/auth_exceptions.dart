// Login exceptions
class WrongCredentialsAuthException implements Exception {}

// Register exceptions
class UsernameAlreadyTakenAuthException implements Exception {}

// Email related errors
class EmailAlreadyUsedAuthException implements Exception {}

class EmailFormatAuthException implements Exception {}

class EmailAlreadyVerifiedAuthException implements Exception {}

// Password related exceptions
class PasswordDoesntMatchAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

// Generic exceptions
class GenericAuthException implements Exception {}

class InitializationAuthException implements Exception {}

class OperationNotAllowedAuthException implements Exception {}

class UserDisabledAuthException implements Exception {}

// Other auth exceptions
class UserNotLoggedInAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class UserCancelledAuthException implements Exception {
  @override
  String toString() => 'User cancelled Google sign-in';
}

class TooManyRequestsAuthException implements Exception {
  final Duration cooldownRemaining;
  final String operationType; // e.g., 'password_reset', 'login'

  TooManyRequestsAuthException(this.cooldownRemaining, this.operationType);

  @override
  String toString() {
    final seconds = cooldownRemaining.inSeconds;
    return 'Please wait $seconds seconds before trying again';
  }

  String get formattedTime {
    final minutes = cooldownRemaining.inMinutes;
    final seconds = cooldownRemaining.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }
}

class LogOutAuthException implements Exception {}
