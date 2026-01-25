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
  String get terms_of_service_title => 'Terms of Service';

  @override
  String terms_of_service_last_updated(String date) {
    return 'Last Updated: $date';
  }

  @override
  String get terms_of_service_intro =>
      'Welcome to Workin Fit. By accessing or using our app, you agree to be bound by these Terms of Service.';

  @override
  String get terms_of_service_section_1_title => '1. Acceptance of Terms';

  @override
  String get terms_of_service_section_1_content =>
      'By creating an account and using Workin Fit, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service and our Privacy Policy.';

  @override
  String get terms_of_service_section_2_title => '2. Use of Service';

  @override
  String get terms_of_service_section_2_content =>
      'You agree to use Workin Fit only for lawful purposes and in accordance with these Terms. You are responsible for maintaining the confidentiality of your account credentials.';

  @override
  String get terms_of_service_section_3_title => '3. User Accounts';

  @override
  String get terms_of_service_section_3_content =>
      'You are responsible for all activities that occur under your account. You must provide accurate and complete information when creating an account and keep your account information updated.';

  @override
  String get terms_of_service_section_4_title => '4. Health and Safety';

  @override
  String get terms_of_service_section_4_content =>
      'Workin Fit provides fitness information and workout programs for informational purposes only. Consult with a healthcare professional before beginning any exercise program. You assume all risks associated with your use of the app.';

  @override
  String get terms_of_service_section_5_title => '5. Intellectual Property';

  @override
  String get terms_of_service_section_5_content =>
      'All content, features, and functionality of Workin Fit are owned by us and are protected by copyright, trademark, and other intellectual property laws.';

  @override
  String get terms_of_service_section_6_title => '6. Limitation of Liability';

  @override
  String get terms_of_service_section_6_content =>
      'Workin Fit shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the app.';

  @override
  String get terms_of_service_section_7_title => '7. Changes to Terms';

  @override
  String get terms_of_service_section_7_content =>
      'We reserve the right to modify these Terms of Service at any time. Your continued use of the app after any changes constitutes acceptance of the new terms.';

  @override
  String get terms_of_service_contact =>
      'If you have any questions about these Terms, please contact us.';

  @override
  String get privacy_policy_title => 'Privacy Policy';

  @override
  String privacy_policy_last_updated(String date) {
    return 'Last Updated: $date';
  }

  @override
  String get privacy_policy_intro =>
      'At Workin Fit, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.';

  @override
  String get privacy_policy_section_1_title => '1. Information We Collect';

  @override
  String get privacy_policy_section_1_content =>
      'We collect information that you provide directly to us, including your name, email address, username, and profile information. We also collect workout data, exercise history, and fitness goals that you input into the app.';

  @override
  String get privacy_policy_section_2_title => '2. How We Use Your Information';

  @override
  String get privacy_policy_section_2_content =>
      'We use the information we collect to provide, maintain, and improve our services, personalize your experience, track your fitness progress, and communicate with you about your account and our services.';

  @override
  String get privacy_policy_section_3_title =>
      '3. Information Sharing and Disclosure';

  @override
  String get privacy_policy_section_3_content =>
      'We do not sell your personal information. We may share your information only with your consent, to comply with legal obligations, or to protect our rights and the safety of our users.';

  @override
  String get privacy_policy_section_4_title => '4. Data Security';

  @override
  String get privacy_policy_section_4_content =>
      'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.';

  @override
  String get privacy_policy_section_5_title => '5. Your Rights and Choices';

  @override
  String get privacy_policy_section_5_content =>
      'You have the right to access, update, or delete your personal information at any time through your account settings. You can also opt out of certain data collection practices.';

  @override
  String get privacy_policy_section_6_title => '6. Children\'s Privacy';

  @override
  String get privacy_policy_section_6_content =>
      'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child, please contact us immediately.';

  @override
  String get privacy_policy_section_7_title =>
      '7. Changes to This Privacy Policy';

  @override
  String get privacy_policy_section_7_content =>
      'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date.';

  @override
  String get privacy_policy_contact =>
      'If you have any questions about this Privacy Policy, please contact us.';

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
