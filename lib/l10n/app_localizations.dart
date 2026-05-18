import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The text of the button to send the form
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_page_register_button;

  /// Input hint for the confirmation of the password text input in the register page
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get auth_page_register_confirm_password_input;

  /// Little message under the title
  ///
  /// In en, this message translates to:
  /// **'Start your fitness journey with us!'**
  String get auth_page_register_description;

  /// Input hint for the email text input in the register page
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_page_register_email_input;

  /// The "or" text under the register button splitting the traditional register from the google/apple authentication
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get auth_page_register_or_text;

  /// Input input for the password text input in the register page
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_page_register_password_input;

  /// Create account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_page_register_title;

  /// Input hint for the username text input in the register page
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get auth_page_register_username_input;

  /// The title app on the welcome page
  ///
  /// In en, this message translates to:
  /// **'Workin Fit'**
  String get welcome_page_app_title;

  /// The choose language button on welcome page
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get welcome_page_choose_language;

  /// The confirmation button on the language selection page
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get welcome_page_language_confirmation_button;

  /// The english on the language selection page
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get welcome_page_language_english;

  /// The french on the language selection page
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get welcome_page_language_french;

  /// The register button on the welcome page
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get welcome_page_register_button;

  /// No description provided for @auth_register_username_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get auth_register_username_hint;

  /// No description provided for @auth_register_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get auth_register_email_hint;

  /// No description provided for @auth_register_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get auth_register_password_hint;

  /// No description provided for @auth_register_confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get auth_register_confirm_password_hint;

  /// No description provided for @auth_register_validation_username_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get auth_register_validation_username_required;

  /// No description provided for @auth_register_validation_username_min.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {minLength} characters'**
  String auth_register_validation_username_min(int minLength);

  /// No description provided for @auth_register_validation_username_max.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most {maxLength} characters'**
  String auth_register_validation_username_max(int maxLength);

  /// No description provided for @auth_register_validation_email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get auth_register_validation_email_required;

  /// No description provided for @auth_register_validation_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get auth_register_validation_email_invalid;

  /// No description provided for @auth_register_validation_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get auth_register_validation_password_required;

  /// No description provided for @auth_register_validation_password_min.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters'**
  String auth_register_validation_password_min(int minLength);

  /// No description provided for @auth_register_validation_password_uppercase.
  ///
  /// In en, this message translates to:
  /// **'Must contain an uppercase letter'**
  String get auth_register_validation_password_uppercase;

  /// No description provided for @auth_register_validation_password_number.
  ///
  /// In en, this message translates to:
  /// **'Must contain a number'**
  String get auth_register_validation_password_number;

  /// No description provided for @auth_register_validation_password_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_register_validation_password_match;

  /// No description provided for @auth_register_dialog_verify_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get auth_register_dialog_verify_title;

  /// No description provided for @auth_register_dialog_verify_content.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your inbox. Please verify your email address before logging in.'**
  String get auth_register_dialog_verify_content;

  /// No description provided for @auth_register_dialog_verify_button.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get auth_register_dialog_verify_button;

  /// No description provided for @auth_register_terms_text.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our\nTerms of Service and Privacy Policy'**
  String get auth_register_terms_text;

  /// No description provided for @auth_register_terms_prefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our\n'**
  String get auth_register_terms_prefix;

  /// No description provided for @auth_register_terms_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get auth_register_terms_and;

  /// Title of the Terms of Service page
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service_title;

  /// Last updated date for terms of service
  ///
  /// In en, this message translates to:
  /// **'Last Updated: {date}'**
  String terms_of_service_last_updated(String date);

  /// No description provided for @terms_of_service_intro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Workin Fit. By accessing or using our app, you agree to be bound by these Terms of Service.'**
  String get terms_of_service_intro;

  /// No description provided for @terms_of_service_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get terms_of_service_section_1_title;

  /// No description provided for @terms_of_service_section_1_content.
  ///
  /// In en, this message translates to:
  /// **'By creating an account and using Workin Fit, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service and our Privacy Policy.'**
  String get terms_of_service_section_1_content;

  /// No description provided for @terms_of_service_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Use of Service'**
  String get terms_of_service_section_2_title;

  /// No description provided for @terms_of_service_section_2_content.
  ///
  /// In en, this message translates to:
  /// **'You agree to use Workin Fit only for lawful purposes and in accordance with these Terms. You are responsible for maintaining the confidentiality of your account credentials.'**
  String get terms_of_service_section_2_content;

  /// No description provided for @terms_of_service_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. User Accounts'**
  String get terms_of_service_section_3_title;

  /// No description provided for @terms_of_service_section_3_content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for all activities that occur under your account. You must provide accurate and complete information when creating an account and keep your account information updated.'**
  String get terms_of_service_section_3_content;

  /// No description provided for @terms_of_service_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Health and Safety'**
  String get terms_of_service_section_4_title;

  /// No description provided for @terms_of_service_section_4_content.
  ///
  /// In en, this message translates to:
  /// **'Workin Fit provides fitness information and workout programs for informational purposes only. Consult with a healthcare professional before beginning any exercise program. You assume all risks associated with your use of the app.'**
  String get terms_of_service_section_4_content;

  /// No description provided for @terms_of_service_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Intellectual Property'**
  String get terms_of_service_section_5_title;

  /// No description provided for @terms_of_service_section_5_content.
  ///
  /// In en, this message translates to:
  /// **'All content, features, and functionality of Workin Fit are owned by us and are protected by copyright, trademark, and other intellectual property laws.'**
  String get terms_of_service_section_5_content;

  /// No description provided for @terms_of_service_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Limitation of Liability'**
  String get terms_of_service_section_6_title;

  /// No description provided for @terms_of_service_section_6_content.
  ///
  /// In en, this message translates to:
  /// **'Workin Fit shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the app.'**
  String get terms_of_service_section_6_content;

  /// No description provided for @terms_of_service_section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to Terms'**
  String get terms_of_service_section_7_title;

  /// No description provided for @terms_of_service_section_7_content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these Terms of Service at any time. Your continued use of the app after any changes constitutes acceptance of the new terms.'**
  String get terms_of_service_section_7_content;

  /// No description provided for @terms_of_service_contact.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms, please contact us.'**
  String get terms_of_service_contact;

  /// Title of the Privacy Policy page
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// Last updated date for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Last Updated: {date}'**
  String privacy_policy_last_updated(String date);

  /// No description provided for @privacy_policy_intro.
  ///
  /// In en, this message translates to:
  /// **'At Workin Fit, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'**
  String get privacy_policy_intro;

  /// No description provided for @privacy_policy_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacy_policy_section_1_title;

  /// No description provided for @privacy_policy_section_1_content.
  ///
  /// In en, this message translates to:
  /// **'We collect information that you provide directly to us, including your name, email address, username, and profile information. We also collect workout data, exercise history, and fitness goals that you input into the app.'**
  String get privacy_policy_section_1_content;

  /// No description provided for @privacy_policy_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacy_policy_section_2_title;

  /// No description provided for @privacy_policy_section_2_content.
  ///
  /// In en, this message translates to:
  /// **'We use the information we collect to provide, maintain, and improve our services, personalize your experience, track your fitness progress, and communicate with you about your account and our services.'**
  String get privacy_policy_section_2_content;

  /// No description provided for @privacy_policy_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Information Sharing and Disclosure'**
  String get privacy_policy_section_3_title;

  /// No description provided for @privacy_policy_section_3_content.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal information. We may share your information only with your consent, to comply with legal obligations, or to protect our rights and the safety of our users.'**
  String get privacy_policy_section_3_content;

  /// No description provided for @privacy_policy_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Security'**
  String get privacy_policy_section_4_title;

  /// No description provided for @privacy_policy_section_4_content.
  ///
  /// In en, this message translates to:
  /// **'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.'**
  String get privacy_policy_section_4_content;

  /// No description provided for @privacy_policy_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights and Choices'**
  String get privacy_policy_section_5_title;

  /// No description provided for @privacy_policy_section_5_content.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, update, or delete your personal information at any time through your account settings. You can also opt out of certain data collection practices.'**
  String get privacy_policy_section_5_content;

  /// No description provided for @privacy_policy_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Children\'s Privacy'**
  String get privacy_policy_section_6_title;

  /// No description provided for @privacy_policy_section_6_content.
  ///
  /// In en, this message translates to:
  /// **'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child, please contact us immediately.'**
  String get privacy_policy_section_6_content;

  /// No description provided for @privacy_policy_section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to This Privacy Policy'**
  String get privacy_policy_section_7_title;

  /// No description provided for @privacy_policy_section_7_content.
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date.'**
  String get privacy_policy_section_7_content;

  /// No description provided for @privacy_policy_contact.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us.'**
  String get privacy_policy_contact;

  /// Little message under the title on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue your fitness journey.'**
  String get auth_page_login_description;

  /// The text of the button to send the login form
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_page_login_button;

  /// No description provided for @auth_login_label.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login_label;

  /// No description provided for @auth_login_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_login_email_label;

  /// No description provided for @auth_login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get auth_login_email_hint;

  /// No description provided for @auth_login_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_login_password_label;

  /// No description provided for @auth_login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get auth_login_password_hint;

  /// No description provided for @auth_login_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_login_forgot_password;

  /// No description provided for @auth_login_validation_email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get auth_login_validation_email_required;

  /// No description provided for @auth_login_validation_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get auth_login_validation_email_invalid;

  /// No description provided for @auth_login_validation_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get auth_login_validation_password_required;

  /// No description provided for @auth_login_or_text.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get auth_login_or_text;

  /// No description provided for @auth_login_social_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_login_social_google;

  /// No description provided for @auth_login_social_apple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get auth_login_social_apple;

  /// No description provided for @auth_login_forgot_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get auth_login_forgot_dialog_title;

  /// No description provided for @auth_login_forgot_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Send a password reset email to {email}?'**
  String auth_login_forgot_dialog_content(String email);

  /// No description provided for @auth_login_forgot_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get auth_login_forgot_dialog_cancel;

  /// No description provided for @auth_login_forgot_dialog_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get auth_login_forgot_dialog_send;

  /// No description provided for @auth_login_forgot_dialog_email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get auth_login_forgot_dialog_email_required;

  /// No description provided for @auth_login_forgot_dialog_success.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get auth_login_forgot_dialog_success;

  /// No description provided for @auth_tab_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_tab_register;

  /// No description provided for @auth_tab_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_tab_login;

  /// No description provided for @email_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get email_verification_title;

  /// No description provided for @email_verification_sent_to.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification email to:'**
  String get email_verification_sent_to;

  /// No description provided for @email_verification_instructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to activate your account.'**
  String get email_verification_instructions;

  /// No description provided for @email_verification_button_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get email_verification_button_checking;

  /// No description provided for @email_verification_button_verified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get email_verification_button_verified;

  /// No description provided for @email_verification_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get email_verification_resend;

  /// No description provided for @email_verification_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get email_verification_sign_out;

  /// No description provided for @email_verification_success.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get email_verification_success;

  /// No description provided for @email_verification_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get email_verification_not_verified;

  /// No description provided for @email_verification_resend_title.
  ///
  /// In en, this message translates to:
  /// **'Verification Email Sent'**
  String get email_verification_resend_title;

  /// No description provided for @email_verification_resend_content.
  ///
  /// In en, this message translates to:
  /// **'A new verification email has been sent to {email}. Please check your inbox.'**
  String email_verification_resend_content(String email);

  /// No description provided for @email_verification_resend_button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get email_verification_resend_button;

  /// No description provided for @email_verification_error_signout.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String email_verification_error_signout(String error);

  /// No description provided for @email_verification_check_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Check verification status'**
  String get email_verification_check_tooltip;

  /// No description provided for @error_auth_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get error_auth_user_not_found;

  /// No description provided for @error_auth_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please try again.'**
  String get error_auth_wrong_password;

  /// No description provided for @error_auth_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email.'**
  String get error_auth_email_already_in_use;

  /// No description provided for @error_auth_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get error_auth_invalid_email;

  /// No description provided for @error_auth_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters.'**
  String get error_auth_weak_password;

  /// No description provided for @error_auth_user_disabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get error_auth_user_disabled;

  /// No description provided for @error_auth_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get error_auth_too_many_requests;

  /// No description provided for @error_auth_operation_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled.'**
  String get error_auth_operation_not_allowed;

  /// No description provided for @error_auth_invalid_credential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please try again.'**
  String get error_auth_invalid_credential;

  /// No description provided for @error_auth_account_exists_different.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email using a different sign-in method.'**
  String get error_auth_account_exists_different;

  /// No description provided for @error_auth_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get error_auth_cancelled;

  /// No description provided for @error_auth_network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_auth_network_error;

  /// No description provided for @error_auth_generic.
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred.'**
  String get error_auth_generic;

  /// No description provided for @error_auth_google_signin_failed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get error_auth_google_signin_failed;

  /// No description provided for @error_auth_google_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_auth_google_network;

  /// No description provided for @error_auth_google_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get error_auth_google_cancelled;

  /// No description provided for @error_auth_google_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is already in progress.'**
  String get error_auth_google_in_progress;

  /// No description provided for @error_auth_google_developer.
  ///
  /// In en, this message translates to:
  /// **'Developer error. Please configure Google Sign-In properly.'**
  String get error_auth_google_developer;

  /// No description provided for @error_auth_email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified. Please check your inbox.'**
  String get error_auth_email_not_verified;

  /// No description provided for @home_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get home_welcome_title;

  /// No description provided for @home_placeholder_title.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get home_placeholder_title;

  /// No description provided for @home_placeholder_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your fitness journey starts here'**
  String get home_placeholder_subtitle;

  /// No description provided for @home_user_fallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get home_user_fallback;

  /// No description provided for @home_preview_front.
  ///
  /// In en, this message translates to:
  /// **'FRONT'**
  String get home_preview_front;

  /// No description provided for @home_preview_back.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get home_preview_back;

  /// No description provided for @home_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get home_logout;

  /// No description provided for @sessions_create_success.
  ///
  /// In en, this message translates to:
  /// **'Session created!'**
  String get sessions_create_success;

  /// No description provided for @sessions_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String sessions_error_generic(String error);

  /// No description provided for @sessions_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get sessions_create_title;

  /// No description provided for @sessions_name_label.
  ///
  /// In en, this message translates to:
  /// **'Session Name'**
  String get sessions_name_label;

  /// No description provided for @sessions_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save Session'**
  String get sessions_save_button;

  /// No description provided for @sessions_list_title.
  ///
  /// In en, this message translates to:
  /// **'My Sessions'**
  String get sessions_list_title;

  /// No description provided for @home_tab_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_tab_home;

  /// No description provided for @home_tab_sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get home_tab_sessions;

  /// No description provided for @home_tab_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get home_tab_lab;

  /// No description provided for @home_tab_programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get home_tab_programs;

  /// No description provided for @home_tab_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get home_tab_profile;

  /// No description provided for @home_placeholder_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get home_placeholder_coming_soon;

  /// No description provided for @workout_state_no_exercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this session.'**
  String get workout_state_no_exercises;

  /// No description provided for @workout_state_load_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercises: {error}'**
  String workout_state_load_error(String error);

  /// No description provided for @workout_phase_get_ready.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get workout_phase_get_ready;

  /// No description provided for @workout_phase_exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get workout_phase_exercise;

  /// No description provided for @workout_phase_finished.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get workout_phase_finished;

  /// No description provided for @workout_hint_tap_pause.
  ///
  /// In en, this message translates to:
  /// **'Tap timer to pause'**
  String get workout_hint_tap_pause;

  /// No description provided for @workout_hint_tap_resume.
  ///
  /// In en, this message translates to:
  /// **'Tap timer to resume'**
  String get workout_hint_tap_resume;

  /// No description provided for @workout_hint_tap_start.
  ///
  /// In en, this message translates to:
  /// **'Tap timer to start'**
  String get workout_hint_tap_start;

  /// No description provided for @workout_current_label.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get workout_current_label;

  /// No description provided for @workout_next_label.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get workout_next_label;

  /// No description provided for @workout_final_exercise.
  ///
  /// In en, this message translates to:
  /// **'Final exercise in progress.'**
  String get workout_final_exercise;

  /// No description provided for @workout_tips_fallback.
  ///
  /// In en, this message translates to:
  /// **'Keep your core engaged and move with control.'**
  String get workout_tips_fallback;

  /// No description provided for @workout_unnamed_exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise {index}'**
  String workout_unnamed_exercise(int index);

  /// No description provided for @exercise_push_001_name.
  ///
  /// In en, this message translates to:
  /// **'Push-up'**
  String get exercise_push_001_name;

  /// No description provided for @exercise_push_001_description.
  ///
  /// In en, this message translates to:
  /// **'Classic bodyweight exercise targeting chest, shoulders, and triceps. Start in plank position, lower body until chest nearly touches floor, then push back up.'**
  String get exercise_push_001_description;

  /// No description provided for @exercise_push_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with knee push-ups if full push-ups are too difficult. Keep your core tight and body in a straight line.'**
  String get exercise_push_001_beginner_tips;

  /// No description provided for @exercise_push_002_name.
  ///
  /// In en, this message translates to:
  /// **'Incline Push-up'**
  String get exercise_push_002_name;

  /// No description provided for @exercise_push_002_description.
  ///
  /// In en, this message translates to:
  /// **'Easier variation of push-up performed with hands elevated on a chair or wall. Reduces bodyweight load, perfect for beginners.'**
  String get exercise_push_002_description;

  /// No description provided for @exercise_push_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Place hands on a sturdy chair or wall. The higher the surface, the easier the exercise.'**
  String get exercise_push_002_beginner_tips;

  /// No description provided for @exercise_push_005_name.
  ///
  /// In en, this message translates to:
  /// **'Wide Push-up'**
  String get exercise_push_005_name;

  /// No description provided for @exercise_push_005_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up with hands placed wider than shoulder-width. Targets outer chest and shoulders more than standard push-up.'**
  String get exercise_push_005_description;

  /// No description provided for @exercise_push_005_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Place hands wider than shoulder-width apart. Keep elbows slightly flared out during movement.'**
  String get exercise_push_005_beginner_tips;

  /// No description provided for @exercise_push_007_name.
  ///
  /// In en, this message translates to:
  /// **'Wall Push-up'**
  String get exercise_push_007_name;

  /// No description provided for @exercise_push_007_description.
  ///
  /// In en, this message translates to:
  /// **'Beginner-friendly push-up performed standing against a wall. Perfect for those building upper body strength.'**
  String get exercise_push_007_description;

  /// No description provided for @exercise_push_007_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Stand facing wall, place hands on wall at shoulder height. Step back to increase difficulty.'**
  String get exercise_push_007_beginner_tips;

  /// No description provided for @exercise_push_008_name.
  ///
  /// In en, this message translates to:
  /// **'Knee Push-up'**
  String get exercise_push_008_name;

  /// No description provided for @exercise_push_008_description.
  ///
  /// In en, this message translates to:
  /// **'Modified push-up performed on knees instead of toes. Reduces bodyweight load significantly.'**
  String get exercise_push_008_description;

  /// No description provided for @exercise_push_008_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep your body straight from knees to head. Don\'t let your hips sag or rise too high.'**
  String get exercise_push_008_beginner_tips;

  /// No description provided for @exercise_push_015_name.
  ///
  /// In en, this message translates to:
  /// **'Wall Sit'**
  String get exercise_push_015_name;

  /// No description provided for @exercise_push_015_description.
  ///
  /// In en, this message translates to:
  /// **'Isometric leg exercise performed against a wall. Builds quadriceps and glute endurance.'**
  String get exercise_push_015_description;

  /// No description provided for @exercise_push_015_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Slide down wall until thighs are parallel to floor. Hold position with back flat against wall.'**
  String get exercise_push_015_beginner_tips;

  /// No description provided for @exercise_pull_001_name.
  ///
  /// In en, this message translates to:
  /// **'Inverted Row'**
  String get exercise_pull_001_name;

  /// No description provided for @exercise_pull_001_description.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight rowing exercise using a table or sturdy surface. Excellent for building back and bicep strength without equipment.'**
  String get exercise_pull_001_description;

  /// No description provided for @exercise_pull_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a sturdy table or chair. Keep body straight, pull chest to surface. Adjust angle to change difficulty.'**
  String get exercise_pull_001_beginner_tips;

  /// No description provided for @exercise_pull_002_name.
  ///
  /// In en, this message translates to:
  /// **'Superman'**
  String get exercise_pull_002_name;

  /// No description provided for @exercise_pull_002_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise targeting lower back and glutes. Lie face down, lift arms and legs simultaneously, hold briefly.'**
  String get exercise_pull_002_description;

  /// No description provided for @exercise_pull_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lift only as high as comfortable. Focus on squeezing glutes and lower back muscles.'**
  String get exercise_pull_002_beginner_tips;

  /// No description provided for @exercise_pull_003_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Snow Angels'**
  String get exercise_pull_003_name;

  /// No description provided for @exercise_pull_003_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise where you move arms in snow angel motion. Strengthens posterior deltoids and upper back.'**
  String get exercise_pull_003_description;

  /// No description provided for @exercise_pull_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep arms straight and lift them off the ground. Move slowly and controlled through full range of motion.'**
  String get exercise_pull_003_beginner_tips;

  /// No description provided for @exercise_pull_004_name.
  ///
  /// In en, this message translates to:
  /// **'Y-T-W Raises'**
  String get exercise_pull_004_name;

  /// No description provided for @exercise_pull_004_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise series forming Y, T, and W shapes with arms. Targets entire upper back and rear deltoids.'**
  String get exercise_pull_004_description;

  /// No description provided for @exercise_pull_004_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Perform each letter shape separately. Keep core engaged and avoid arching lower back excessively.'**
  String get exercise_pull_004_beginner_tips;

  /// No description provided for @exercise_pull_005_name.
  ///
  /// In en, this message translates to:
  /// **'Wall Angels'**
  String get exercise_pull_005_name;

  /// No description provided for @exercise_pull_005_description.
  ///
  /// In en, this message translates to:
  /// **'Standing exercise against wall mimicking snow angels. Improves posture and strengthens upper back muscles.'**
  String get exercise_pull_005_description;

  /// No description provided for @exercise_pull_005_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep back, head, and arms in contact with wall. Move slowly and maintain contact throughout movement.'**
  String get exercise_pull_005_beginner_tips;

  /// No description provided for @exercise_pull_006_name.
  ///
  /// In en, this message translates to:
  /// **'Prone Y Raise'**
  String get exercise_pull_006_name;

  /// No description provided for @exercise_pull_006_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise lifting arms in Y position. Targets upper traps and rear deltoids.'**
  String get exercise_pull_006_description;

  /// No description provided for @exercise_pull_006_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lift arms at 45-degree angle. Squeeze shoulder blades together at the top.'**
  String get exercise_pull_006_beginner_tips;

  /// No description provided for @exercise_pull_007_name.
  ///
  /// In en, this message translates to:
  /// **'Prone T Raise'**
  String get exercise_pull_007_name;

  /// No description provided for @exercise_pull_007_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise lifting arms straight out to sides forming T shape. Strengthens rear deltoids and mid traps.'**
  String get exercise_pull_007_description;

  /// No description provided for @exercise_pull_007_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep arms straight and lift them parallel to ground. Focus on squeezing shoulder blades.'**
  String get exercise_pull_007_beginner_tips;

  /// No description provided for @exercise_pull_008_name.
  ///
  /// In en, this message translates to:
  /// **'Prone W Raise'**
  String get exercise_pull_008_name;

  /// No description provided for @exercise_pull_008_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise with arms bent forming W shape. Targets rhomboids and rear deltoids.'**
  String get exercise_pull_008_description;

  /// No description provided for @exercise_pull_008_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Bend elbows and lift arms, squeezing shoulder blades together. Keep core engaged.'**
  String get exercise_pull_008_beginner_tips;

  /// No description provided for @exercise_pull_010_name.
  ///
  /// In en, this message translates to:
  /// **'Scapular Wall Slides'**
  String get exercise_pull_010_name;

  /// No description provided for @exercise_pull_010_description.
  ///
  /// In en, this message translates to:
  /// **'Posture exercise performed against wall. Strengthens upper back and improves shoulder mobility.'**
  String get exercise_pull_010_description;

  /// No description provided for @exercise_pull_010_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep back, head, and arms against wall. Slide arms up and down while maintaining contact.'**
  String get exercise_pull_010_beginner_tips;

  /// No description provided for @exercise_pull_015_name.
  ///
  /// In en, this message translates to:
  /// **'Doorway Row'**
  String get exercise_pull_015_name;

  /// No description provided for @exercise_pull_015_description.
  ///
  /// In en, this message translates to:
  /// **'Rowing exercise using doorway frame. Stand in doorway, pull body toward frame using back muscles.'**
  String get exercise_pull_015_description;

  /// No description provided for @exercise_pull_015_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use sturdy doorway. Place hands on frame, lean back, and pull body forward. Adjust angle for difficulty.'**
  String get exercise_pull_015_beginner_tips;

  /// No description provided for @exercise_pull_018_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Fly'**
  String get exercise_pull_018_name;

  /// No description provided for @exercise_pull_018_description.
  ///
  /// In en, this message translates to:
  /// **'Prone exercise mimicking reverse fly motion. Strengthens rear deltoids and upper back without weights.'**
  String get exercise_pull_018_description;

  /// No description provided for @exercise_pull_018_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lie face down, lift arms out to sides. Squeeze shoulder blades together at the top.'**
  String get exercise_pull_018_beginner_tips;

  /// No description provided for @exercise_legs_001_name.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Squat'**
  String get exercise_legs_001_name;

  /// No description provided for @exercise_legs_001_description.
  ///
  /// In en, this message translates to:
  /// **'Fundamental lower body exercise. Stand with feet shoulder-width, lower down as if sitting in chair, then stand back up.'**
  String get exercise_legs_001_description;

  /// No description provided for @exercise_legs_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep knees tracking over toes. Lower until thighs are parallel to floor or as low as comfortable.'**
  String get exercise_legs_001_beginner_tips;

  /// No description provided for @exercise_legs_005_name.
  ///
  /// In en, this message translates to:
  /// **'Forward Lunge'**
  String get exercise_legs_005_name;

  /// No description provided for @exercise_legs_005_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral leg exercise stepping forward. Targets quads, glutes, and improves balance.'**
  String get exercise_legs_005_description;

  /// No description provided for @exercise_legs_005_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Step forward, lower back knee toward ground. Keep front knee over ankle. Push back to start.'**
  String get exercise_legs_005_beginner_tips;

  /// No description provided for @exercise_legs_006_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Lunge'**
  String get exercise_legs_006_name;

  /// No description provided for @exercise_legs_006_description.
  ///
  /// In en, this message translates to:
  /// **'Lunge variation stepping backward. Easier on knees and emphasizes glutes more than forward lunge.'**
  String get exercise_legs_006_description;

  /// No description provided for @exercise_legs_006_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Step backward, lower down until both knees form 90-degree angles. Push back to start position.'**
  String get exercise_legs_006_beginner_tips;

  /// No description provided for @exercise_legs_009_name.
  ///
  /// In en, this message translates to:
  /// **'Side Lunge'**
  String get exercise_legs_009_name;

  /// No description provided for @exercise_legs_009_description.
  ///
  /// In en, this message translates to:
  /// **'Lateral lunge variation stepping to the side. Targets inner thighs and improves hip mobility.'**
  String get exercise_legs_009_description;

  /// No description provided for @exercise_legs_009_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Step to the side, lower down keeping other leg straight. Push back to center. Alternate sides.'**
  String get exercise_legs_009_beginner_tips;

  /// No description provided for @exercise_legs_010_name.
  ///
  /// In en, this message translates to:
  /// **'Calf Raise'**
  String get exercise_legs_010_name;

  /// No description provided for @exercise_legs_010_description.
  ///
  /// In en, this message translates to:
  /// **'Isolated calf exercise. Stand on balls of feet, rise up onto toes, then lower down slowly.'**
  String get exercise_legs_010_description;

  /// No description provided for @exercise_legs_010_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Rise up as high as possible, hold briefly, then lower slowly. Can be done on floor or elevated surface.'**
  String get exercise_legs_010_beginner_tips;

  /// No description provided for @exercise_legs_012_name.
  ///
  /// In en, this message translates to:
  /// **'Glute Bridge'**
  String get exercise_legs_012_name;

  /// No description provided for @exercise_legs_012_description.
  ///
  /// In en, this message translates to:
  /// **'Hip extension exercise targeting glutes and hamstrings. Lie on back, lift hips up, squeeze glutes.'**
  String get exercise_legs_012_description;

  /// No description provided for @exercise_legs_012_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep feet flat on floor, lift hips until body forms straight line. Squeeze glutes at the top.'**
  String get exercise_legs_012_beginner_tips;

  /// No description provided for @exercise_legs_014_name.
  ///
  /// In en, this message translates to:
  /// **'Donkey Kicks'**
  String get exercise_legs_014_name;

  /// No description provided for @exercise_legs_014_description.
  ///
  /// In en, this message translates to:
  /// **'Quadruped exercise targeting glutes. Start on hands and knees, kick one leg back and up.'**
  String get exercise_legs_014_description;

  /// No description provided for @exercise_legs_014_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep core engaged and back straight. Lift leg without arching lower back. Squeeze glute at top.'**
  String get exercise_legs_014_beginner_tips;

  /// No description provided for @exercise_legs_015_name.
  ///
  /// In en, this message translates to:
  /// **'Fire Hydrants'**
  String get exercise_legs_015_name;

  /// No description provided for @exercise_legs_015_description.
  ///
  /// In en, this message translates to:
  /// **'Quadruped exercise lifting leg to the side. Targets glutes and hip abductors.'**
  String get exercise_legs_015_description;

  /// No description provided for @exercise_legs_015_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start on hands and knees. Lift leg out to side, keeping knee bent. Don\'t rotate hips.'**
  String get exercise_legs_015_beginner_tips;

  /// No description provided for @exercise_legs_016_name.
  ///
  /// In en, this message translates to:
  /// **'Clamshells'**
  String get exercise_legs_016_name;

  /// No description provided for @exercise_legs_016_description.
  ///
  /// In en, this message translates to:
  /// **'Side-lying exercise targeting hip abductors and glutes. Lie on side, lift top knee while keeping feet together.'**
  String get exercise_legs_016_description;

  /// No description provided for @exercise_legs_016_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep feet together, lift only the knee. Don\'t roll backward. Move slowly and controlled.'**
  String get exercise_legs_016_beginner_tips;

  /// No description provided for @exercise_legs_017_name.
  ///
  /// In en, this message translates to:
  /// **'Leg Raises'**
  String get exercise_legs_017_name;

  /// No description provided for @exercise_legs_017_description.
  ///
  /// In en, this message translates to:
  /// **'Core and hip flexor exercise. Lie on back, lift legs straight up, then lower down slowly.'**
  String get exercise_legs_017_description;

  /// No description provided for @exercise_legs_017_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep lower back pressed to floor. Lower legs only as far as you can maintain back contact.'**
  String get exercise_legs_017_beginner_tips;

  /// No description provided for @exercise_legs_020_name.
  ///
  /// In en, this message translates to:
  /// **'Step-up'**
  String get exercise_legs_020_name;

  /// No description provided for @exercise_legs_020_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral leg exercise using chair or step. Step up onto surface, then step back down.'**
  String get exercise_legs_020_description;

  /// No description provided for @exercise_legs_020_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use sturdy chair or step. Place entire foot on surface. Push through heel to step up.'**
  String get exercise_legs_020_beginner_tips;

  /// No description provided for @exercise_legs_021_name.
  ///
  /// In en, this message translates to:
  /// **'Sumo Squat'**
  String get exercise_legs_021_name;

  /// No description provided for @exercise_legs_021_description.
  ///
  /// In en, this message translates to:
  /// **'Wide-stance squat variation. Targets inner thighs and glutes more than standard squat.'**
  String get exercise_legs_021_description;

  /// No description provided for @exercise_legs_021_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Stand with feet wider than shoulder-width, toes pointed slightly out. Lower down, keeping knees tracking over toes.'**
  String get exercise_legs_021_beginner_tips;

  /// No description provided for @exercise_core_001_name.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get exercise_core_001_name;

  /// No description provided for @exercise_core_001_description.
  ///
  /// In en, this message translates to:
  /// **'Fundamental core exercise. Hold body in straight line supported by forearms and toes. Builds core strength and stability.'**
  String get exercise_core_001_description;

  /// No description provided for @exercise_core_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep body straight from head to heels. Don\'t let hips sag or rise. Start with 20-30 seconds.'**
  String get exercise_core_001_beginner_tips;

  /// No description provided for @exercise_core_002_name.
  ///
  /// In en, this message translates to:
  /// **'Side Plank'**
  String get exercise_core_002_name;

  /// No description provided for @exercise_core_002_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral core exercise performed on side. Targets obliques and improves lateral stability.'**
  String get exercise_core_002_description;

  /// No description provided for @exercise_core_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Support body on one forearm and side of foot. Keep body straight. Start with 15-20 seconds per side.'**
  String get exercise_core_002_beginner_tips;

  /// No description provided for @exercise_core_004_name.
  ///
  /// In en, this message translates to:
  /// **'Bicycle Crunches'**
  String get exercise_core_004_name;

  /// No description provided for @exercise_core_004_description.
  ///
  /// In en, this message translates to:
  /// **'Rotational core exercise mimicking bicycle motion. Targets abs and obliques effectively.'**
  String get exercise_core_004_description;

  /// No description provided for @exercise_core_004_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lie on back, bring opposite elbow to knee. Extend other leg. Move slowly and controlled.'**
  String get exercise_core_004_beginner_tips;

  /// No description provided for @exercise_core_005_name.
  ///
  /// In en, this message translates to:
  /// **'Russian Twists'**
  String get exercise_core_005_name;

  /// No description provided for @exercise_core_005_description.
  ///
  /// In en, this message translates to:
  /// **'Seated rotational exercise targeting obliques. Sit with knees bent, lean back slightly, rotate torso side to side.'**
  String get exercise_core_005_description;

  /// No description provided for @exercise_core_005_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep core engaged and back straight. Rotate from torso, not just arms. Start without weight.'**
  String get exercise_core_005_beginner_tips;

  /// No description provided for @exercise_core_006_name.
  ///
  /// In en, this message translates to:
  /// **'Flutter Kicks'**
  String get exercise_core_006_name;

  /// No description provided for @exercise_core_006_description.
  ///
  /// In en, this message translates to:
  /// **'Core exercise performed lying on back. Alternately kick legs up and down while keeping core engaged.'**
  String get exercise_core_006_description;

  /// No description provided for @exercise_core_006_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep lower back pressed to floor. Move legs in small, controlled motions. Don\'t arch back.'**
  String get exercise_core_006_beginner_tips;

  /// No description provided for @exercise_core_007_name.
  ///
  /// In en, this message translates to:
  /// **'Dead Bug'**
  String get exercise_core_007_name;

  /// No description provided for @exercise_core_007_description.
  ///
  /// In en, this message translates to:
  /// **'Core stability exercise performed on back. Extend opposite arm and leg while maintaining core engagement.'**
  String get exercise_core_007_description;

  /// No description provided for @exercise_core_007_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep lower back pressed to floor. Move slowly and controlled. Alternate opposite arm and leg.'**
  String get exercise_core_007_beginner_tips;

  /// No description provided for @exercise_core_008_name.
  ///
  /// In en, this message translates to:
  /// **'Bird Dog'**
  String get exercise_core_008_name;

  /// No description provided for @exercise_core_008_description.
  ///
  /// In en, this message translates to:
  /// **'Quadruped core stability exercise. Extend opposite arm and leg while maintaining balance.'**
  String get exercise_core_008_description;

  /// No description provided for @exercise_core_008_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start on hands and knees. Extend opposite arm and leg. Hold briefly, then switch sides.'**
  String get exercise_core_008_beginner_tips;

  /// No description provided for @exercise_core_011_name.
  ///
  /// In en, this message translates to:
  /// **'Toe Touches'**
  String get exercise_core_011_name;

  /// No description provided for @exercise_core_011_description.
  ///
  /// In en, this message translates to:
  /// **'Core exercise reaching for toes. Lie on back, lift legs and reach hands toward toes.'**
  String get exercise_core_011_description;

  /// No description provided for @exercise_core_011_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep legs as straight as possible. Lift shoulders off ground. Reach up, not forward.'**
  String get exercise_core_011_beginner_tips;

  /// No description provided for @exercise_core_012_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Crunches'**
  String get exercise_core_012_name;

  /// No description provided for @exercise_core_012_description.
  ///
  /// In en, this message translates to:
  /// **'Core exercise lifting hips. Lie on back, bring knees toward chest, lift hips off ground.'**
  String get exercise_core_012_description;

  /// No description provided for @exercise_core_012_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep knees bent. Lift hips by contracting abs, not by swinging legs. Lower slowly.'**
  String get exercise_core_012_beginner_tips;

  /// No description provided for @exercise_cardio_001_name.
  ///
  /// In en, this message translates to:
  /// **'Jumping Jacks'**
  String get exercise_cardio_001_name;

  /// No description provided for @exercise_cardio_001_description.
  ///
  /// In en, this message translates to:
  /// **'Classic full-body cardio exercise. Jump feet apart while raising arms overhead, then return.'**
  String get exercise_cardio_001_description;

  /// No description provided for @exercise_cardio_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start slowly to master coordination. Land softly on balls of feet. Can be done low-impact by stepping instead of jumping.'**
  String get exercise_cardio_001_beginner_tips;

  /// No description provided for @exercise_cardio_002_name.
  ///
  /// In en, this message translates to:
  /// **'High Knees'**
  String get exercise_cardio_002_name;

  /// No description provided for @exercise_cardio_002_description.
  ///
  /// In en, this message translates to:
  /// **'Running in place bringing knees up high. Excellent cardio exercise that also improves coordination.'**
  String get exercise_cardio_002_description;

  /// No description provided for @exercise_cardio_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Run in place, bringing knees up toward chest. Pump arms naturally. Start with 20-30 seconds.'**
  String get exercise_cardio_002_beginner_tips;

  /// No description provided for @exercise_cardio_003_name.
  ///
  /// In en, this message translates to:
  /// **'Butt Kicks'**
  String get exercise_cardio_003_name;

  /// No description provided for @exercise_cardio_003_description.
  ///
  /// In en, this message translates to:
  /// **'Running in place kicking heels toward glutes. Targets hamstrings while providing cardio benefits.'**
  String get exercise_cardio_003_description;

  /// No description provided for @exercise_cardio_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Run in place, kick heels up toward glutes. Keep knees pointing down. Start with 20-30 seconds.'**
  String get exercise_cardio_003_beginner_tips;

  /// No description provided for @exercise_cardio_009_name.
  ///
  /// In en, this message translates to:
  /// **'Shadow Boxing'**
  String get exercise_cardio_009_name;

  /// No description provided for @exercise_cardio_009_description.
  ///
  /// In en, this message translates to:
  /// **'Cardio exercise mimicking boxing movements. Throw punches in air, combining cardio with coordination.'**
  String get exercise_cardio_009_description;

  /// No description provided for @exercise_cardio_009_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Throw jabs, crosses, hooks, and uppercuts. Keep moving, don\'t stop between punches. 30-60 seconds rounds.'**
  String get exercise_cardio_009_beginner_tips;

  /// No description provided for @exercise_cardio_010_name.
  ///
  /// In en, this message translates to:
  /// **'Jump Rope (No Rope)'**
  String get exercise_cardio_010_name;

  /// No description provided for @exercise_cardio_010_description.
  ///
  /// In en, this message translates to:
  /// **'Mimic jump rope motion without equipment. Jump lightly on balls of feet, rotating wrists as if holding rope.'**
  String get exercise_cardio_010_description;

  /// No description provided for @exercise_cardio_010_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Jump lightly on balls of feet. Rotate wrists as if holding rope. Start with 20-30 seconds.'**
  String get exercise_cardio_010_beginner_tips;

  /// No description provided for @exercise_cardio_014_name.
  ///
  /// In en, this message translates to:
  /// **'Dancing in Place'**
  String get exercise_cardio_014_name;

  /// No description provided for @exercise_cardio_014_description.
  ///
  /// In en, this message translates to:
  /// **'Fun cardio exercise moving to music. Freestyle dance movements to get heart rate up.'**
  String get exercise_cardio_014_description;

  /// No description provided for @exercise_cardio_014_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Move your body to music. Include arm movements, leg lifts, and hip movements. Have fun!'**
  String get exercise_cardio_014_beginner_tips;

  /// No description provided for @exercise_push_003_name.
  ///
  /// In en, this message translates to:
  /// **'Decline Push-up'**
  String get exercise_push_003_name;

  /// No description provided for @exercise_push_003_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced push-up variation with feet elevated on a chair. Increases difficulty by shifting more weight to upper body.'**
  String get exercise_push_003_description;

  /// No description provided for @exercise_push_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with a low elevation and gradually increase. Ensure the chair is stable and won\'t slide.'**
  String get exercise_push_003_beginner_tips;

  /// No description provided for @exercise_push_004_name.
  ///
  /// In en, this message translates to:
  /// **'Diamond Push-up'**
  String get exercise_push_004_name;

  /// No description provided for @exercise_push_004_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up variation with hands forming a diamond shape. Emphasizes triceps and inner chest muscles.'**
  String get exercise_push_004_description;

  /// No description provided for @exercise_push_004_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with regular push-ups to build strength. Place thumbs and index fingers together to form diamond.'**
  String get exercise_push_004_beginner_tips;

  /// No description provided for @exercise_push_006_name.
  ///
  /// In en, this message translates to:
  /// **'Pike Push-up'**
  String get exercise_push_006_name;

  /// No description provided for @exercise_push_006_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up performed in downward dog position. Excellent for building shoulder strength and preparing for handstand push-ups.'**
  String get exercise_push_006_description;

  /// No description provided for @exercise_push_006_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with feet wider apart for better balance. Lower head toward floor between hands, then push back up.'**
  String get exercise_push_006_beginner_tips;

  /// No description provided for @exercise_push_010_name.
  ///
  /// In en, this message translates to:
  /// **'Hindu Push-up'**
  String get exercise_push_010_name;

  /// No description provided for @exercise_push_010_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic push-up variation with flowing movement. Combines strength training with mobility work.'**
  String get exercise_push_010_description;

  /// No description provided for @exercise_push_010_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in downward dog, lower into upward dog position, then return. Focus on smooth, controlled movement.'**
  String get exercise_push_010_beginner_tips;

  /// No description provided for @exercise_push_011_name.
  ///
  /// In en, this message translates to:
  /// **'Spiderman Push-up'**
  String get exercise_push_011_name;

  /// No description provided for @exercise_push_011_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up variation where you bring knee to elbow during the lowering phase. Adds core engagement and hip mobility.'**
  String get exercise_push_011_description;

  /// No description provided for @exercise_push_011_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with regular push-ups. Add the knee movement once you\'re comfortable with the base exercise.'**
  String get exercise_push_011_beginner_tips;

  /// No description provided for @exercise_push_012_name.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Tap Push-up'**
  String get exercise_push_012_name;

  /// No description provided for @exercise_push_012_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up variation where you tap opposite shoulder at the top of each rep. Challenges stability and core strength.'**
  String get exercise_push_012_description;

  /// No description provided for @exercise_push_012_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular push-ups first. Keep your hips level and avoid rotating your body when tapping.'**
  String get exercise_push_012_beginner_tips;

  /// No description provided for @exercise_push_013_name.
  ///
  /// In en, this message translates to:
  /// **'Tricep Dips'**
  String get exercise_push_013_name;

  /// No description provided for @exercise_push_013_description.
  ///
  /// In en, this message translates to:
  /// **'Upper body exercise using a chair. Targets triceps, shoulders, and chest. Sit on edge of chair, lower body, then push up.'**
  String get exercise_push_013_description;

  /// No description provided for @exercise_push_013_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep feet closer to chair for easier variation. Ensure chair is stable and won\'t tip over.'**
  String get exercise_push_013_beginner_tips;

  /// No description provided for @exercise_push_014_name.
  ///
  /// In en, this message translates to:
  /// **'Diamond Tricep Dips'**
  String get exercise_push_014_name;

  /// No description provided for @exercise_push_014_description.
  ///
  /// In en, this message translates to:
  /// **'Tricep dips with hands close together in diamond position. Increases tricep emphasis and difficulty.'**
  String get exercise_push_014_description;

  /// No description provided for @exercise_push_014_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular tricep dips first. Place hands close together with fingers pointing forward.'**
  String get exercise_push_014_beginner_tips;

  /// No description provided for @exercise_push_020_name.
  ///
  /// In en, this message translates to:
  /// **'Dive Bomber Push-up'**
  String get exercise_push_020_name;

  /// No description provided for @exercise_push_020_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic push-up variation combining downward dog, low push-up, and upward dog positions in one fluid motion.'**
  String get exercise_push_020_description;

  /// No description provided for @exercise_push_020_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start slowly to master the movement pattern. Focus on smooth transitions between positions.'**
  String get exercise_push_020_beginner_tips;

  /// No description provided for @exercise_pull_009_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Plank'**
  String get exercise_pull_009_name;

  /// No description provided for @exercise_pull_009_description.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight exercise performed face-up. Strengthens posterior chain including back, glutes, and hamstrings.'**
  String get exercise_pull_009_description;

  /// No description provided for @exercise_pull_009_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with bent knees and gradually straighten legs as you get stronger. Keep hips lifted.'**
  String get exercise_pull_009_beginner_tips;

  /// No description provided for @exercise_pull_011_name.
  ///
  /// In en, this message translates to:
  /// **'Isometric Pull Hold'**
  String get exercise_pull_011_name;

  /// No description provided for @exercise_pull_011_description.
  ///
  /// In en, this message translates to:
  /// **'Static hold exercise mimicking pull-up position. Builds grip strength and back endurance.'**
  String get exercise_pull_011_description;

  /// No description provided for @exercise_pull_011_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Hang from a bar or sturdy surface. Hold chin over bar as long as possible. Use assistance if needed.'**
  String get exercise_pull_011_beginner_tips;

  /// No description provided for @exercise_pull_012_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Plank Walk'**
  String get exercise_pull_012_name;

  /// No description provided for @exercise_pull_012_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic reverse plank variation. Walk hands backward while maintaining reverse plank position.'**
  String get exercise_pull_012_description;

  /// No description provided for @exercise_pull_012_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with small steps. Keep hips elevated and body straight throughout movement.'**
  String get exercise_pull_012_beginner_tips;

  /// No description provided for @exercise_pull_013_name.
  ///
  /// In en, this message translates to:
  /// **'Single Arm Row'**
  String get exercise_pull_013_name;

  /// No description provided for @exercise_pull_013_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral rowing exercise using bodyweight. Can be performed with towel or resistance band if available.'**
  String get exercise_pull_013_description;

  /// No description provided for @exercise_pull_013_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a towel wrapped around a door handle or sturdy anchor. Pull with one arm, focusing on squeezing back muscles.'**
  String get exercise_pull_013_beginner_tips;

  /// No description provided for @exercise_pull_014_name.
  ///
  /// In en, this message translates to:
  /// **'Towel Row'**
  String get exercise_pull_014_name;

  /// No description provided for @exercise_pull_014_description.
  ///
  /// In en, this message translates to:
  /// **'Rowing exercise using a towel for grip. Wrap towel around door handle or sturdy anchor and row.'**
  String get exercise_pull_014_description;

  /// No description provided for @exercise_pull_014_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Ensure door or anchor is secure. Adjust distance to change difficulty. Closer = easier, farther = harder.'**
  String get exercise_pull_014_beginner_tips;

  /// No description provided for @exercise_pull_016_name.
  ///
  /// In en, this message translates to:
  /// **'Australian Pull-up'**
  String get exercise_pull_016_name;

  /// No description provided for @exercise_pull_016_description.
  ///
  /// In en, this message translates to:
  /// **'Horizontal pulling exercise using table or bar. Body positioned horizontally, pull chest to surface.'**
  String get exercise_pull_016_description;

  /// No description provided for @exercise_pull_016_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use sturdy table or low bar. Keep body straight. Higher surface = easier, lower = harder.'**
  String get exercise_pull_016_beginner_tips;

  /// No description provided for @exercise_pull_017_name.
  ///
  /// In en, this message translates to:
  /// **'Pull-up Negative'**
  String get exercise_pull_017_name;

  /// No description provided for @exercise_pull_017_description.
  ///
  /// In en, this message translates to:
  /// **'Eccentric phase of pull-up. Jump or step up to top position, then lower slowly. Builds strength for full pull-ups.'**
  String get exercise_pull_017_description;

  /// No description provided for @exercise_pull_017_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a chair to reach top position. Lower as slowly as possible, aiming for 3-5 seconds descent.'**
  String get exercise_pull_017_beginner_tips;

  /// No description provided for @exercise_pull_019_name.
  ///
  /// In en, this message translates to:
  /// **'Wide Grip Inverted Row'**
  String get exercise_pull_019_name;

  /// No description provided for @exercise_pull_019_description.
  ///
  /// In en, this message translates to:
  /// **'Inverted row with hands placed wider than shoulder-width. Emphasizes outer back and rear deltoids.'**
  String get exercise_pull_019_description;

  /// No description provided for @exercise_pull_019_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use table or bar. Place hands wider than shoulders. Pull chest to surface while keeping body straight.'**
  String get exercise_pull_019_beginner_tips;

  /// No description provided for @exercise_pull_020_name.
  ///
  /// In en, this message translates to:
  /// **'Close Grip Inverted Row'**
  String get exercise_pull_020_name;

  /// No description provided for @exercise_pull_020_description.
  ///
  /// In en, this message translates to:
  /// **'Inverted row with hands close together. Increases bicep emphasis and difficulty.'**
  String get exercise_pull_020_description;

  /// No description provided for @exercise_pull_020_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Place hands close together, palms facing each other if possible. Pull with biceps and back muscles.'**
  String get exercise_pull_020_beginner_tips;

  /// No description provided for @exercise_legs_002_name.
  ///
  /// In en, this message translates to:
  /// **'Jump Squat'**
  String get exercise_legs_002_name;

  /// No description provided for @exercise_legs_002_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive squat variation with jump at the top. Develops power and athleticism in lower body.'**
  String get exercise_legs_002_description;

  /// No description provided for @exercise_legs_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular squats first. Land softly with knees slightly bent to absorb impact.'**
  String get exercise_legs_002_beginner_tips;

  /// No description provided for @exercise_legs_004_name.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Split Squat'**
  String get exercise_legs_004_name;

  /// No description provided for @exercise_legs_004_description.
  ///
  /// In en, this message translates to:
  /// **'Single-leg squat with rear foot elevated on chair. Excellent for building unilateral leg strength.'**
  String get exercise_legs_004_description;

  /// No description provided for @exercise_legs_004_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Place rear foot on chair behind you. Lower down, keeping front knee over ankle. Start with shallow depth.'**
  String get exercise_legs_004_beginner_tips;

  /// No description provided for @exercise_legs_007_name.
  ///
  /// In en, this message translates to:
  /// **'Walking Lunge'**
  String get exercise_legs_007_name;

  /// No description provided for @exercise_legs_007_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic lunge variation moving forward. Combines strength training with coordination.'**
  String get exercise_legs_007_description;

  /// No description provided for @exercise_legs_007_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with stationary lunges. Alternate legs as you move forward, maintaining good form.'**
  String get exercise_legs_007_beginner_tips;

  /// No description provided for @exercise_legs_008_name.
  ///
  /// In en, this message translates to:
  /// **'Jumping Lunge'**
  String get exercise_legs_008_name;

  /// No description provided for @exercise_legs_008_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive lunge variation with jump between reps. Develops power and cardiovascular fitness.'**
  String get exercise_legs_008_description;

  /// No description provided for @exercise_legs_008_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular lunges first. Land softly and switch legs in the air. Start with low jumps.'**
  String get exercise_legs_008_beginner_tips;

  /// No description provided for @exercise_legs_011_name.
  ///
  /// In en, this message translates to:
  /// **'Single Leg Calf Raise'**
  String get exercise_legs_011_name;

  /// No description provided for @exercise_legs_011_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral calf exercise. Performed on one leg to increase difficulty and address imbalances.'**
  String get exercise_legs_011_description;

  /// No description provided for @exercise_legs_011_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master two-legged calf raises first. Hold onto something for balance if needed.'**
  String get exercise_legs_011_beginner_tips;

  /// No description provided for @exercise_legs_013_name.
  ///
  /// In en, this message translates to:
  /// **'Single Leg Glute Bridge'**
  String get exercise_legs_013_name;

  /// No description provided for @exercise_legs_013_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced glute bridge variation performed on one leg. Significantly increases difficulty and glute activation.'**
  String get exercise_legs_013_description;

  /// No description provided for @exercise_legs_013_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular glute bridge first. Extend one leg straight, lift hips with one leg.'**
  String get exercise_legs_013_beginner_tips;

  /// No description provided for @exercise_legs_018_name.
  ///
  /// In en, this message translates to:
  /// **'Single Leg Deadlift'**
  String get exercise_legs_018_name;

  /// No description provided for @exercise_legs_018_description.
  ///
  /// In en, this message translates to:
  /// **'Unilateral hip hinge exercise. Develops balance, hamstring strength, and glute activation.'**
  String get exercise_legs_018_description;

  /// No description provided for @exercise_legs_018_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with small range of motion. Hinge at hips, extend opposite leg back. Keep back straight.'**
  String get exercise_legs_018_beginner_tips;

  /// No description provided for @exercise_legs_023_name.
  ///
  /// In en, this message translates to:
  /// **'Cossack Squat'**
  String get exercise_legs_023_name;

  /// No description provided for @exercise_legs_023_description.
  ///
  /// In en, this message translates to:
  /// **'Lateral squat variation with one leg extended. Improves hip mobility and builds leg strength.'**
  String get exercise_legs_023_description;

  /// No description provided for @exercise_legs_023_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Shift weight to one side, lower down while extending other leg. Keep extended leg straight.'**
  String get exercise_legs_023_beginner_tips;

  /// No description provided for @exercise_legs_025_name.
  ///
  /// In en, this message translates to:
  /// **'Wall Sit Pulse'**
  String get exercise_legs_025_name;

  /// No description provided for @exercise_legs_025_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic wall sit variation. Hold wall sit position, then pulse up and down slightly.'**
  String get exercise_legs_025_description;

  /// No description provided for @exercise_legs_025_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in wall sit position. Pulse up and down 2-3 inches. Keep back against wall throughout.'**
  String get exercise_legs_025_beginner_tips;

  /// No description provided for @exercise_core_003_name.
  ///
  /// In en, this message translates to:
  /// **'Mountain Climbers'**
  String get exercise_core_003_name;

  /// No description provided for @exercise_core_003_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic core exercise alternating knees to chest. Combines strength with cardiovascular training.'**
  String get exercise_core_003_description;

  /// No description provided for @exercise_core_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in plank position. Alternate bringing knees to chest. Keep hips level, don\'t bounce.'**
  String get exercise_core_003_beginner_tips;

  /// No description provided for @exercise_core_009_name.
  ///
  /// In en, this message translates to:
  /// **'Hollow Body Hold'**
  String get exercise_core_009_name;

  /// No description provided for @exercise_core_009_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced isometric core exercise. Lie on back, lift shoulders and legs, hold position.'**
  String get exercise_core_009_description;

  /// No description provided for @exercise_core_009_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with bent knees. Gradually straighten legs as you get stronger. Keep lower back pressed to floor.'**
  String get exercise_core_009_beginner_tips;

  /// No description provided for @exercise_core_010_name.
  ///
  /// In en, this message translates to:
  /// **'V-Ups'**
  String get exercise_core_010_name;

  /// No description provided for @exercise_core_010_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced core exercise forming V shape. Lie on back, lift torso and legs simultaneously to touch.'**
  String get exercise_core_010_description;

  /// No description provided for @exercise_core_010_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with knees bent. Gradually work toward straight legs. Don\'t use momentum.'**
  String get exercise_core_010_beginner_tips;

  /// No description provided for @exercise_core_013_name.
  ///
  /// In en, this message translates to:
  /// **'Plank Jacks'**
  String get exercise_core_013_name;

  /// No description provided for @exercise_core_013_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic plank variation jumping feet apart and together. Combines core strength with cardio.'**
  String get exercise_core_013_description;

  /// No description provided for @exercise_core_013_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in plank position. Jump feet apart and together while maintaining plank position.'**
  String get exercise_core_013_beginner_tips;

  /// No description provided for @exercise_core_014_name.
  ///
  /// In en, this message translates to:
  /// **'Bear Crawl'**
  String get exercise_core_014_name;

  /// No description provided for @exercise_core_014_description.
  ///
  /// In en, this message translates to:
  /// **'Quadruped movement exercise. Crawl forward and backward on hands and feet, keeping knees off ground.'**
  String get exercise_core_014_description;

  /// No description provided for @exercise_core_014_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep core engaged and back flat. Move opposite hand and foot together. Start with short distances.'**
  String get exercise_core_014_beginner_tips;

  /// No description provided for @exercise_core_015_name.
  ///
  /// In en, this message translates to:
  /// **'Crab Walk'**
  String get exercise_core_015_name;

  /// No description provided for @exercise_core_015_description.
  ///
  /// In en, this message translates to:
  /// **'Reverse quadruped movement. Sit with hands behind you, lift hips, walk forward and backward.'**
  String get exercise_core_015_description;

  /// No description provided for @exercise_core_015_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep hips lifted throughout. Move opposite hand and foot together. Start with short distances.'**
  String get exercise_core_015_beginner_tips;

  /// No description provided for @exercise_core_016_name.
  ///
  /// In en, this message translates to:
  /// **'Windshield Wipers'**
  String get exercise_core_016_name;

  /// No description provided for @exercise_core_016_description.
  ///
  /// In en, this message translates to:
  /// **'Core exercise moving legs side to side. Lie on back, lift legs, rotate them side to side.'**
  String get exercise_core_016_description;

  /// No description provided for @exercise_core_016_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep legs together and lower back pressed to floor. Move slowly and controlled.'**
  String get exercise_core_016_beginner_tips;

  /// No description provided for @exercise_core_018_name.
  ///
  /// In en, this message translates to:
  /// **'Plank to Downward Dog'**
  String get exercise_core_018_name;

  /// No description provided for @exercise_core_018_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic movement transitioning from plank to downward dog. Combines core strength with mobility.'**
  String get exercise_core_018_description;

  /// No description provided for @exercise_core_018_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in plank, push hips up to downward dog, then return. Move slowly and controlled.'**
  String get exercise_core_018_beginner_tips;

  /// No description provided for @exercise_core_019_name.
  ///
  /// In en, this message translates to:
  /// **'Side Plank with Leg Lift'**
  String get exercise_core_019_name;

  /// No description provided for @exercise_core_019_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced side plank variation. Hold side plank, lift top leg up and down.'**
  String get exercise_core_019_description;

  /// No description provided for @exercise_core_019_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular side plank first. Lift leg slowly, keeping body straight. Don\'t rotate hips.'**
  String get exercise_core_019_beginner_tips;

  /// No description provided for @exercise_core_020_name.
  ///
  /// In en, this message translates to:
  /// **'Plank Up-Downs'**
  String get exercise_core_020_name;

  /// No description provided for @exercise_core_020_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic plank variation transitioning between high and low plank. Alternates between hands and forearms.'**
  String get exercise_core_020_description;

  /// No description provided for @exercise_core_020_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in plank, push up to high plank one arm at a time, then lower back down. Keep core engaged.'**
  String get exercise_core_020_beginner_tips;

  /// No description provided for @exercise_cardio_004_name.
  ///
  /// In en, this message translates to:
  /// **'Burpees'**
  String get exercise_cardio_004_name;

  /// No description provided for @exercise_cardio_004_description.
  ///
  /// In en, this message translates to:
  /// **'Full-body explosive exercise combining squat, plank, push-up, and jump. Ultimate bodyweight cardio challenge.'**
  String get exercise_cardio_004_description;

  /// No description provided for @exercise_cardio_004_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with step-back burpees (no jump). Master each component separately before combining. Land softly from jump.'**
  String get exercise_cardio_004_beginner_tips;

  /// No description provided for @exercise_cardio_005_name.
  ///
  /// In en, this message translates to:
  /// **'Skater Jumps'**
  String get exercise_cardio_005_name;

  /// No description provided for @exercise_cardio_005_description.
  ///
  /// In en, this message translates to:
  /// **'Lateral jumping exercise mimicking ice skating motion. Develops power, balance, and cardiovascular fitness.'**
  String get exercise_cardio_005_description;

  /// No description provided for @exercise_cardio_005_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Jump side to side, landing on one foot. Swing opposite arm across body. Start with small jumps.'**
  String get exercise_cardio_005_beginner_tips;

  /// No description provided for @exercise_cardio_006_name.
  ///
  /// In en, this message translates to:
  /// **'Star Jumps'**
  String get exercise_cardio_006_name;

  /// No description provided for @exercise_cardio_006_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive jumping exercise forming star shape. Jump up, spread arms and legs wide, then return.'**
  String get exercise_cardio_006_description;

  /// No description provided for @exercise_cardio_006_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Jump up, spread arms and legs wide at peak. Land softly with feet together. Start with low jumps.'**
  String get exercise_cardio_006_beginner_tips;

  /// No description provided for @exercise_cardio_007_name.
  ///
  /// In en, this message translates to:
  /// **'Tuck Jumps'**
  String get exercise_cardio_007_name;

  /// No description provided for @exercise_cardio_007_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive jump bringing knees to chest. Develops power and cardiovascular fitness.'**
  String get exercise_cardio_007_description;

  /// No description provided for @exercise_cardio_007_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Jump as high as possible, bringing knees toward chest. Land softly with knees slightly bent.'**
  String get exercise_cardio_007_beginner_tips;

  /// No description provided for @exercise_cardio_008_name.
  ///
  /// In en, this message translates to:
  /// **'Inchworms'**
  String get exercise_cardio_008_name;

  /// No description provided for @exercise_cardio_008_description.
  ///
  /// In en, this message translates to:
  /// **'Full-body movement exercise. Stand, walk hands out to plank, then walk feet back to hands.'**
  String get exercise_cardio_008_description;

  /// No description provided for @exercise_cardio_008_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep legs as straight as possible when walking hands out. Move slowly and controlled.'**
  String get exercise_cardio_008_beginner_tips;

  /// No description provided for @exercise_cardio_011_name.
  ///
  /// In en, this message translates to:
  /// **'Fast Feet'**
  String get exercise_cardio_011_name;

  /// No description provided for @exercise_cardio_011_description.
  ///
  /// In en, this message translates to:
  /// **'High-intensity cardio exercise. Run in place as fast as possible, staying on balls of feet.'**
  String get exercise_cardio_011_description;

  /// No description provided for @exercise_cardio_011_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Stay on balls of feet, move feet as fast as possible. Keep core engaged. Start with 10-15 second bursts.'**
  String get exercise_cardio_011_beginner_tips;

  /// No description provided for @exercise_cardio_012_name.
  ///
  /// In en, this message translates to:
  /// **'Squat Jumps'**
  String get exercise_cardio_012_name;

  /// No description provided for @exercise_cardio_012_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive squat variation with jump. Combines strength training with high-intensity cardio.'**
  String get exercise_cardio_012_description;

  /// No description provided for @exercise_cardio_012_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Squat down, then explode up into jump. Land softly and immediately go into next rep.'**
  String get exercise_cardio_012_beginner_tips;

  /// No description provided for @exercise_cardio_013_name.
  ///
  /// In en, this message translates to:
  /// **'Lunge Jumps'**
  String get exercise_cardio_013_name;

  /// No description provided for @exercise_cardio_013_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive lunge variation with jump. Alternates legs while jumping, providing intense cardio workout.'**
  String get exercise_cardio_013_description;

  /// No description provided for @exercise_cardio_013_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in lunge position, jump up and switch legs in air. Land in opposite lunge position.'**
  String get exercise_cardio_013_beginner_tips;

  /// No description provided for @exercise_cardio_015_name.
  ///
  /// In en, this message translates to:
  /// **'Jumping Lunges'**
  String get exercise_cardio_015_name;

  /// No description provided for @exercise_cardio_015_description.
  ///
  /// In en, this message translates to:
  /// **'High-intensity lunge variation with explosive jumps. Alternates legs while maintaining lunge position.'**
  String get exercise_cardio_015_description;

  /// No description provided for @exercise_cardio_015_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start in lunge, jump up and switch legs. Land softly in opposite lunge. Master regular lunges first.'**
  String get exercise_cardio_015_beginner_tips;

  /// No description provided for @exercise_push_009_name.
  ///
  /// In en, this message translates to:
  /// **'Archer Push-up'**
  String get exercise_push_009_name;

  /// No description provided for @exercise_push_009_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced unilateral push-up variation. Shifts weight to one arm while the other arm extends, building incredible strength.'**
  String get exercise_push_009_description;

  /// No description provided for @exercise_push_009_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular push-ups first. Start with a small shift and gradually increase the range.'**
  String get exercise_push_009_beginner_tips;

  /// No description provided for @exercise_push_016_name.
  ///
  /// In en, this message translates to:
  /// **'Pseudo Planche Push-up'**
  String get exercise_push_016_name;

  /// No description provided for @exercise_push_016_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced push-up with hands positioned further back toward waist. Extremely challenging variation that builds incredible strength.'**
  String get exercise_push_016_description;

  /// No description provided for @exercise_push_016_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with hands slightly behind shoulders and gradually move them back as you get stronger.'**
  String get exercise_push_016_beginner_tips;

  /// No description provided for @exercise_push_017_name.
  ///
  /// In en, this message translates to:
  /// **'Clapping Push-up'**
  String get exercise_push_017_name;

  /// No description provided for @exercise_push_017_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive push-up variation where you clap hands together at the top. Develops power and upper body explosiveness.'**
  String get exercise_push_017_description;

  /// No description provided for @exercise_push_017_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular push-ups first. Start with small claps and gradually increase height. Land softly.'**
  String get exercise_push_017_beginner_tips;

  /// No description provided for @exercise_push_018_name.
  ///
  /// In en, this message translates to:
  /// **'One-Arm Push-up'**
  String get exercise_push_018_name;

  /// No description provided for @exercise_push_018_description.
  ///
  /// In en, this message translates to:
  /// **'Ultimate push-up challenge performed with one arm. Requires exceptional strength, stability, and core control.'**
  String get exercise_push_018_description;

  /// No description provided for @exercise_push_018_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Progress from archer push-ups. Start with feet wide apart and gradually bring them closer together.'**
  String get exercise_push_018_beginner_tips;

  /// No description provided for @exercise_push_019_name.
  ///
  /// In en, this message translates to:
  /// **'Handstand Push-up'**
  String get exercise_push_019_name;

  /// No description provided for @exercise_push_019_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced exercise performed in handstand position. Ultimate test of shoulder strength and stability.'**
  String get exercise_push_019_description;

  /// No description provided for @exercise_push_019_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master handstand hold first. Practice against a wall before attempting freestanding. Use pike push-ups to build strength.'**
  String get exercise_push_019_beginner_tips;

  /// No description provided for @exercise_legs_003_name.
  ///
  /// In en, this message translates to:
  /// **'Pistol Squat'**
  String get exercise_legs_003_name;

  /// No description provided for @exercise_legs_003_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced single-leg squat. Requires exceptional strength, balance, and mobility. Ultimate leg strength test.'**
  String get exercise_legs_003_description;

  /// No description provided for @exercise_legs_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with assisted pistol squats using a chair or holding onto something. Progress gradually.'**
  String get exercise_legs_003_beginner_tips;

  /// No description provided for @exercise_legs_019_name.
  ///
  /// In en, this message translates to:
  /// **'Skater Squats'**
  String get exercise_legs_019_name;

  /// No description provided for @exercise_legs_019_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced single-leg squat variation. Requires exceptional balance and leg strength.'**
  String get exercise_legs_019_description;

  /// No description provided for @exercise_legs_019_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with assisted version holding onto something. Lower down on one leg, extend other leg forward.'**
  String get exercise_legs_019_beginner_tips;

  /// No description provided for @exercise_legs_022_name.
  ///
  /// In en, this message translates to:
  /// **'Single Leg Squat'**
  String get exercise_legs_022_name;

  /// No description provided for @exercise_legs_022_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced unilateral squat. Performed on one leg, requires exceptional strength and balance.'**
  String get exercise_legs_022_description;

  /// No description provided for @exercise_legs_022_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with assisted version or pistol squat progression. Lower down on one leg, extend other leg forward for balance.'**
  String get exercise_legs_022_beginner_tips;

  /// No description provided for @exercise_legs_024_name.
  ///
  /// In en, this message translates to:
  /// **'Jump Squat to Tuck'**
  String get exercise_legs_024_name;

  /// No description provided for @exercise_legs_024_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced jump squat variation bringing knees to chest in the air. Develops explosive power and core strength.'**
  String get exercise_legs_024_description;

  /// No description provided for @exercise_legs_024_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master regular jump squats first. Bring knees toward chest at peak of jump. Land softly.'**
  String get exercise_legs_024_beginner_tips;

  /// No description provided for @exercise_core_017_name.
  ///
  /// In en, this message translates to:
  /// **'L-Sit'**
  String get exercise_core_017_name;

  /// No description provided for @exercise_core_017_description.
  ///
  /// In en, this message translates to:
  /// **'Advanced isometric core exercise. Sit with legs extended, lift body off ground using core and arms.'**
  String get exercise_core_017_description;

  /// No description provided for @exercise_core_017_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with bent knees or using chair for support. Gradually work toward full L-sit.'**
  String get exercise_core_017_beginner_tips;

  /// Full body warmup category
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get warmup_category_full_body;

  /// Upper body warmup category
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get warmup_category_upper_body;

  /// Lower body warmup category
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get warmup_category_lower_body;

  /// Core warmup category
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get warmup_category_core;

  /// Cardio warmup category
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get warmup_category_cardio;

  /// Full body warmup description
  ///
  /// In en, this message translates to:
  /// **'Whole body activation'**
  String get warmup_category_desc_full_body;

  /// Upper body warmup description
  ///
  /// In en, this message translates to:
  /// **'Arms, shoulders & chest'**
  String get warmup_category_desc_upper_body;

  /// Lower body warmup description
  ///
  /// In en, this message translates to:
  /// **'Legs, hips & glutes'**
  String get warmup_category_desc_lower_body;

  /// Core warmup description
  ///
  /// In en, this message translates to:
  /// **'Abs & lower back'**
  String get warmup_category_desc_core;

  /// Cardio warmup description
  ///
  /// In en, this message translates to:
  /// **'Get your heart rate up'**
  String get warmup_category_desc_cardio;

  /// Warmup category picker prompt
  ///
  /// In en, this message translates to:
  /// **'Choose focus area'**
  String get warmup_pick_category;

  /// No description provided for @exercise_cardio_016_name.
  ///
  /// In en, this message translates to:
  /// **'Broad Jump'**
  String get exercise_cardio_016_name;

  /// No description provided for @exercise_cardio_016_description.
  ///
  /// In en, this message translates to:
  /// **'Explosive forward jump landing softly in an athletic stance. Develops power in legs and spikes heart rate for conditioning.'**
  String get exercise_cardio_016_description;

  /// No description provided for @exercise_cardio_016_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Swing arms for momentum. Bend knees on landing to absorb impact.'**
  String get exercise_cardio_016_beginner_tips;

  /// No description provided for @exercise_cardio_017_name.
  ///
  /// In en, this message translates to:
  /// **'Sprawl'**
  String get exercise_cardio_017_name;

  /// No description provided for @exercise_cardio_017_description.
  ///
  /// In en, this message translates to:
  /// **'Drop hips back, shoot legs out to plank, jump feet in, stand up. Burpee without the push-up—pure conditioning.'**
  String get exercise_cardio_017_description;

  /// No description provided for @exercise_cardio_017_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Step feet back one at a time if jumping is too intense. Stand fully between reps.'**
  String get exercise_cardio_017_beginner_tips;

  /// No description provided for @exercise_cardio_018_name.
  ///
  /// In en, this message translates to:
  /// **'Power Skips'**
  String get exercise_cardio_018_name;

  /// No description provided for @exercise_cardio_018_description.
  ///
  /// In en, this message translates to:
  /// **'Exaggerated skipping with explosive knee drive and arm swing. Develops single-leg power and high-intensity conditioning.'**
  String get exercise_cardio_018_description;

  /// No description provided for @exercise_cardio_018_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Drive the opposite arm and leg together. Land softly on the ball of the foot.'**
  String get exercise_cardio_018_beginner_tips;

  /// No description provided for @exercise_cardio_019_name.
  ///
  /// In en, this message translates to:
  /// **'Boxer Shuffle'**
  String get exercise_cardio_019_name;

  /// No description provided for @exercise_cardio_019_description.
  ///
  /// In en, this message translates to:
  /// **'Rapid weight shifts side to side on the balls of the feet with light punches optional. Low-impact cardio finisher.'**
  String get exercise_cardio_019_description;

  /// No description provided for @exercise_cardio_019_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Stay on the balls of your feet. Keep movements small and rhythm steady.'**
  String get exercise_cardio_019_beginner_tips;

  /// No description provided for @exercise_core_021_name.
  ///
  /// In en, this message translates to:
  /// **'Heel Taps'**
  String get exercise_core_021_name;

  /// No description provided for @exercise_core_021_description.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back, crunch up slightly, and alternate tapping heels to the floor. Trains abs with light oblique engagement.'**
  String get exercise_core_021_description;

  /// No description provided for @exercise_core_021_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Press lower back gently into the floor. Move slowly—do not rush the taps.'**
  String get exercise_core_021_beginner_tips;

  /// No description provided for @exercise_core_022_name.
  ///
  /// In en, this message translates to:
  /// **'Knee Pull-In'**
  String get exercise_core_022_name;

  /// No description provided for @exercise_core_022_description.
  ///
  /// In en, this message translates to:
  /// **'Seated or on hands, draw knees toward chest and extend legs. Dynamic ab exercise scaling from beginner to advanced.'**
  String get exercise_core_022_description;

  /// No description provided for @exercise_core_022_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Round lower back slightly as knees come in. Move slowly to avoid momentum.'**
  String get exercise_core_022_beginner_tips;

  /// No description provided for @exercise_core_023_name.
  ///
  /// In en, this message translates to:
  /// **'Sit-up'**
  String get exercise_core_023_name;

  /// No description provided for @exercise_core_023_description.
  ///
  /// In en, this message translates to:
  /// **'Classic abdominal exercise. Curl torso up from the floor with feet anchored or bent, then lower with control.'**
  String get exercise_core_023_description;

  /// No description provided for @exercise_core_023_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Exhale on the way up. If your neck strains, support your head lightly with your hands.'**
  String get exercise_core_023_beginner_tips;

  /// No description provided for @exercise_core_025_name.
  ///
  /// In en, this message translates to:
  /// **'Standing Side Crunch'**
  String get exercise_core_025_name;

  /// No description provided for @exercise_core_025_description.
  ///
  /// In en, this message translates to:
  /// **'Stand tall and crunch sideways bringing elbow toward hip. Isolates obliques without lying on the floor.'**
  String get exercise_core_025_description;

  /// No description provided for @exercise_core_025_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep hips level—avoid leaning the whole body. Contract the side you are crunching toward.'**
  String get exercise_core_025_beginner_tips;

  /// No description provided for @exercise_core_026_name.
  ///
  /// In en, this message translates to:
  /// **'Cross-Body Mountain Climber'**
  String get exercise_core_026_name;

  /// No description provided for @exercise_core_026_description.
  ///
  /// In en, this message translates to:
  /// **'In high plank, drive knee toward opposite elbow. Adds rotation to mountain climbers for obliques and cardio.'**
  String get exercise_core_026_description;

  /// No description provided for @exercise_core_026_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep shoulders over wrists. Quality beats speed—alternate sides with control.'**
  String get exercise_core_026_beginner_tips;

  /// No description provided for @exercise_core_027_name.
  ///
  /// In en, this message translates to:
  /// **'Hollow Rock'**
  String get exercise_core_027_name;

  /// No description provided for @exercise_core_027_description.
  ///
  /// In en, this message translates to:
  /// **'Hold hollow body position and rock forward and back slightly. Advanced anti-extension core drill popular in gymnastics training.'**
  String get exercise_core_027_description;

  /// No description provided for @exercise_core_027_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Master hollow hold first. Keep lower back pressed toward the floor.'**
  String get exercise_core_027_beginner_tips;

  /// No description provided for @exercise_core_028_name.
  ///
  /// In en, this message translates to:
  /// **'Tuck Front Lever Hold'**
  String get exercise_core_028_name;

  /// No description provided for @exercise_core_028_description.
  ///
  /// In en, this message translates to:
  /// **'Hang from a bar, tuck knees, and depress shoulders to lift torso nearly horizontal. Advanced straight-arm back and core strength.'**
  String get exercise_core_028_description;

  /// No description provided for @exercise_core_028_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with short tuck holds. Focus on pushing shoulders down away from ears.'**
  String get exercise_core_028_beginner_tips;

  /// No description provided for @exercise_legs_026_name.
  ///
  /// In en, this message translates to:
  /// **'Squat Pulse'**
  String get exercise_legs_026_name;

  /// No description provided for @exercise_legs_026_description.
  ///
  /// In en, this message translates to:
  /// **'Hold the bottom of a squat and pulse up and down a few inches. Builds quad and glute endurance without equipment.'**
  String get exercise_legs_026_description;

  /// No description provided for @exercise_legs_026_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep chest up and knees tracking over toes. Use a shallow range if needed.'**
  String get exercise_legs_026_beginner_tips;

  /// No description provided for @exercise_legs_027_name.
  ///
  /// In en, this message translates to:
  /// **'Sissy Squat Hold'**
  String get exercise_legs_027_name;

  /// No description provided for @exercise_legs_027_description.
  ///
  /// In en, this message translates to:
  /// **'Lean back slightly while bending knees forward, keeping hips extended. Intense quad isolation using bodyweight only.'**
  String get exercise_legs_027_description;

  /// No description provided for @exercise_legs_027_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Hold a wall or door frame lightly for balance. Use a small range until strength improves.'**
  String get exercise_legs_027_beginner_tips;

  /// No description provided for @exercise_legs_030_name.
  ///
  /// In en, this message translates to:
  /// **'Sliding Hamstring Curl'**
  String get exercise_legs_030_name;

  /// No description provided for @exercise_legs_030_description.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back, heels on a towel or socks on smooth floor, curl heels toward glutes. Hamstring curl without machines.'**
  String get exercise_legs_030_description;

  /// No description provided for @exercise_legs_030_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lift hips as you curl in. Control the slide back to start.'**
  String get exercise_legs_030_beginner_tips;

  /// No description provided for @exercise_legs_031_name.
  ///
  /// In en, this message translates to:
  /// **'Nordic Curl Negative'**
  String get exercise_legs_031_name;

  /// No description provided for @exercise_legs_031_description.
  ///
  /// In en, this message translates to:
  /// **'Kneel with ankles anchored under a couch or partner, lower torso forward slowly, catch with hands. Advanced hamstring eccentric.'**
  String get exercise_legs_031_description;

  /// No description provided for @exercise_legs_031_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep hips extended. Lower only as far as you can control—use hands to assist at the bottom.'**
  String get exercise_legs_031_beginner_tips;

  /// No description provided for @exercise_legs_033_name.
  ///
  /// In en, this message translates to:
  /// **'Frog Pump'**
  String get exercise_legs_033_name;

  /// No description provided for @exercise_legs_033_description.
  ///
  /// In en, this message translates to:
  /// **'Lie on your back with soles together and knees open. Drive hips up by squeezing glutes for high-rep glute activation.'**
  String get exercise_legs_033_description;

  /// No description provided for @exercise_legs_033_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Do not arch the lower back excessively. Pause briefly at the top of each rep.'**
  String get exercise_legs_033_beginner_tips;

  /// No description provided for @exercise_legs_034_name.
  ///
  /// In en, this message translates to:
  /// **'Curtsy Lunge'**
  String get exercise_legs_034_name;

  /// No description provided for @exercise_legs_034_description.
  ///
  /// In en, this message translates to:
  /// **'Step one leg diagonally behind the other into a curtsy position and return. Emphasizes glutes and outer hip stability.'**
  String get exercise_legs_034_description;

  /// No description provided for @exercise_legs_034_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep front knee aligned over the ankle. Touch the back knee toward the floor lightly.'**
  String get exercise_legs_034_beginner_tips;

  /// No description provided for @exercise_legs_035_name.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Hip Thrust'**
  String get exercise_legs_035_name;

  /// No description provided for @exercise_legs_035_description.
  ///
  /// In en, this message translates to:
  /// **'Upper back on the floor, feet flat, drive hips to full extension. One of the most effective glute builders without weights.'**
  String get exercise_legs_035_description;

  /// No description provided for @exercise_legs_035_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Tuck chin slightly and push through heels. Squeeze glutes hard at the top.'**
  String get exercise_legs_035_beginner_tips;

  /// No description provided for @exercise_legs_036_name.
  ///
  /// In en, this message translates to:
  /// **'Standing Glute Kickback'**
  String get exercise_legs_036_name;

  /// No description provided for @exercise_legs_036_description.
  ///
  /// In en, this message translates to:
  /// **'Stand on one leg and drive the other leg straight back. Isolates glutes and improves hip extension strength.'**
  String get exercise_legs_036_description;

  /// No description provided for @exercise_legs_036_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Squeeze glute at end range. Hold a wall for balance if needed.'**
  String get exercise_legs_036_beginner_tips;

  /// No description provided for @exercise_legs_037_name.
  ///
  /// In en, this message translates to:
  /// **'Seated Calf Raise'**
  String get exercise_legs_037_name;

  /// No description provided for @exercise_legs_037_description.
  ///
  /// In en, this message translates to:
  /// **'Sit with knees bent at 90 degrees and lift heels off the floor. Targets soleus and gastrocnemius without a step.'**
  String get exercise_legs_037_description;

  /// No description provided for @exercise_legs_037_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Pause at the top. Place hands on knees for light resistance if desired.'**
  String get exercise_legs_037_beginner_tips;

  /// No description provided for @exercise_legs_038_name.
  ///
  /// In en, this message translates to:
  /// **'Shrimp Squat'**
  String get exercise_legs_038_name;

  /// No description provided for @exercise_legs_038_description.
  ///
  /// In en, this message translates to:
  /// **'Single-leg squat reaching the back knee behind you while holding the rear foot. Advanced quad and balance challenge.'**
  String get exercise_legs_038_description;

  /// No description provided for @exercise_legs_038_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a wall for balance. Progress from partial range to full depth over weeks.'**
  String get exercise_legs_038_beginner_tips;

  /// No description provided for @exercise_legs_039_name.
  ///
  /// In en, this message translates to:
  /// **'Lateral Lunge Pulse'**
  String get exercise_legs_039_name;

  /// No description provided for @exercise_legs_039_description.
  ///
  /// In en, this message translates to:
  /// **'Step wide to one side, stay low, and pulse in the bottom position. Targets quads, glutes, and inner thighs.'**
  String get exercise_legs_039_description;

  /// No description provided for @exercise_legs_039_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep the bent knee over the foot. Chest stays lifted throughout pulses.'**
  String get exercise_legs_039_beginner_tips;

  /// No description provided for @exercise_pull_021_name.
  ///
  /// In en, this message translates to:
  /// **'Prone Cobra'**
  String get exercise_pull_021_name;

  /// No description provided for @exercise_pull_021_description.
  ///
  /// In en, this message translates to:
  /// **'Back extension hold lying face down. Lift chest and arms slightly to strengthen the lower back and glutes with minimal spinal compression.'**
  String get exercise_pull_021_description;

  /// No description provided for @exercise_pull_021_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Lift only as high as comfortable. Hold 2–3 seconds and lower with control.'**
  String get exercise_pull_021_beginner_tips;

  /// No description provided for @exercise_pull_022_name.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Good Morning'**
  String get exercise_pull_022_name;

  /// No description provided for @exercise_pull_022_description.
  ///
  /// In en, this message translates to:
  /// **'Hands behind head, hinge at hips with a flat back, then return upright. Strengthens hamstrings, glutes, and erectors.'**
  String get exercise_pull_022_description;

  /// No description provided for @exercise_pull_022_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Push hips back as if closing a door with your glutes. Stop when torso is near parallel to the floor.'**
  String get exercise_pull_022_beginner_tips;

  /// No description provided for @exercise_pull_024_name.
  ///
  /// In en, this message translates to:
  /// **'Chin-Up Negative'**
  String get exercise_pull_024_name;

  /// No description provided for @exercise_pull_024_description.
  ///
  /// In en, this message translates to:
  /// **'Underhand grip at the top of a chin-up, lower slowly for 3–5 seconds. Builds biceps and lat strength for full chin-ups.'**
  String get exercise_pull_024_description;

  /// No description provided for @exercise_pull_024_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a sturdy bar. Jump or step to the top position and control the descent.'**
  String get exercise_pull_024_beginner_tips;

  /// No description provided for @exercise_pull_025_name.
  ///
  /// In en, this message translates to:
  /// **'Dead Hang'**
  String get exercise_pull_025_name;

  /// No description provided for @exercise_pull_025_description.
  ///
  /// In en, this message translates to:
  /// **'Hang from a sturdy bar or ledge with arms straight. Builds grip, forearms, and decompresses the spine while preparing for pull-up strength.'**
  String get exercise_pull_025_description;

  /// No description provided for @exercise_pull_025_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Pack shoulders down slightly. Start with 10–20 seconds and add time gradually.'**
  String get exercise_pull_025_beginner_tips;

  /// No description provided for @exercise_pull_026_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse Grip Hang Hold'**
  String get exercise_pull_026_name;

  /// No description provided for @exercise_pull_026_description.
  ///
  /// In en, this message translates to:
  /// **'Hang with underhand grip at the top of a chin-up position. Isometric hold for biceps and grip endurance.'**
  String get exercise_pull_026_description;

  /// No description provided for @exercise_pull_026_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Use a box to reach the top position if needed. Keep shoulders engaged, not fully relaxed.'**
  String get exercise_pull_026_beginner_tips;

  /// No description provided for @exercise_pull_027_name.
  ///
  /// In en, this message translates to:
  /// **'Fist Plank Hold'**
  String get exercise_pull_027_name;

  /// No description provided for @exercise_pull_027_description.
  ///
  /// In en, this message translates to:
  /// **'High plank performed on closed fists. Increases wrist and forearm demand while maintaining core tension.'**
  String get exercise_pull_027_description;

  /// No description provided for @exercise_pull_027_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Align wrists under shoulders. Stop if you feel sharp wrist pain.'**
  String get exercise_pull_027_beginner_tips;

  /// No description provided for @exercise_pull_028_name.
  ///
  /// In en, this message translates to:
  /// **'Scapular Push-up'**
  String get exercise_pull_028_name;

  /// No description provided for @exercise_pull_028_description.
  ///
  /// In en, this message translates to:
  /// **'From a high plank, protract and retract the shoulder blades without bending elbows. Trains serratus and mid-back control for healthier pressing.'**
  String get exercise_pull_028_description;

  /// No description provided for @exercise_pull_028_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep arms straight throughout. Move only at the shoulder blades.'**
  String get exercise_pull_028_beginner_tips;

  /// No description provided for @exercise_pull_029_name.
  ///
  /// In en, this message translates to:
  /// **'Renegade Row'**
  String get exercise_pull_029_name;

  /// No description provided for @exercise_pull_029_description.
  ///
  /// In en, this message translates to:
  /// **'From a high plank, row one hand to the hip while balancing on the other. Combines core stability with back and bicep pulling.'**
  String get exercise_pull_029_description;

  /// No description provided for @exercise_pull_029_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Widen foot stance for stability. Prevent hips from rotating as you row.'**
  String get exercise_pull_029_beginner_tips;

  /// No description provided for @exercise_pull_030_name.
  ///
  /// In en, this message translates to:
  /// **'Archer Inverted Row'**
  String get exercise_pull_030_name;

  /// No description provided for @exercise_pull_030_description.
  ///
  /// In en, this message translates to:
  /// **'Under a table, row toward one hand with the other arm extended. Unilateral back and bicep strength without a pull-up bar.'**
  String get exercise_pull_030_description;

  /// No description provided for @exercise_pull_030_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep body rigid. Pull chest to the working hand each rep.'**
  String get exercise_pull_030_beginner_tips;

  /// No description provided for @exercise_push_021_name.
  ///
  /// In en, this message translates to:
  /// **'Staggered Push-up'**
  String get exercise_push_021_name;

  /// No description provided for @exercise_push_021_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up with one hand slightly forward and one back. Builds unilateral pressing strength and core stability while training chest and arms.'**
  String get exercise_push_021_description;

  /// No description provided for @exercise_push_021_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep hips square to the floor. Alternate which hand is forward each set.'**
  String get exercise_push_021_beginner_tips;

  /// No description provided for @exercise_push_022_name.
  ///
  /// In en, this message translates to:
  /// **'Tempo Push-up'**
  String get exercise_push_022_name;

  /// No description provided for @exercise_push_022_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up with a slow 3-second lowering phase and explosive press up. Increases time under tension for chest and triceps.'**
  String get exercise_push_022_description;

  /// No description provided for @exercise_push_022_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Count three seconds down, one second up. Maintain a rigid plank throughout.'**
  String get exercise_push_022_beginner_tips;

  /// No description provided for @exercise_push_023_name.
  ///
  /// In en, this message translates to:
  /// **'Close-Hand Push-up'**
  String get exercise_push_023_name;

  /// No description provided for @exercise_push_023_description.
  ///
  /// In en, this message translates to:
  /// **'Push-up with hands shoulder-width or slightly narrower. Shifts emphasis toward triceps while still loading the chest.'**
  String get exercise_push_023_description;

  /// No description provided for @exercise_push_023_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep elbows closer to the body than a standard push-up. Do not let hips sag.'**
  String get exercise_push_023_beginner_tips;

  /// No description provided for @exercise_push_024_name.
  ///
  /// In en, this message translates to:
  /// **'Arm Circles'**
  String get exercise_push_024_name;

  /// No description provided for @exercise_push_024_description.
  ///
  /// In en, this message translates to:
  /// **'Shoulder mobility and endurance drill. Extend arms to the sides and draw controlled circles to warm up and strengthen the deltoids.'**
  String get exercise_push_024_description;

  /// No description provided for @exercise_push_024_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with small circles and gradually enlarge them. Reverse direction halfway through the set.'**
  String get exercise_push_024_beginner_tips;

  /// No description provided for @exercise_push_025_name.
  ///
  /// In en, this message translates to:
  /// **'Prone I Raise'**
  String get exercise_push_025_name;

  /// No description provided for @exercise_push_025_description.
  ///
  /// In en, this message translates to:
  /// **'Lie face down and lift straight arms overhead forming an I shape. Targets rear delts and upper back for posture and shoulder health.'**
  String get exercise_push_025_description;

  /// No description provided for @exercise_push_025_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Keep thumbs pointing up. Squeeze shoulder blades at the top without shrugging.'**
  String get exercise_push_025_beginner_tips;

  /// No description provided for @exercise_push_027_name.
  ///
  /// In en, this message translates to:
  /// **'Body Saw'**
  String get exercise_push_027_name;

  /// No description provided for @exercise_push_027_description.
  ///
  /// In en, this message translates to:
  /// **'From forearm plank, rock body forward and back using shoulders. Challenges core anti-extension and triceps endurance.'**
  String get exercise_push_027_description;

  /// No description provided for @exercise_push_027_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Move in a small range at first. Keep glutes engaged to protect the lower back.'**
  String get exercise_push_027_beginner_tips;

  /// No description provided for @exercise_push_029_name.
  ///
  /// In en, this message translates to:
  /// **'Typewriter Push-up'**
  String get exercise_push_029_name;

  /// No description provided for @exercise_push_029_description.
  ///
  /// In en, this message translates to:
  /// **'At the bottom of a push-up, shift body weight side to side before pressing up. Extreme chest and tricep tension with core demand.'**
  String get exercise_push_029_description;

  /// No description provided for @exercise_push_029_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Stay low—move horizontally at the bottom only. Master archer push-ups first.'**
  String get exercise_push_029_beginner_tips;

  /// No description provided for @exercise_rest_001_name.
  ///
  /// In en, this message translates to:
  /// **'Meditation & Deep Breathing'**
  String get exercise_rest_001_name;

  /// No description provided for @exercise_rest_001_description.
  ///
  /// In en, this message translates to:
  /// **'Focused mindfulness session. Sit or lie still, close your eyes, and practise box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s. Reduces cortisol and accelerates recovery.'**
  String get exercise_rest_001_description;

  /// No description provided for @exercise_rest_001_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Start with 5-minute sessions. A wandering mind is normal — gently redirect to the breath without judgement.'**
  String get exercise_rest_001_beginner_tips;

  /// No description provided for @exercise_rest_002_name.
  ///
  /// In en, this message translates to:
  /// **'Easy Jog / Brisk Walk'**
  String get exercise_rest_002_name;

  /// No description provided for @exercise_rest_002_description.
  ///
  /// In en, this message translates to:
  /// **'Low-intensity steady-state cardio. Keep pace conversational — you should complete full sentences without gasping. Promotes blood flow and active recovery without adding training stress.'**
  String get exercise_rest_002_description;

  /// No description provided for @exercise_rest_002_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'If your heart rate exceeds 130 bpm, slow to a walk. The goal is circulation, not intensity.'**
  String get exercise_rest_002_beginner_tips;

  /// No description provided for @exercise_rest_003_name.
  ///
  /// In en, this message translates to:
  /// **'Full Body Mobility Flow'**
  String get exercise_rest_003_name;

  /// No description provided for @exercise_rest_003_description.
  ///
  /// In en, this message translates to:
  /// **'Dynamic and static stretching targeting major muscle groups in sequence. Improves range of motion, reduces soreness, and primes the body for the next training day.'**
  String get exercise_rest_003_description;

  /// No description provided for @exercise_rest_003_beginner_tips.
  ///
  /// In en, this message translates to:
  /// **'Move at breath pace. Never bounce into a stretch. Work from ankles upward: ankles to hips to thoracic spine to shoulders to neck.'**
  String get exercise_rest_003_beginner_tips;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
