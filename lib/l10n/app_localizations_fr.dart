// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get auth_page_register_button => 'S\'enregistrer';

  @override
  String get auth_page_register_confirm_password_input =>
      'Confirmer le mot de passe';

  @override
  String get auth_page_register_description =>
      'Commencez votre aventure fitness avec nous!';

  @override
  String get auth_page_register_email_input => 'Email';

  @override
  String get auth_page_register_or_text => 'ou';

  @override
  String get auth_page_register_password_input => 'Mot de passe';

  @override
  String get auth_page_register_title => 'Créer un compte';

  @override
  String get auth_page_register_username_input => 'Pseudo';

  @override
  String get welcome_page_app_title => 'Workin Fit';

  @override
  String get welcome_page_choose_language => 'Changer de langue';

  @override
  String get welcome_page_language_confirmation_button => 'Confirmer';

  @override
  String get welcome_page_language_english => 'Anglais';

  @override
  String get welcome_page_language_french => 'Français';

  @override
  String get welcome_page_register_button => 'Créer un compte';
}
