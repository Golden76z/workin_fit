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
