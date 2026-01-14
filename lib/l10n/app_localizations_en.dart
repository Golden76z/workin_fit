// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get auth_page_register_button => 'Register';

  @override
  String get auth_page_register_confirm_password_input => 'Confirm password';

  @override
  String get auth_page_register_description =>
      'Start your fitness journey with us!';

  @override
  String get auth_page_register_email_input => 'Email';

  @override
  String get auth_page_register_or_text => 'or';

  @override
  String get auth_page_register_password_input => 'Password';

  @override
  String get auth_page_register_title => 'Create Account';

  @override
  String get auth_page_register_username_input => 'Username';

  @override
  String get welcome_page_app_title => 'Workin Fit';

  @override
  String get welcome_page_choose_language => 'Choose language';

  @override
  String get welcome_page_language_confirmation_button => 'Confirm';

  @override
  String get welcome_page_language_english => 'English';

  @override
  String get welcome_page_language_french => 'French';

  @override
  String get welcome_page_register_button => 'Register';

  @override
  String get auth_register_username_hint => 'Choose a username';

  @override
  String get auth_register_email_hint => 'Enter your email';

  @override
  String get auth_register_password_hint => 'Create a strong password';

  @override
  String get auth_register_confirm_password_hint => 'Confirm your password';

  @override
  String get auth_register_validation_username_required =>
      'Please enter a username';

  @override
  String auth_register_validation_username_min(int minLength) {
    return 'Username must be at least $minLength characters';
  }

  @override
  String auth_register_validation_username_max(int maxLength) {
    return 'Username must be at most $maxLength characters';
  }

  @override
  String get auth_register_validation_email_required =>
      'Please enter your email';

  @override
  String get auth_register_validation_email_invalid =>
      'Please enter a valid email';

  @override
  String get auth_register_validation_password_required =>
      'Please enter a password';

  @override
  String auth_register_validation_password_min(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get auth_register_validation_password_uppercase =>
      'Must contain an uppercase letter';

  @override
  String get auth_register_validation_password_number =>
      'Must contain a number';

  @override
  String get auth_register_validation_password_match =>
      'Passwords do not match';

  @override
  String get auth_register_dialog_verify_title => 'Verify Your Email';

  @override
  String get auth_register_dialog_verify_content =>
      'A verification email has been sent to your inbox. Please verify your email address before logging in.';

  @override
  String get auth_register_dialog_verify_button => 'Got it';

  @override
  String get auth_register_terms_text =>
      'By creating an account, you agree to our\nTerms of Service and Privacy Policy';

  @override
  String get auth_login_label => 'Login';

  @override
  String get auth_login_email_label => 'Email';

  @override
  String get auth_login_email_hint => 'Enter your email';

  @override
  String get auth_login_password_label => 'Password';

  @override
  String get auth_login_password_hint => 'Enter your password';

  @override
  String get auth_login_forgot_password => 'Forgot Password?';

  @override
  String get auth_login_validation_email_required => 'Please enter your email';

  @override
  String get auth_login_validation_email_invalid =>
      'Please enter a valid email';

  @override
  String get auth_login_validation_password_required =>
      'Please enter your password';

  @override
  String get auth_login_or_text => 'OR';

  @override
  String get auth_login_social_google => 'Continue with Google';

  @override
  String get auth_login_social_apple => 'Continue with Apple';

  @override
  String get auth_login_forgot_dialog_title => 'Reset Password';

  @override
  String auth_login_forgot_dialog_content(String email) {
    return 'Send a password reset email to $email?';
  }

  @override
  String get auth_login_forgot_dialog_cancel => 'Cancel';

  @override
  String get auth_login_forgot_dialog_send => 'Send';

  @override
  String get auth_login_forgot_dialog_email_required =>
      'Please enter your email address first';

  @override
  String get auth_login_forgot_dialog_success => 'Password reset email sent!';

  @override
  String get auth_tab_register => 'Register';

  @override
  String get auth_tab_login => 'Login';

  @override
  String get email_verification_title => 'Verify Your Email';

  @override
  String get email_verification_sent_to =>
      'We\'ve sent a verification email to:';

  @override
  String get email_verification_instructions =>
      'Please check your inbox and click the verification link to activate your account.';

  @override
  String get email_verification_button_checking => 'Checking...';

  @override
  String get email_verification_button_verified => 'I\'ve Verified My Email';

  @override
  String get email_verification_resend => 'Resend Verification Email';

  @override
  String get email_verification_sign_out => 'Sign Out';

  @override
  String get email_verification_success => 'Email verified successfully!';

  @override
  String get email_verification_not_verified =>
      'Email not verified yet. Please check your inbox.';

  @override
  String get email_verification_resend_title => 'Verification Email Sent';

  @override
  String email_verification_resend_content(String email) {
    return 'A new verification email has been sent to $email. Please check your inbox.';
  }

  @override
  String get email_verification_resend_button => 'OK';

  @override
  String email_verification_error_signout(String error) {
    return 'Error signing out: $error';
  }

  @override
  String get error_auth_user_not_found => 'No user found with this email.';

  @override
  String get error_auth_wrong_password => 'Wrong password. Please try again.';

  @override
  String get error_auth_email_already_in_use =>
      'An account already exists with this email.';

  @override
  String get error_auth_invalid_email => 'Invalid email address.';

  @override
  String get error_auth_weak_password =>
      'Password is too weak. Use at least 8 characters.';

  @override
  String get error_auth_user_disabled => 'This account has been disabled.';

  @override
  String get error_auth_too_many_requests =>
      'Too many attempts. Please try again later.';

  @override
  String get error_auth_operation_not_allowed =>
      'This sign-in method is not enabled.';

  @override
  String get error_auth_invalid_credential =>
      'Invalid credentials. Please try again.';

  @override
  String get error_auth_account_exists_different =>
      'An account already exists with this email using a different sign-in method.';

  @override
  String get error_auth_cancelled => 'Sign-in was cancelled.';

  @override
  String get error_auth_network_error =>
      'Network error. Please check your connection.';

  @override
  String get error_auth_generic => 'Authentication error occurred.';

  @override
  String get error_auth_google_signin_failed =>
      'Google Sign-In failed. Please try again.';

  @override
  String get error_auth_google_network =>
      'Network error. Please check your connection.';

  @override
  String get error_auth_google_cancelled => 'Sign-in was cancelled.';

  @override
  String get error_auth_google_in_progress => 'Sign-in is already in progress.';

  @override
  String get error_auth_google_developer =>
      'Developer error. Please configure Google Sign-In properly.';

  @override
  String get error_auth_email_not_verified =>
      'Email not verified. Please check your inbox.';
}
