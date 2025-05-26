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

class TooManyRequestsAuthException implements Exception {}

class LogOutAuthException implements Exception {}
