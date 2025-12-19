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
