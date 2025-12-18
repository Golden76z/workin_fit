import 'package:google_sign_in/google_sign_in.dart';

/// Singleton service for Google Sign-In initialization and management
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  static GoogleSignIn? _googleSignIn;

  GoogleAuthService._internal();

  factory GoogleAuthService() {
    return _instance;
  }

  /// Get or create GoogleSignIn instance with proper initialization
  GoogleSignIn getGoogleSignIn() {
    _googleSignIn ??= GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
    return _googleSignIn!;
  }

  /// Initialize GoogleSignIn instance (call this during app startup)
  void initialize() {
    _googleSignIn ??= GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
  }
}
