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
  String get auth_page_register_email_input => 'E-mail';

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
  String get auth_register_terms_prefix =>
      'En créant un compte, vous acceptez nos\n';

  @override
  String get auth_register_terms_and => ' et ';

  @override
  String get terms_of_service_title => 'Conditions d\'utilisation';

  @override
  String terms_of_service_last_updated(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get terms_of_service_intro =>
      'Bienvenue sur Workin Fit. En accédant ou en utilisant notre application, vous acceptez d\'être lié par ces Conditions d\'utilisation.';

  @override
  String get terms_of_service_section_1_title =>
      '1. Acceptation des conditions';

  @override
  String get terms_of_service_section_1_content =>
      'En créant un compte et en utilisant Workin Fit, vous reconnaissez avoir lu, compris et accepté d\'être lié par ces Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get terms_of_service_section_2_title => '2. Utilisation du service';

  @override
  String get terms_of_service_section_2_content =>
      'Vous acceptez d\'utiliser Workin Fit uniquement à des fins légales et conformément à ces Conditions. Vous êtes responsable du maintien de la confidentialité de vos identifiants de compte.';

  @override
  String get terms_of_service_section_3_title => '3. Comptes utilisateurs';

  @override
  String get terms_of_service_section_3_content =>
      'Vous êtes responsable de toutes les activités qui se produisent sous votre compte. Vous devez fournir des informations exactes et complètes lors de la création d\'un compte et maintenir vos informations de compte à jour.';

  @override
  String get terms_of_service_section_4_title => '4. Santé et sécurité';

  @override
  String get terms_of_service_section_4_content =>
      'Workin Fit fournit des informations sur la forme physique et des programmes d\'entraînement à titre informatif uniquement. Consultez un professionnel de la santé avant de commencer tout programme d\'exercice. Vous assumez tous les risques associés à votre utilisation de l\'application.';

  @override
  String get terms_of_service_section_5_title => '5. Propriété intellectuelle';

  @override
  String get terms_of_service_section_5_content =>
      'Tout le contenu, les fonctionnalités et les fonctions de Workin Fit nous appartiennent et sont protégés par les lois sur le droit d\'auteur, les marques de commerce et autres lois sur la propriété intellectuelle.';

  @override
  String get terms_of_service_section_6_title =>
      '6. Limitation de responsabilité';

  @override
  String get terms_of_service_section_6_content =>
      'Workin Fit ne sera pas responsable de tout dommage indirect, accessoire, spécial ou consécutif découlant de ou lié à votre utilisation de l\'application.';

  @override
  String get terms_of_service_section_7_title =>
      '7. Modifications des conditions';

  @override
  String get terms_of_service_section_7_content =>
      'Nous nous réservons le droit de modifier ces Conditions d\'utilisation à tout moment. Votre utilisation continue de l\'application après toute modification constitue une acceptation des nouvelles conditions.';

  @override
  String get terms_of_service_contact =>
      'Si vous avez des questions concernant ces Conditions, veuillez nous contacter.';

  @override
  String get privacy_policy_title => 'Politique de confidentialité';

  @override
  String privacy_policy_last_updated(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get privacy_policy_intro =>
      'Chez Workin Fit, nous nous engageons à protéger votre vie privée. Cette Politique de confidentialité explique comment nous collectons, utilisons, divulguons et protégeons vos informations lorsque vous utilisez notre application mobile.';

  @override
  String get privacy_policy_section_1_title =>
      '1. Informations que nous collectons';

  @override
  String get privacy_policy_section_1_content =>
      'Nous collectons les informations que vous nous fournissez directement, y compris votre nom, votre adresse e-mail, votre nom d\'utilisateur et vos informations de profil. Nous collectons également les données d\'entraînement, l\'historique des exercices et les objectifs de forme physique que vous saisissez dans l\'application.';

  @override
  String get privacy_policy_section_2_title =>
      '2. Comment nous utilisons vos informations';

  @override
  String get privacy_policy_section_2_content =>
      'Nous utilisons les informations que nous collectons pour fournir, maintenir et améliorer nos services, personnaliser votre expérience, suivre vos progrès de forme physique et communiquer avec vous concernant votre compte et nos services.';

  @override
  String get privacy_policy_section_3_title =>
      '3. Partage et divulgation d\'informations';

  @override
  String get privacy_policy_section_3_content =>
      'Nous ne vendons pas vos informations personnelles. Nous ne partageons vos informations qu\'avec votre consentement, pour nous conformer aux obligations légales ou pour protéger nos droits et la sécurité de nos utilisateurs.';

  @override
  String get privacy_policy_section_4_title => '4. Sécurité des données';

  @override
  String get privacy_policy_section_4_content =>
      'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles appropriées pour protéger vos informations personnelles. Cependant, aucune méthode de transmission sur Internet n\'est sécurisée à 100%.';

  @override
  String get privacy_policy_section_5_title => '5. Vos droits et choix';

  @override
  String get privacy_policy_section_5_content =>
      'Vous avez le droit d\'accéder, de mettre à jour ou de supprimer vos informations personnelles à tout moment via les paramètres de votre compte. Vous pouvez également vous désinscrire de certaines pratiques de collecte de données.';

  @override
  String get privacy_policy_section_6_title => '6. Confidentialité des enfants';

  @override
  String get privacy_policy_section_6_content =>
      'Notre service n\'est pas destiné aux enfants de moins de 13 ans. Nous ne collectons pas sciemment d\'informations personnelles auprès d\'enfants de moins de 13 ans. Si vous pensez que nous avons collecté des informations auprès d\'un enfant, veuillez nous contacter immédiatement.';

  @override
  String get privacy_policy_section_7_title =>
      '7. Modifications de cette Politique de confidentialité';

  @override
  String get privacy_policy_section_7_content =>
      'Nous pouvons mettre à jour cette Politique de confidentialité de temps à autre. Nous vous informerons de tout changement en publiant la nouvelle Politique de confidentialité sur cette page et en mettant à jour la date de \"Dernière mise à jour\".';

  @override
  String get privacy_policy_contact =>
      'Si vous avez des questions concernant cette Politique de confidentialité, veuillez nous contacter.';

  @override
  String get auth_page_login_description =>
      'Bon retour ! Connectez-vous pour continuer votre parcours fitness.';

  @override
  String get auth_page_login_button => 'Connexion';

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
  String get email_verification_resend_button => 'D\'accord';

  @override
  String email_verification_error_signout(String error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get email_verification_check_tooltip =>
      'Vérifier le statut de vérification';

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

  @override
  String get home_welcome_title => 'Bienvenue !';

  @override
  String get home_placeholder_title => 'Page d\'accueil';

  @override
  String get home_placeholder_subtitle => 'Votre aventure fitness commence ici';

  @override
  String get home_user_fallback => 'Utilisateur';

  @override
  String get home_preview_front => 'AVANT';

  @override
  String get home_preview_back => 'ARRIÈRE';

  @override
  String get home_logout => 'Se déconnecter';

  @override
  String get sessions_create_success => 'Session créée !';

  @override
  String sessions_error_generic(String error) {
    return 'Erreur : $error';
  }

  @override
  String get sessions_create_title => 'Créer une session';

  @override
  String get sessions_name_label => 'Nom de la session';

  @override
  String get sessions_save_button => 'Enregistrer la session';

  @override
  String get sessions_list_title => 'Mes sessions';

  @override
  String get home_tab_home => 'Accueil';

  @override
  String get home_tab_sessions => 'Sessions';

  @override
  String get home_tab_lab => 'Labo';

  @override
  String get home_tab_programs => 'Programmes';

  @override
  String get home_tab_profile => 'Profil';

  @override
  String get home_placeholder_coming_soon => 'Bientôt disponible';

  @override
  String get workout_state_no_exercises => 'Aucun exercice dans cette session.';

  @override
  String workout_state_load_error(String error) {
    return 'Impossible de charger les exercices : $error';
  }

  @override
  String get workout_phase_get_ready => 'Prépare-toi';

  @override
  String get workout_phase_exercise => 'Exercice';

  @override
  String get workout_phase_finished => 'Entraînement terminé';

  @override
  String get workout_hint_tap_pause =>
      'Touchez le minuteur pour mettre en pause';

  @override
  String get workout_hint_tap_resume => 'Touchez le minuteur pour reprendre';

  @override
  String get workout_hint_tap_start => 'Touchez le minuteur pour démarrer';

  @override
  String get workout_current_label => 'Actuel';

  @override
  String get workout_next_label => 'Exercice suivant';

  @override
  String get workout_final_exercise => 'Dernier exercice en cours.';

  @override
  String get workout_tips_fallback =>
      'Garde le tronc engagé et contrôle le mouvement.';

  @override
  String workout_unnamed_exercise(int index) {
    return 'Exercice $index';
  }

  @override
  String get exercise_push_001_name => 'Pompes';

  @override
  String get exercise_push_001_description =>
      'Exercice classique au poids du corps ciblant la poitrine, les épaules et les triceps. Commencez en position de planche, descendez le corps jusqu\'à ce que la poitrine touche presque le sol, puis remontez.';

  @override
  String get exercise_push_001_beginner_tips =>
      'Commencez par des pompes sur les genoux si les pompes complètes sont trop difficiles. Gardez votre tronc serré et votre corps en ligne droite.';

  @override
  String get exercise_push_002_name => 'Pompes inclinées';

  @override
  String get exercise_push_002_description =>
      'Variation plus facile des pompes effectuée avec les mains surélevées sur une chaise ou un mur. Réduit la charge du poids du corps, parfait pour les débutants.';

  @override
  String get exercise_push_002_beginner_tips =>
      'Placez les mains sur une chaise solide ou un mur. Plus la surface est haute, plus l\'exercice est facile.';

  @override
  String get exercise_push_005_name => 'Pompes larges';

  @override
  String get exercise_push_005_description =>
      'Pompes avec les mains placées plus larges que la largeur des épaules. Cible la poitrine extérieure et les épaules plus que les pompes standards.';

  @override
  String get exercise_push_005_beginner_tips =>
      'Placez les mains plus larges que la largeur des épaules. Gardez les coudes légèrement écartés pendant le mouvement.';

  @override
  String get exercise_push_007_name => 'Pompes au mur';

  @override
  String get exercise_push_007_description =>
      'Pompes adaptées aux débutants effectuées debout contre un mur. Parfait pour ceux qui développent la force du haut du corps.';

  @override
  String get exercise_push_007_beginner_tips =>
      'Tenez-vous face au mur, placez les mains sur le mur à hauteur d\'épaule. Reculez pour augmenter la difficulté.';

  @override
  String get exercise_push_008_name => 'Pompes sur les genoux';

  @override
  String get exercise_push_008_description =>
      'Pompes modifiées effectuées sur les genoux au lieu des orteils. Réduit considérablement la charge du poids du corps.';

  @override
  String get exercise_push_008_beginner_tips =>
      'Gardez votre corps droit des genoux à la tête. Ne laissez pas vos hanches s\'affaisser ou monter trop haut.';

  @override
  String get exercise_push_015_name => 'Chaise au mur';

  @override
  String get exercise_push_015_description =>
      'Exercice isométrique des jambes effectué contre un mur. Développe l\'endurance des quadriceps et des fessiers.';

  @override
  String get exercise_push_015_beginner_tips =>
      'Glissez le long du mur jusqu\'à ce que les cuisses soient parallèles au sol. Maintenez la position avec le dos plat contre le mur.';

  @override
  String get exercise_pull_001_name => 'Tractions inversées';

  @override
  String get exercise_pull_001_description =>
      'Exercice de rowing au poids du corps utilisant une table ou une surface solide. Excellent pour développer la force du dos et des biceps sans équipement.';

  @override
  String get exercise_pull_001_beginner_tips =>
      'Utilisez une table ou une chaise solide. Gardez le corps droit, tirez la poitrine vers la surface. Ajustez l\'angle pour changer la difficulté.';

  @override
  String get exercise_pull_002_name => 'Superman';

  @override
  String get exercise_pull_002_description =>
      'Exercice allongé ciblant le bas du dos et les fessiers. Allongez-vous face contre terre, soulevez les bras et les jambes simultanément, maintenez brièvement.';

  @override
  String get exercise_pull_002_beginner_tips =>
      'Soulevez seulement aussi haut que confortable. Concentrez-vous sur la contraction des fessiers et des muscles du bas du dos.';

  @override
  String get exercise_pull_003_name => 'Anges de neige inversés';

  @override
  String get exercise_pull_003_description =>
      'Exercice allongé où vous bougez les bras en mouvement d\'ange de neige. Renforce les deltoïdes postérieurs et le haut du dos.';

  @override
  String get exercise_pull_003_beginner_tips =>
      'Gardez les bras droits et soulevez-les du sol. Bougez lentement et de manière contrôlée dans toute l\'amplitude de mouvement.';

  @override
  String get exercise_pull_004_name => 'Élévations Y-T-W';

  @override
  String get exercise_pull_004_description =>
      'Série d\'exercices allongés formant des formes Y, T et W avec les bras. Cible tout le haut du dos et les deltoïdes postérieurs.';

  @override
  String get exercise_pull_004_beginner_tips =>
      'Effectuez chaque forme de lettre séparément. Gardez le tronc engagé et évitez de cambrer excessivement le bas du dos.';

  @override
  String get exercise_pull_005_name => 'Anges au mur';

  @override
  String get exercise_pull_005_description =>
      'Exercice debout contre le mur imitant les anges de neige. Améliore la posture et renforce les muscles du haut du dos.';

  @override
  String get exercise_pull_005_beginner_tips =>
      'Gardez le dos, la tête et les bras en contact avec le mur. Bougez lentement et maintenez le contact tout au long du mouvement.';

  @override
  String get exercise_pull_006_name => 'Élévation Y allongé';

  @override
  String get exercise_pull_006_description =>
      'Exercice allongé soulevant les bras en position Y. Cible les trapèzes supérieurs et les deltoïdes postérieurs.';

  @override
  String get exercise_pull_006_beginner_tips =>
      'Soulevez les bras à un angle de 45 degrés. Serrez les omoplates ensemble en haut.';

  @override
  String get exercise_pull_007_name => 'Élévation T allongé';

  @override
  String get exercise_pull_007_description =>
      'Exercice allongé soulevant les bras droit sur les côtés formant une forme T. Renforce les deltoïdes postérieurs et les trapèzes moyens.';

  @override
  String get exercise_pull_007_beginner_tips =>
      'Gardez les bras droits et soulevez-les parallèlement au sol. Concentrez-vous sur la contraction des omoplates.';

  @override
  String get exercise_pull_008_name => 'Élévation W allongé';

  @override
  String get exercise_pull_008_description =>
      'Exercice allongé avec les bras pliés formant une forme W. Cible les rhomboïdes et les deltoïdes postérieurs.';

  @override
  String get exercise_pull_008_beginner_tips =>
      'Pliez les coudes et soulevez les bras, en serrant les omoplates ensemble. Gardez le tronc engagé.';

  @override
  String get exercise_pull_010_name => 'Glissades scapulaires au mur';

  @override
  String get exercise_pull_010_description =>
      'Exercice de posture effectué contre le mur. Renforce le haut du dos et améliore la mobilité des épaules.';

  @override
  String get exercise_pull_010_beginner_tips =>
      'Gardez le dos, la tête et les bras contre le mur. Faites glisser les bras de haut en bas tout en maintenant le contact.';

  @override
  String get exercise_pull_015_name => 'Rowing dans l\'encadrement';

  @override
  String get exercise_pull_015_description =>
      'Exercice de rowing utilisant l\'encadrement de porte. Tenez-vous dans l\'encadrement, tirez le corps vers l\'encadrement en utilisant les muscles du dos.';

  @override
  String get exercise_pull_015_beginner_tips =>
      'Utilisez un encadrement solide. Placez les mains sur l\'encadrement, penchez-vous en arrière et tirez le corps vers l\'avant. Ajustez l\'angle pour la difficulté.';

  @override
  String get exercise_pull_018_name => 'Écarté inversé';

  @override
  String get exercise_pull_018_description =>
      'Exercice allongé imitant le mouvement d\'écarté inversé. Renforce les deltoïdes postérieurs et le haut du dos sans poids.';

  @override
  String get exercise_pull_018_beginner_tips =>
      'Allongez-vous face contre terre, soulevez les bras sur les côtés. Serrez les omoplates ensemble en haut.';

  @override
  String get exercise_legs_001_name => 'Squat au poids du corps';

  @override
  String get exercise_legs_001_description =>
      'Exercice fondamental du bas du corps. Tenez-vous avec les pieds à largeur d\'épaules, descendez comme si vous vous asseyiez sur une chaise, puis relevez-vous.';

  @override
  String get exercise_legs_001_beginner_tips =>
      'Gardez les genoux alignés sur les orteils. Descendez jusqu\'à ce que les cuisses soient parallèles au sol ou aussi bas que confortable.';

  @override
  String get exercise_legs_005_name => 'Fente avant';

  @override
  String get exercise_legs_005_description =>
      'Exercice unilatéral de la jambe en avançant. Cible les quadriceps, les fessiers et améliore l\'équilibre.';

  @override
  String get exercise_legs_005_beginner_tips =>
      'Avancez, descendez le genou arrière vers le sol. Gardez le genou avant au-dessus de la cheville. Poussez pour revenir au départ.';

  @override
  String get exercise_legs_006_name => 'Fente arrière';

  @override
  String get exercise_legs_006_description =>
      'Variation de fente en reculant. Plus doux pour les genoux et met l\'accent sur les fessiers plus que la fente avant.';

  @override
  String get exercise_legs_006_beginner_tips =>
      'Reculez, descendez jusqu\'à ce que les deux genoux forment des angles de 90 degrés. Poussez pour revenir à la position de départ.';

  @override
  String get exercise_legs_009_name => 'Fente latérale';

  @override
  String get exercise_legs_009_description =>
      'Variation de fente latérale en avançant sur le côté. Cible l\'intérieur des cuisses et améliore la mobilité de la hanche.';

  @override
  String get exercise_legs_009_beginner_tips =>
      'Avancez sur le côté, descendez en gardant l\'autre jambe droite. Poussez pour revenir au centre. Alternez les côtés.';

  @override
  String get exercise_legs_010_name => 'Relevé de mollets';

  @override
  String get exercise_legs_010_description =>
      'Exercice isolé des mollets. Tenez-vous sur la pointe des pieds, montez sur les orteils, puis descendez lentement.';

  @override
  String get exercise_legs_010_beginner_tips =>
      'Montez aussi haut que possible, maintenez brièvement, puis descendez lentement. Peut être fait sur le sol ou une surface surélevée.';

  @override
  String get exercise_legs_012_name => 'Pont fessier';

  @override
  String get exercise_legs_012_description =>
      'Exercice d\'extension de hanche ciblant les fessiers et les ischio-jambiers. Allongez-vous sur le dos, soulevez les hanches, serrez les fessiers.';

  @override
  String get exercise_legs_012_beginner_tips =>
      'Gardez les pieds à plat sur le sol, soulevez les hanches jusqu\'à ce que le corps forme une ligne droite. Serrez les fessiers en haut.';

  @override
  String get exercise_legs_014_name => 'Coups de pied d\'âne';

  @override
  String get exercise_legs_014_description =>
      'Exercice à quatre pattes ciblant les fessiers. Commencez sur les mains et les genoux, donnez un coup de pied avec une jambe vers l\'arrière et vers le haut.';

  @override
  String get exercise_legs_014_beginner_tips =>
      'Gardez le tronc engagé et le dos droit. Soulevez la jambe sans cambrer le bas du dos. Serrez le fessier en haut.';

  @override
  String get exercise_legs_015_name => 'Borne d\'incendie';

  @override
  String get exercise_legs_015_description =>
      'Exercice à quatre pattes soulevant la jambe sur le côté. Cible les fessiers et les abducteurs de hanche.';

  @override
  String get exercise_legs_015_beginner_tips =>
      'Commencez sur les mains et les genoux. Soulevez la jambe sur le côté, en gardant le genou plié. Ne tournez pas les hanches.';

  @override
  String get exercise_legs_016_name => 'Coquillages';

  @override
  String get exercise_legs_016_description =>
      'Exercice allongé sur le côté ciblant les abducteurs de hanche et les fessiers. Allongez-vous sur le côté, soulevez le genou supérieur tout en gardant les pieds ensemble.';

  @override
  String get exercise_legs_016_beginner_tips =>
      'Gardez les pieds ensemble, soulevez seulement le genou. Ne roulez pas en arrière. Bougez lentement et de manière contrôlée.';

  @override
  String get exercise_legs_017_name => 'Relevés de jambes';

  @override
  String get exercise_legs_017_description =>
      'Exercice du tronc et des fléchisseurs de hanche. Allongez-vous sur le dos, soulevez les jambes droit vers le haut, puis descendez lentement.';

  @override
  String get exercise_legs_017_beginner_tips =>
      'Gardez le bas du dos pressé contre le sol. Descendez les jambes seulement aussi loin que vous pouvez maintenir le contact du dos.';

  @override
  String get exercise_legs_020_name => 'Montée sur banc';

  @override
  String get exercise_legs_020_description =>
      'Exercice unilatéral de la jambe utilisant une chaise ou un marchepied. Montez sur la surface, puis redescendez.';

  @override
  String get exercise_legs_020_beginner_tips =>
      'Utilisez une chaise ou un marchepied solide. Placez tout le pied sur la surface. Poussez avec le talon pour monter.';

  @override
  String get exercise_legs_021_name => 'Squat sumo';

  @override
  String get exercise_legs_021_description =>
      'Variation de squat en position large. Cible l\'intérieur des cuisses et les fessiers plus que le squat standard.';

  @override
  String get exercise_legs_021_beginner_tips =>
      'Tenez-vous avec les pieds plus larges que la largeur des épaules, les orteils pointés légèrement vers l\'extérieur. Descendez, en gardant les genoux alignés sur les orteils.';

  @override
  String get exercise_core_001_name => 'Planche';

  @override
  String get exercise_core_001_description =>
      'Exercice fondamental du tronc. Maintenez le corps en ligne droite soutenu par les avant-bras et les orteils. Développe la force et la stabilité du tronc.';

  @override
  String get exercise_core_001_beginner_tips =>
      'Gardez le corps droit de la tête aux talons. Ne laissez pas les hanches s\'affaisser ou monter. Commencez avec 20-30 secondes.';

  @override
  String get exercise_core_002_name => 'Planche latérale';

  @override
  String get exercise_core_002_description =>
      'Exercice unilatéral du tronc effectué sur le côté. Cible les obliques et améliore la stabilité latérale.';

  @override
  String get exercise_core_002_beginner_tips =>
      'Soutenez le corps sur un avant-bras et le côté du pied. Gardez le corps droit. Commencez avec 15-20 secondes de chaque côté.';

  @override
  String get exercise_core_004_name => 'Crunchs vélo';

  @override
  String get exercise_core_004_description =>
      'Exercice rotatif du tronc imitant le mouvement de vélo. Cible efficacement les abdominaux et les obliques.';

  @override
  String get exercise_core_004_beginner_tips =>
      'Allongez-vous sur le dos, amenez le coude opposé au genou. Étendez l\'autre jambe. Bougez lentement et de manière contrôlée.';

  @override
  String get exercise_core_005_name => 'Twists russes';

  @override
  String get exercise_core_005_description =>
      'Exercice rotatif assis ciblant les obliques. Asseyez-vous avec les genoux pliés, penchez-vous légèrement en arrière, tournez le torse de côté à côté.';

  @override
  String get exercise_core_005_beginner_tips =>
      'Gardez le tronc engagé et le dos droit. Tournez depuis le torse, pas seulement les bras. Commencez sans poids.';

  @override
  String get exercise_core_006_name => 'Battements de jambes';

  @override
  String get exercise_core_006_description =>
      'Exercice du tronc effectué allongé sur le dos. Donnez des coups de pied alternativement de haut en bas tout en gardant le tronc engagé.';

  @override
  String get exercise_core_006_beginner_tips =>
      'Gardez le bas du dos pressé contre le sol. Bougez les jambes en petits mouvements contrôlés. Ne cambrez pas le dos.';

  @override
  String get exercise_core_007_name => 'Insecte mort';

  @override
  String get exercise_core_007_description =>
      'Exercice de stabilité du tronc effectué sur le dos. Étendez le bras et la jambe opposés tout en maintenant l\'engagement du tronc.';

  @override
  String get exercise_core_007_beginner_tips =>
      'Gardez le bas du dos pressé contre le sol. Bougez lentement et de manière contrôlée. Alternez le bras et la jambe opposés.';

  @override
  String get exercise_core_008_name => 'Chien oiseau';

  @override
  String get exercise_core_008_description =>
      'Exercice de stabilité du tronc à quatre pattes. Étendez le bras et la jambe opposés tout en maintenant l\'équilibre.';

  @override
  String get exercise_core_008_beginner_tips =>
      'Commencez sur les mains et les genoux. Étendez le bras et la jambe opposés. Maintenez brièvement, puis changez de côté.';

  @override
  String get exercise_core_011_name => 'Touches d\'orteils';

  @override
  String get exercise_core_011_description =>
      'Exercice du tronc en atteignant les orteils. Allongez-vous sur le dos, soulevez les jambes et atteignez les mains vers les orteils.';

  @override
  String get exercise_core_011_beginner_tips =>
      'Gardez les jambes aussi droites que possible. Soulevez les épaules du sol. Atteignez vers le haut, pas vers l\'avant.';

  @override
  String get exercise_core_012_name => 'Crunchs inversés';

  @override
  String get exercise_core_012_description =>
      'Exercice du tronc soulevant les hanches. Allongez-vous sur le dos, amenez les genoux vers la poitrine, soulevez les hanches du sol.';

  @override
  String get exercise_core_012_beginner_tips =>
      'Gardez les genoux pliés. Soulevez les hanches en contractant les abdominaux, pas en balançant les jambes. Descendez lentement.';

  @override
  String get exercise_cardio_001_name => 'Sauts écartés';

  @override
  String get exercise_cardio_001_description =>
      'Exercice cardio classique pour tout le corps. Écartez les pieds en sautant tout en levant les bras au-dessus de la tête, puis revenez.';

  @override
  String get exercise_cardio_001_beginner_tips =>
      'Commencez lentement pour maîtriser la coordination. Atterrissez doucement sur la pointe des pieds. Peut être fait en faible impact en marchant au lieu de sauter.';

  @override
  String get exercise_cardio_002_name => 'Genoux hauts';

  @override
  String get exercise_cardio_002_description =>
      'Course sur place en montant les genoux haut. Excellent exercice cardio qui améliore également la coordination.';

  @override
  String get exercise_cardio_002_beginner_tips =>
      'Courez sur place, en montant les genoux vers la poitrine. Pompez les bras naturellement. Commencez avec 20-30 secondes.';

  @override
  String get exercise_cardio_003_name => 'Talons-fesses';

  @override
  String get exercise_cardio_003_description =>
      'Course sur place en donnant des coups de talon vers les fessiers. Cible les ischio-jambiers tout en offrant des bienfaits cardio.';

  @override
  String get exercise_cardio_003_beginner_tips =>
      'Courez sur place, donnez des coups de talon vers les fessiers. Gardez les genoux pointés vers le bas. Commencez avec 20-30 secondes.';

  @override
  String get exercise_cardio_009_name => 'Boxe de l\'ombre';

  @override
  String get exercise_cardio_009_description =>
      'Exercice cardio imitant les mouvements de boxe. Lancez des coups de poing en l\'air, combinant cardio et coordination.';

  @override
  String get exercise_cardio_009_beginner_tips =>
      'Lancez des directs, croisés, crochets et uppercuts. Continuez à bouger, ne vous arrêtez pas entre les coups. Rounds de 30-60 secondes.';

  @override
  String get exercise_cardio_010_name => 'Saut à la corde (sans corde)';

  @override
  String get exercise_cardio_010_description =>
      'Imitez le mouvement de saut à la corde sans équipement. Sautez légèrement sur la pointe des pieds, en tournant les poignets comme si vous teniez une corde.';

  @override
  String get exercise_cardio_010_beginner_tips =>
      'Sautez légèrement sur la pointe des pieds. Tournez les poignets comme si vous teniez une corde. Commencez avec 20-30 secondes.';

  @override
  String get exercise_cardio_014_name => 'Danse sur place';

  @override
  String get exercise_cardio_014_description =>
      'Exercice cardio amusant en bougeant sur la musique. Mouvements de danse libre pour augmenter le rythme cardiaque.';

  @override
  String get exercise_cardio_014_beginner_tips =>
      'Bougez votre corps sur la musique. Incluez des mouvements de bras, des levées de jambes et des mouvements de hanches. Amusez-vous !';

  @override
  String get exercise_push_003_name => 'Pompes déclinées';

  @override
  String get exercise_push_003_description =>
      'Variation avancée de pompes avec les pieds surélevés sur une chaise. Augmente la difficulté en déplaçant plus de poids vers le haut du corps.';

  @override
  String get exercise_push_003_beginner_tips =>
      'Commencez avec une faible élévation et augmentez progressivement. Assurez-vous que la chaise est stable et ne glissera pas.';

  @override
  String get exercise_push_004_name => 'Pompes diamant';

  @override
  String get exercise_push_004_description =>
      'Variation de pompes avec les mains formant une forme de diamant. Met l\'accent sur les triceps et les muscles internes de la poitrine.';

  @override
  String get exercise_push_004_beginner_tips =>
      'Commencez par des pompes régulières pour développer la force. Placez les pouces et les index ensemble pour former un diamant.';

  @override
  String get exercise_push_006_name => 'Pompes pike';

  @override
  String get exercise_push_006_description =>
      'Pompes effectuées en position chien tête en bas. Excellent pour développer la force des épaules et se préparer aux pompes en équilibre sur les mains.';

  @override
  String get exercise_push_006_beginner_tips =>
      'Commencez avec les pieds plus écartés pour un meilleur équilibre. Descendez la tête vers le sol entre les mains, puis remontez.';

  @override
  String get exercise_push_010_name => 'Pompes hindoues';

  @override
  String get exercise_push_010_description =>
      'Variation dynamique de pompes avec un mouvement fluide. Combine l\'entraînement en force avec le travail de mobilité.';

  @override
  String get exercise_push_010_beginner_tips =>
      'Commencez en chien tête en bas, descendez en position chien tête en haut, puis revenez. Concentrez-vous sur un mouvement fluide et contrôlé.';

  @override
  String get exercise_push_011_name => 'Pompes Spiderman';

  @override
  String get exercise_push_011_description =>
      'Variation de pompes où vous amenez le genou au coude pendant la phase de descente. Ajoute l\'engagement du tronc et la mobilité de la hanche.';

  @override
  String get exercise_push_011_beginner_tips =>
      'Commencez par des pompes régulières. Ajoutez le mouvement du genou une fois que vous êtes à l\'aise avec l\'exercice de base.';

  @override
  String get exercise_push_012_name => 'Pompes avec tapotement d\'épaule';

  @override
  String get exercise_push_012_description =>
      'Variation de pompes où vous tapez l\'épaule opposée en haut de chaque répétition. Défie la stabilité et la force du tronc.';

  @override
  String get exercise_push_012_beginner_tips =>
      'Maîtrisez d\'abord les pompes régulières. Gardez vos hanches au même niveau et évitez de tourner votre corps en tapotant.';

  @override
  String get exercise_push_013_name => 'Dips triceps';

  @override
  String get exercise_push_013_description =>
      'Exercice du haut du corps utilisant une chaise. Cible les triceps, les épaules et la poitrine. Asseyez-vous sur le bord de la chaise, descendez le corps, puis remontez.';

  @override
  String get exercise_push_013_beginner_tips =>
      'Gardez les pieds plus près de la chaise pour une variation plus facile. Assurez-vous que la chaise est stable et ne basculera pas.';

  @override
  String get exercise_push_014_name => 'Dips triceps diamant';

  @override
  String get exercise_push_014_description =>
      'Dips triceps avec les mains rapprochées en position diamant. Augmente l\'accent sur les triceps et la difficulté.';

  @override
  String get exercise_push_014_beginner_tips =>
      'Maîtrisez d\'abord les dips triceps réguliers. Placez les mains rapprochées avec les doigts pointés vers l\'avant.';

  @override
  String get exercise_push_020_name => 'Pompes plongeant';

  @override
  String get exercise_push_020_description =>
      'Variation dynamique de pompes combinant les positions chien tête en bas, pompe basse et chien tête en haut en un seul mouvement fluide.';

  @override
  String get exercise_push_020_beginner_tips =>
      'Commencez lentement pour maîtriser le schéma de mouvement. Concentrez-vous sur des transitions fluides entre les positions.';

  @override
  String get exercise_pull_009_name => 'Planche inversée';

  @override
  String get exercise_pull_009_description =>
      'Exercice au poids du corps effectué face vers le haut. Renforce la chaîne postérieure incluant le dos, les fessiers et les ischio-jambiers.';

  @override
  String get exercise_pull_009_beginner_tips =>
      'Commencez avec les genoux pliés et redressez progressivement les jambes au fur et à mesure que vous devenez plus fort. Gardez les hanches surélevées.';

  @override
  String get exercise_pull_011_name => 'Maintien isométrique de traction';

  @override
  String get exercise_pull_011_description =>
      'Exercice de maintien statique imitant la position de traction. Développe la force de préhension et l\'endurance du dos.';

  @override
  String get exercise_pull_011_beginner_tips =>
      'Accrochez-vous à une barre ou une surface solide. Maintenez le menton au-dessus de la barre aussi longtemps que possible. Utilisez une assistance si nécessaire.';

  @override
  String get exercise_pull_012_name => 'Marche en planche inversée';

  @override
  String get exercise_pull_012_description =>
      'Variation dynamique de planche inversée. Marchez avec les mains vers l\'arrière tout en maintenant la position de planche inversée.';

  @override
  String get exercise_pull_012_beginner_tips =>
      'Commencez avec de petits pas. Gardez les hanches surélevées et le corps droit tout au long du mouvement.';

  @override
  String get exercise_pull_013_name => 'Rowing à un bras';

  @override
  String get exercise_pull_013_description =>
      'Exercice de rowing unilatéral utilisant le poids du corps. Peut être effectué avec une serviette ou une bande de résistance si disponible.';

  @override
  String get exercise_pull_013_beginner_tips =>
      'Utilisez une serviette enroulée autour d\'une poignée de porte ou une ancre solide. Tirez avec un bras, en vous concentrant sur la contraction des muscles du dos.';

  @override
  String get exercise_pull_014_name => 'Rowing avec serviette';

  @override
  String get exercise_pull_014_description =>
      'Exercice de rowing utilisant une serviette pour la prise. Enroulez la serviette autour de la poignée de porte ou d\'une ancre solide et ramez.';

  @override
  String get exercise_pull_014_beginner_tips =>
      'Assurez-vous que la porte ou l\'ancre est sécurisée. Ajustez la distance pour changer la difficulté. Plus près = plus facile, plus loin = plus difficile.';

  @override
  String get exercise_pull_016_name => 'Tractions australiennes';

  @override
  String get exercise_pull_016_description =>
      'Exercice de traction horizontal utilisant une table ou une barre. Corps positionné horizontalement, tirez la poitrine vers la surface.';

  @override
  String get exercise_pull_016_beginner_tips =>
      'Utilisez une table solide ou une barre basse. Gardez le corps droit. Surface plus haute = plus facile, plus basse = plus difficile.';

  @override
  String get exercise_pull_017_name => 'Négatif de traction';

  @override
  String get exercise_pull_017_description =>
      'Phase excentrique de traction. Sautez ou montez jusqu\'à la position haute, puis descendez lentement. Développe la force pour les tractions complètes.';

  @override
  String get exercise_pull_017_beginner_tips =>
      'Utilisez une chaise pour atteindre la position haute. Descendez aussi lentement que possible, visant une descente de 3-5 secondes.';

  @override
  String get exercise_pull_019_name => 'Tractions inversées prise large';

  @override
  String get exercise_pull_019_description =>
      'Traction inversée avec les mains placées plus larges que la largeur des épaules. Met l\'accent sur le dos extérieur et les deltoïdes postérieurs.';

  @override
  String get exercise_pull_019_beginner_tips =>
      'Utilisez une table ou une barre. Placez les mains plus larges que les épaules. Tirez la poitrine vers la surface tout en gardant le corps droit.';

  @override
  String get exercise_pull_020_name => 'Tractions inversées prise serrée';

  @override
  String get exercise_pull_020_description =>
      'Traction inversée avec les mains rapprochées. Augmente l\'accent sur les biceps et la difficulté.';

  @override
  String get exercise_pull_020_beginner_tips =>
      'Placez les mains rapprochées, paumes face à face si possible. Tirez avec les biceps et les muscles du dos.';

  @override
  String get exercise_legs_002_name => 'Squat sauté';

  @override
  String get exercise_legs_002_description =>
      'Variation explosive de squat avec un saut en haut. Développe la puissance et l\'athlétisme dans le bas du corps.';

  @override
  String get exercise_legs_002_beginner_tips =>
      'Maîtrisez d\'abord les squats réguliers. Atterrissez doucement avec les genoux légèrement pliés pour absorber l\'impact.';

  @override
  String get exercise_legs_004_name => 'Squat bulgare';

  @override
  String get exercise_legs_004_description =>
      'Squat à une jambe avec le pied arrière surélevé sur une chaise. Excellent pour développer la force unilatérale des jambes.';

  @override
  String get exercise_legs_004_beginner_tips =>
      'Placez le pied arrière sur une chaise derrière vous. Descendez, en gardant le genou avant au-dessus de la cheville. Commencez avec une profondeur peu profonde.';

  @override
  String get exercise_legs_007_name => 'Fente marchée';

  @override
  String get exercise_legs_007_description =>
      'Variation dynamique de fente en avançant. Combine l\'entraînement en force avec la coordination.';

  @override
  String get exercise_legs_007_beginner_tips =>
      'Commencez avec des fentes stationnaires. Alternez les jambes en avançant, en maintenant une bonne forme.';

  @override
  String get exercise_legs_008_name => 'Fente sautée';

  @override
  String get exercise_legs_008_description =>
      'Variation explosive de fente avec un saut entre les répétitions. Développe la puissance et la forme cardiovasculaire.';

  @override
  String get exercise_legs_008_beginner_tips =>
      'Maîtrisez d\'abord les fentes régulières. Atterrissez doucement et changez de jambe en l\'air. Commencez avec de petits sauts.';

  @override
  String get exercise_legs_011_name => 'Relevé de mollets à une jambe';

  @override
  String get exercise_legs_011_description =>
      'Exercice unilatéral des mollets. Effectué sur une jambe pour augmenter la difficulté et corriger les déséquilibres.';

  @override
  String get exercise_legs_011_beginner_tips =>
      'Maîtrisez d\'abord les relevés de mollets à deux jambes. Tenez-vous à quelque chose pour l\'équilibre si nécessaire.';

  @override
  String get exercise_legs_013_name => 'Pont fessier à une jambe';

  @override
  String get exercise_legs_013_description =>
      'Variation avancée de pont fessier effectuée sur une jambe. Augmente considérablement la difficulté et l\'activation des fessiers.';

  @override
  String get exercise_legs_013_beginner_tips =>
      'Maîtrisez d\'abord le pont fessier régulier. Étendez une jambe droite, soulevez les hanches avec une jambe.';

  @override
  String get exercise_legs_018_name => 'Soulevé de terre à une jambe';

  @override
  String get exercise_legs_018_description =>
      'Exercice unilatéral de charnière de hanche. Développe l\'équilibre, la force des ischio-jambiers et l\'activation des fessiers.';

  @override
  String get exercise_legs_018_beginner_tips =>
      'Commencez avec une petite amplitude de mouvement. Pivotez aux hanches, étendez la jambe opposée vers l\'arrière. Gardez le dos droit.';

  @override
  String get exercise_legs_023_name => 'Squat cosaque';

  @override
  String get exercise_legs_023_description =>
      'Variation latérale de squat avec une jambe étendue. Améliore la mobilité de la hanche et développe la force des jambes.';

  @override
  String get exercise_legs_023_beginner_tips =>
      'Déplacez le poids sur un côté, descendez tout en étendant l\'autre jambe. Gardez la jambe étendue droite.';

  @override
  String get exercise_legs_025_name => 'Pulsation chaise au mur';

  @override
  String get exercise_legs_025_description =>
      'Variation dynamique de chaise au mur. Maintenez la position de chaise au mur, puis pulsez légèrement de haut en bas.';

  @override
  String get exercise_legs_025_beginner_tips =>
      'Commencez en position de chaise au mur. Pulsez de haut en bas de 2-3 pouces. Gardez le dos contre le mur tout au long.';

  @override
  String get exercise_core_003_name => 'Grimpeurs';

  @override
  String get exercise_core_003_description =>
      'Exercice dynamique du tronc en alternant les genoux vers la poitrine. Combine la force avec l\'entraînement cardiovasculaire.';

  @override
  String get exercise_core_003_beginner_tips =>
      'Commencez en position de planche. Alternez en amenant les genoux vers la poitrine. Gardez les hanches au même niveau, ne rebondissez pas.';

  @override
  String get exercise_core_009_name => 'Maintien corps creux';

  @override
  String get exercise_core_009_description =>
      'Exercice isométrique avancé du tronc. Allongez-vous sur le dos, soulevez les épaules et les jambes, maintenez la position.';

  @override
  String get exercise_core_009_beginner_tips =>
      'Commencez avec les genoux pliés. Redressez progressivement les jambes au fur et à mesure que vous devenez plus fort. Gardez le bas du dos pressé contre le sol.';

  @override
  String get exercise_core_010_name => 'V-ups';

  @override
  String get exercise_core_010_description =>
      'Exercice avancé du tronc formant une forme V. Allongez-vous sur le dos, soulevez le torse et les jambes simultanément pour se toucher.';

  @override
  String get exercise_core_010_beginner_tips =>
      'Commencez avec les genoux pliés. Travaillez progressivement vers des jambes droites. N\'utilisez pas l\'élan.';

  @override
  String get exercise_core_013_name => 'Planche sautée';

  @override
  String get exercise_core_013_description =>
      'Variation dynamique de planche en sautant les pieds écartés et ensemble. Combine la force du tronc avec le cardio.';

  @override
  String get exercise_core_013_beginner_tips =>
      'Commencez en position de planche. Sautez les pieds écartés et ensemble tout en maintenant la position de planche.';

  @override
  String get exercise_core_014_name => 'Marche de l\'ours';

  @override
  String get exercise_core_014_description =>
      'Exercice de mouvement à quatre pattes. Rampez vers l\'avant et l\'arrière sur les mains et les pieds, en gardant les genoux du sol.';

  @override
  String get exercise_core_014_beginner_tips =>
      'Gardez le tronc engagé et le dos plat. Bougez la main et le pied opposés ensemble. Commencez avec de courtes distances.';

  @override
  String get exercise_core_015_name => 'Marche du crabe';

  @override
  String get exercise_core_015_description =>
      'Mouvement à quatre pattes inversé. Asseyez-vous avec les mains derrière vous, soulevez les hanches, marchez vers l\'avant et l\'arrière.';

  @override
  String get exercise_core_015_beginner_tips =>
      'Gardez les hanches surélevées tout au long. Bougez la main et le pied opposés ensemble. Commencez avec de courtes distances.';

  @override
  String get exercise_core_016_name => 'Essuie-glaces';

  @override
  String get exercise_core_016_description =>
      'Exercice du tronc en bougeant les jambes de côté à côté. Allongez-vous sur le dos, soulevez les jambes, tournez-les de côté à côté.';

  @override
  String get exercise_core_016_beginner_tips =>
      'Gardez les jambes ensemble et le bas du dos pressé contre le sol. Bougez lentement et de manière contrôlée.';

  @override
  String get exercise_core_018_name => 'Planche vers chien tête en bas';

  @override
  String get exercise_core_018_description =>
      'Mouvement dynamique en transition de la planche vers le chien tête en bas. Combine la force du tronc avec la mobilité.';

  @override
  String get exercise_core_018_beginner_tips =>
      'Commencez en planche, poussez les hanches vers le chien tête en bas, puis revenez. Bougez lentement et de manière contrôlée.';

  @override
  String get exercise_core_019_name => 'Planche latérale avec levée de jambe';

  @override
  String get exercise_core_019_description =>
      'Variation avancée de planche latérale. Maintenez la planche latérale, soulevez la jambe supérieure de haut en bas.';

  @override
  String get exercise_core_019_beginner_tips =>
      'Maîtrisez d\'abord la planche latérale régulière. Soulevez la jambe lentement, en gardant le corps droit. Ne tournez pas les hanches.';

  @override
  String get exercise_core_020_name => 'Planche haut-bas';

  @override
  String get exercise_core_020_description =>
      'Variation dynamique de planche en transition entre planche haute et basse. Alterne entre les mains et les avant-bras.';

  @override
  String get exercise_core_020_beginner_tips =>
      'Commencez en planche, poussez vers la planche haute un bras à la fois, puis redescendez. Gardez le tronc engagé.';

  @override
  String get exercise_cardio_004_name => 'Burpees';

  @override
  String get exercise_cardio_004_description =>
      'Exercice explosif pour tout le corps combinant squat, planche, pompe et saut. Défi cardio ultime au poids du corps.';

  @override
  String get exercise_cardio_004_beginner_tips =>
      'Commencez par des burpees sans saut. Maîtrisez chaque composante séparément avant de combiner. Atterrissez doucement du saut.';

  @override
  String get exercise_cardio_005_name => 'Sauts patineur';

  @override
  String get exercise_cardio_005_description =>
      'Exercice de saut latéral imitant le mouvement de patinage sur glace. Développe la puissance, l\'équilibre et la forme cardiovasculaire.';

  @override
  String get exercise_cardio_005_beginner_tips =>
      'Sautez de côté à côté, en atterrissant sur un pied. Balancez le bras opposé à travers le corps. Commencez avec de petits sauts.';

  @override
  String get exercise_cardio_006_name => 'Sauts en étoile';

  @override
  String get exercise_cardio_006_description =>
      'Exercice de saut explosif formant une forme d\'étoile. Sautez, écartez largement les bras et les jambes, puis revenez.';

  @override
  String get exercise_cardio_006_beginner_tips =>
      'Sautez, écartez largement les bras et les jambes au sommet. Atterrissez doucement avec les pieds ensemble. Commencez avec de petits sauts.';

  @override
  String get exercise_cardio_007_name => 'Sauts groupés';

  @override
  String get exercise_cardio_007_description =>
      'Saut explosif en amenant les genoux vers la poitrine. Développe la puissance et la forme cardiovasculaire.';

  @override
  String get exercise_cardio_007_beginner_tips =>
      'Sautez aussi haut que possible, en amenant les genoux vers la poitrine. Atterrissez doucement avec les genoux légèrement pliés.';

  @override
  String get exercise_cardio_008_name => 'Chenilles';

  @override
  String get exercise_cardio_008_description =>
      'Exercice de mouvement pour tout le corps. Tenez-vous debout, marchez avec les mains jusqu\'à la planche, puis marchez avec les pieds jusqu\'aux mains.';

  @override
  String get exercise_cardio_008_beginner_tips =>
      'Gardez les jambes aussi droites que possible en marchant avec les mains. Bougez lentement et de manière contrôlée.';

  @override
  String get exercise_cardio_011_name => 'Pieds rapides';

  @override
  String get exercise_cardio_011_description =>
      'Exercice cardio haute intensité. Courez sur place aussi vite que possible, en restant sur la pointe des pieds.';

  @override
  String get exercise_cardio_011_beginner_tips =>
      'Restez sur la pointe des pieds, bougez les pieds aussi vite que possible. Gardez le tronc engagé. Commencez avec des rafales de 10-15 secondes.';

  @override
  String get exercise_cardio_012_name => 'Sauts de squat';

  @override
  String get exercise_cardio_012_description =>
      'Variation explosive de squat avec saut. Combine l\'entraînement en force avec le cardio haute intensité.';

  @override
  String get exercise_cardio_012_beginner_tips =>
      'Accroupissez-vous, puis explosez vers le haut en sautant. Atterrissez doucement et passez immédiatement à la répétition suivante.';

  @override
  String get exercise_cardio_013_name => 'Sauts de fente';

  @override
  String get exercise_cardio_013_description =>
      'Variation explosive de fente avec saut. Alterne les jambes en sautant, offrant un entraînement cardio intense.';

  @override
  String get exercise_cardio_013_beginner_tips =>
      'Commencez en position de fente, sautez et changez de jambe en l\'air. Atterrissez en position de fente opposée.';

  @override
  String get exercise_cardio_015_name => 'Fentes sautées';

  @override
  String get exercise_cardio_015_description =>
      'Variation de fente haute intensité avec sauts explosifs. Alterne les jambes tout en maintenant la position de fente.';

  @override
  String get exercise_cardio_015_beginner_tips =>
      'Commencez en fente, sautez et changez de jambe. Atterrissez doucement en fente opposée. Maîtrisez d\'abord les fentes régulières.';

  @override
  String get exercise_push_009_name => 'Pompes archer';

  @override
  String get exercise_push_009_description =>
      'Variation avancée de pompes unilatérales. Déplace le poids sur un bras pendant que l\'autre bras s\'étend, développant une force incroyable.';

  @override
  String get exercise_push_009_beginner_tips =>
      'Maîtrisez d\'abord les pompes régulières. Commencez avec un petit déplacement et augmentez progressivement l\'amplitude.';

  @override
  String get exercise_push_016_name => 'Pompes pseudo planche';

  @override
  String get exercise_push_016_description =>
      'Pompes avancées avec les mains positionnées plus en arrière vers la taille. Variation extrêmement difficile qui développe une force incroyable.';

  @override
  String get exercise_push_016_beginner_tips =>
      'Commencez avec les mains légèrement derrière les épaules et déplacez-les progressivement vers l\'arrière au fur et à mesure que vous devenez plus fort.';

  @override
  String get exercise_push_017_name => 'Pompes avec claquement';

  @override
  String get exercise_push_017_description =>
      'Variation explosive de pompes où vous frappez les mains ensemble en haut. Développe la puissance et l\'explosivité du haut du corps.';

  @override
  String get exercise_push_017_beginner_tips =>
      'Maîtrisez d\'abord les pompes régulières. Commencez avec de petits claquements et augmentez progressivement la hauteur. Atterrissez doucement.';

  @override
  String get exercise_push_018_name => 'Pompes à un bras';

  @override
  String get exercise_push_018_description =>
      'Défi ultime de pompes effectué avec un bras. Nécessite une force, une stabilité et un contrôle du tronc exceptionnels.';

  @override
  String get exercise_push_018_beginner_tips =>
      'Progressez depuis les pompes archer. Commencez avec les pieds largement écartés et rapprochez-les progressivement.';

  @override
  String get exercise_push_019_name => 'Pompes en équilibre sur les mains';

  @override
  String get exercise_push_019_description =>
      'Exercice avancé effectué en position d\'équilibre sur les mains. Test ultime de la force et de la stabilité des épaules.';

  @override
  String get exercise_push_019_beginner_tips =>
      'Maîtrisez d\'abord le maintien en équilibre sur les mains. Pratiquez contre un mur avant d\'essayer sans support. Utilisez les pompes pike pour développer la force.';

  @override
  String get exercise_legs_003_name => 'Pistol squat';

  @override
  String get exercise_legs_003_description =>
      'Squat avancé à une jambe. Nécessite une force, un équilibre et une mobilité exceptionnels. Test ultime de la force des jambes.';

  @override
  String get exercise_legs_003_beginner_tips =>
      'Commencez avec des pistol squats assistés en utilisant une chaise ou en vous tenant à quelque chose. Progressez progressivement.';

  @override
  String get exercise_legs_019_name => 'Squats patineur';

  @override
  String get exercise_legs_019_description =>
      'Variation avancée de squat à une jambe. Nécessite un équilibre et une force des jambes exceptionnels.';

  @override
  String get exercise_legs_019_beginner_tips =>
      'Commencez avec une version assistée en vous tenant à quelque chose. Descendez sur une jambe, étendez l\'autre jambe vers l\'avant.';

  @override
  String get exercise_legs_022_name => 'Squat à une jambe';

  @override
  String get exercise_legs_022_description =>
      'Squat unilatéral avancé. Effectué sur une jambe, nécessite une force et un équilibre exceptionnels.';

  @override
  String get exercise_legs_022_beginner_tips =>
      'Commencez avec une version assistée ou une progression de pistol squat. Descendez sur une jambe, étendez l\'autre jambe vers l\'avant pour l\'équilibre.';

  @override
  String get exercise_legs_024_name => 'Squat sauté avec genoux au buste';

  @override
  String get exercise_legs_024_description =>
      'Variation avancée de squat sauté en amenant les genoux vers la poitrine en l\'air. Développe la puissance explosive et la force du tronc.';

  @override
  String get exercise_legs_024_beginner_tips =>
      'Maîtrisez d\'abord les squats sautés réguliers. Amenez les genoux vers la poitrine au sommet du saut. Atterrissez doucement.';

  @override
  String get exercise_core_017_name => 'Assise en L';

  @override
  String get exercise_core_017_description =>
      'Exercice isométrique avancé du tronc. Asseyez-vous avec les jambes étendues, soulevez le corps du sol en utilisant le tronc et les bras.';

  @override
  String get exercise_core_017_beginner_tips =>
      'Commencez avec les genoux pliés ou en utilisant une chaise pour le support. Travaillez progressivement vers un L-sit complet.';

  @override
  String get warmup_category_full_body => 'Corps entier';

  @override
  String get warmup_category_upper_body => 'Haut du corps';

  @override
  String get warmup_category_lower_body => 'Bas du corps';

  @override
  String get warmup_category_core => 'Abdominaux';

  @override
  String get warmup_category_cardio => 'Cardio';

  @override
  String get warmup_category_desc_full_body => 'Activation du corps entier';

  @override
  String get warmup_category_desc_upper_body => 'Bras, épaules et poitrine';

  @override
  String get warmup_category_desc_lower_body => 'Jambes, hanches et fessiers';

  @override
  String get warmup_category_desc_core => 'Abdos et bas du dos';

  @override
  String get warmup_category_desc_cardio => 'Augmentez votre rythme cardiaque';

  @override
  String get warmup_pick_category => 'Choisissez votre zone';
}
