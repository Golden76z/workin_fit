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

  @override
  String get auth_register_username_hint => 'Choisissez un pseudo';

  @override
  String get auth_register_email_hint => 'Entrez votre email';

  @override
  String get auth_register_password_hint => 'Créez un mot de passe fort';

  @override
  String get auth_register_confirm_password_hint =>
      'Confirmez votre mot de passe';

  @override
  String get auth_register_validation_username_required =>
      'Veuillez entrer un pseudo';

  @override
  String auth_register_validation_username_min(int minLength) {
    return 'Le pseudo doit contenir au moins $minLength caractères';
  }

  @override
  String auth_register_validation_username_max(int maxLength) {
    return 'Le pseudo doit contenir au plus $maxLength caractères';
  }

  @override
  String get auth_register_validation_email_required =>
      'Veuillez entrer votre email';

  @override
  String get auth_register_validation_email_invalid =>
      'Veuillez entrer un email valide';

  @override
  String get auth_register_validation_password_required =>
      'Veuillez entrer un mot de passe';

  @override
  String auth_register_validation_password_min(int minLength) {
    return 'Le mot de passe doit contenir au moins $minLength caractères';
  }

  @override
  String get auth_register_validation_password_uppercase =>
      'Doit contenir une majuscule';

  @override
  String get auth_register_validation_password_number =>
      'Doit contenir un chiffre';

  @override
  String get auth_register_validation_password_match =>
      'Les mots de passe ne correspondent pas';

  @override
  String get auth_register_dialog_verify_title => 'Vérifiez votre email';

  @override
  String get auth_register_dialog_verify_content =>
      'Un email de vérification a été envoyé dans votre boîte de réception. Veuillez vérifier votre adresse email avant de vous connecter.';

  @override
  String get auth_register_dialog_verify_button => 'Compris';

  @override
  String get auth_register_terms_text =>
      'En créant un compte, vous acceptez nos\nConditions d\'utilisation et Politique de confidentialité';

  @override
  String get auth_login_label => 'Connexion';

  @override
  String get auth_login_email_label => 'Email';

  @override
  String get auth_login_email_hint => 'Entrez votre email';

  @override
  String get auth_login_password_label => 'Mot de passe';

  @override
  String get auth_login_password_hint => 'Entrez votre mot de passe';

  @override
  String get auth_login_forgot_password => 'Mot de passe oublié ?';

  @override
  String get auth_login_validation_email_required =>
      'Veuillez entrer votre email';

  @override
  String get auth_login_validation_email_invalid =>
      'Veuillez entrer un email valide';

  @override
  String get auth_login_validation_password_required =>
      'Veuillez entrer votre mot de passe';

  @override
  String get auth_login_or_text => 'OU';

  @override
  String get auth_login_social_google => 'Continuer avec Google';

  @override
  String get auth_login_social_apple => 'Continuer avec Apple';

  @override
  String get auth_login_forgot_dialog_title => 'Réinitialiser le mot de passe';

  @override
  String auth_login_forgot_dialog_content(String email) {
    return 'Envoyer un email de réinitialisation à $email ?';
  }

  @override
  String get auth_login_forgot_dialog_cancel => 'Annuler';

  @override
  String get auth_login_forgot_dialog_send => 'Envoyer';

  @override
  String get auth_login_forgot_dialog_email_required =>
      'Veuillez d\'abord entrer votre adresse email';

  @override
  String get auth_login_forgot_dialog_success =>
      'Email de réinitialisation envoyé !';

  @override
  String get auth_tab_register => 'S\'enregistrer';

  @override
  String get auth_tab_login => 'Connexion';

  @override
  String get email_verification_title => 'Vérifiez votre email';

  @override
  String get email_verification_sent_to =>
      'Nous avons envoyé un email de vérification à :';

  @override
  String get email_verification_instructions =>
      'Veuillez vérifier votre boîte de réception et cliquer sur le lien de vérification pour activer votre compte.';

  @override
  String get email_verification_button_checking => 'Vérification...';

  @override
  String get email_verification_button_verified => 'J\'ai vérifié mon email';

  @override
  String get email_verification_resend => 'Renvoyer l\'email de vérification';

  @override
  String get email_verification_sign_out => 'Se déconnecter';

  @override
  String get email_verification_success => 'Email vérifié avec succès !';

  @override
  String get email_verification_not_verified =>
      'Email non vérifié. Veuillez vérifier votre boîte de réception.';

  @override
  String get email_verification_resend_title => 'Email de vérification envoyé';

  @override
  String email_verification_resend_content(String email) {
    return 'Un nouvel email de vérification a été envoyé à $email. Veuillez vérifier votre boîte de réception.';
  }

  @override
  String get email_verification_resend_button => 'OK';

  @override
  String email_verification_error_signout(String error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get error_auth_user_not_found =>
      'Aucun utilisateur trouvé avec cet email.';

  @override
  String get error_auth_wrong_password =>
      'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get error_auth_email_already_in_use =>
      'Un compte existe déjà avec cet email.';

  @override
  String get error_auth_invalid_email => 'Adresse email invalide.';

  @override
  String get error_auth_weak_password =>
      'Mot de passe trop faible. Utilisez au moins 8 caractères.';

  @override
  String get error_auth_user_disabled => 'Ce compte a été désactivé.';

  @override
  String get error_auth_too_many_requests =>
      'Trop de tentatives. Veuillez réessayer plus tard.';

  @override
  String get error_auth_operation_not_allowed =>
      'Cette méthode de connexion n\'est pas activée.';

  @override
  String get error_auth_invalid_credential =>
      'Identifiants invalides. Veuillez réessayer.';

  @override
  String get error_auth_account_exists_different =>
      'Un compte existe déjà avec cet email en utilisant une autre méthode de connexion.';

  @override
  String get error_auth_cancelled => 'La connexion a été annulée.';

  @override
  String get error_auth_network_error =>
      'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get error_auth_generic =>
      'Une erreur d\'authentification s\'est produite.';

  @override
  String get error_auth_google_signin_failed =>
      'La connexion Google a échoué. Veuillez réessayer.';

  @override
  String get error_auth_google_network =>
      'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get error_auth_google_cancelled => 'La connexion a été annulée.';

  @override
  String get error_auth_google_in_progress =>
      'Une connexion est déjà en cours.';

  @override
  String get error_auth_google_developer =>
      'Erreur développeur. Veuillez configurer la connexion Google correctement.';

  @override
  String get error_auth_email_not_verified =>
      'Email non vérifié. Veuillez vérifier votre boîte de réception.';
}
