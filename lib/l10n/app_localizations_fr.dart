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
  String get auth_page_login_description =>
      'Welcome back! Sign in to continue your fitness journey.';

  @override
  String get auth_page_login_button => 'Login';

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
