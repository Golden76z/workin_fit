import 'package:flutter/widgets.dart';

import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/core/errors/auth_exception.dart';

/// Maps [AuthException] codes to localized, user-friendly messages.
String mapAuthErrorToMessage(BuildContext context, Object error) {
  final localizations = AppLocalizations.of(context)!;

  if (error is! AuthException) {
    return localizations.error_auth_generic;
  }

  final code = error.code;
  if (code == null || code.isEmpty) {
    return localizations.error_auth_generic;
  }

  switch (code) {
    case 'user-not-found':
      return localizations.error_auth_user_not_found;
    case 'wrong-password':
      return localizations.error_auth_wrong_password;
    case 'email-already-in-use':
      return localizations.error_auth_email_already_in_use;
    case 'invalid-email':
      return localizations.error_auth_invalid_email;
    case 'weak-password':
      return localizations.error_auth_weak_password;
    case 'user-disabled':
      return localizations.error_auth_user_disabled;
    case 'too-many-requests':
      return localizations.error_auth_too_many_requests;
    case 'operation-not-allowed':
      return localizations.error_auth_operation_not_allowed;
    case 'invalid-credential':
      return localizations.error_auth_invalid_credential;
    case 'account-exists-with-different-credential':
      return localizations.error_auth_account_exists_different;
    case 'cancelled':
      return localizations.error_auth_cancelled;
    case 'network-request-failed':
      return localizations.error_auth_network_error;
    case 'email-not-verified':
      return localizations.error_auth_email_not_verified;
    case 'sign_in_failed':
      return localizations.error_auth_google_signin_failed;
    default:
      return localizations.error_auth_generic;
  }
}

