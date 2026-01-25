import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/providers/auth_provider.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _initialized = false;
  WidgetRef? _ref;

  Future<void> initialize(WidgetRef ref) async {
    if (_initialized) return;
    _initialized = true;
    _ref = ref;

    // Handle initial link (if app was opened from a link)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink, ref);
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        if (_ref != null) {
          _handleDeepLink(uri, _ref!);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri, WidgetRef ref) {
    // Check if this is an email verification link
    // Firebase Auth email verification links contain 'mode=verifyEmail' and 'oobCode'
    final isVerificationLink = uri.queryParameters.containsKey('mode') &&
        uri.queryParameters['mode'] == 'verifyEmail' &&
        uri.queryParameters.containsKey('oobCode');
    
    if (isVerificationLink) {
      // This is an email verification link with oobCode
      final oobCode = uri.queryParameters['oobCode'];
      if (oobCode != null) {
        _verifyEmailWithCode(ref, oobCode);
      }
    } else if (uri.scheme == 'workinfit' && 
               (uri.path.contains('verify-email') || uri.host.isEmpty)) {
      // Custom scheme deep link - check if it has oobCode
      if (uri.queryParameters.containsKey('oobCode')) {
        final oobCode = uri.queryParameters['oobCode'];
        if (oobCode != null) {
          _verifyEmailWithCode(ref, oobCode);
        }
      } else {
        // No oobCode, just check verification status
        _checkEmailVerification(ref);
      }
    }
  }

  Future<void> _verifyEmailWithCode(WidgetRef ref, String oobCode) async {
    try {
      final auth = FirebaseAuth.instance;
      
      // Apply the action code to verify the email
      await auth.applyActionCode(oobCode);
      
      // Reload user to get latest verification status
      await ref.read(authActionsProvider).reloadUser();
      
      // The auth state listener in main.dart will automatically
      // redirect to WelcomePage if email is verified
      print('Email verified successfully via deep link');
    } catch (e) {
      print('Error verifying email with code: $e');
      // Even if applying the code fails, try to reload user
      // (in case verification happened on Firebase's side)
      await _checkEmailVerification(ref);
    }
  }

  Future<void> _checkEmailVerification(WidgetRef ref) async {
    try {
      // Reload user to get latest verification status
      await ref.read(authActionsProvider).reloadUser();
      
      // The auth state listener in main.dart will automatically
      // redirect to WelcomePage if email is verified
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

// Provider for DeepLinkService
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(() => service.dispose());
  return service;
});
