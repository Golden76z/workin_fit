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
  String get auth_page_login_description =>
      'Welcome back! Sign in to continue your fitness journey.';

  @override
  String get auth_page_login_button => 'Login';

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
  String get email_verification_check_tooltip => 'Check verification status';

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

  @override
  String get home_welcome_title => 'Welcome!';

  @override
  String get home_placeholder_title => 'Home Page';

  @override
  String get home_placeholder_subtitle => 'Your fitness journey starts here';

  @override
  String get home_logout => 'Log Out';

  @override
  String get sessions_create_success => 'Session created!';

  @override
  String sessions_error_generic(String error) {
    return 'Error: $error';
  }

  @override
  String get sessions_create_title => 'Create Session';

  @override
  String get sessions_name_label => 'Session Name';

  @override
  String get sessions_save_button => 'Save Session';

  @override
  String get sessions_list_title => 'My Sessions';

  @override
  String get exercise_push_001_name => 'Push-up';

  @override
  String get exercise_push_001_description =>
      'Classic bodyweight exercise targeting chest, shoulders, and triceps. Start in plank position, lower body until chest nearly touches floor, then push back up.';

  @override
  String get exercise_push_001_beginner_tips =>
      'Start with knee push-ups if full push-ups are too difficult. Keep your core tight and body in a straight line.';

  @override
  String get exercise_push_002_name => 'Incline Push-up';

  @override
  String get exercise_push_002_description =>
      'Easier variation of push-up performed with hands elevated on a chair or wall. Reduces bodyweight load, perfect for beginners.';

  @override
  String get exercise_push_002_beginner_tips =>
      'Place hands on a sturdy chair or wall. The higher the surface, the easier the exercise.';

  @override
  String get exercise_push_005_name => 'Wide Push-up';

  @override
  String get exercise_push_005_description =>
      'Push-up with hands placed wider than shoulder-width. Targets outer chest and shoulders more than standard push-up.';

  @override
  String get exercise_push_005_beginner_tips =>
      'Place hands wider than shoulder-width apart. Keep elbows slightly flared out during movement.';

  @override
  String get exercise_push_007_name => 'Wall Push-up';

  @override
  String get exercise_push_007_description =>
      'Beginner-friendly push-up performed standing against a wall. Perfect for those building upper body strength.';

  @override
  String get exercise_push_007_beginner_tips =>
      'Stand facing wall, place hands on wall at shoulder height. Step back to increase difficulty.';

  @override
  String get exercise_push_008_name => 'Knee Push-up';

  @override
  String get exercise_push_008_description =>
      'Modified push-up performed on knees instead of toes. Reduces bodyweight load significantly.';

  @override
  String get exercise_push_008_beginner_tips =>
      'Keep your body straight from knees to head. Don\'t let your hips sag or rise too high.';

  @override
  String get exercise_push_015_name => 'Wall Sit';

  @override
  String get exercise_push_015_description =>
      'Isometric leg exercise performed against a wall. Builds quadriceps and glute endurance.';

  @override
  String get exercise_push_015_beginner_tips =>
      'Slide down wall until thighs are parallel to floor. Hold position with back flat against wall.';

  @override
  String get exercise_pull_001_name => 'Inverted Row';

  @override
  String get exercise_pull_001_description =>
      'Bodyweight rowing exercise using a table or sturdy surface. Excellent for building back and bicep strength without equipment.';

  @override
  String get exercise_pull_001_beginner_tips =>
      'Use a sturdy table or chair. Keep body straight, pull chest to surface. Adjust angle to change difficulty.';

  @override
  String get exercise_pull_002_name => 'Superman';

  @override
  String get exercise_pull_002_description =>
      'Prone exercise targeting lower back and glutes. Lie face down, lift arms and legs simultaneously, hold briefly.';

  @override
  String get exercise_pull_002_beginner_tips =>
      'Lift only as high as comfortable. Focus on squeezing glutes and lower back muscles.';

  @override
  String get exercise_pull_003_name => 'Reverse Snow Angels';

  @override
  String get exercise_pull_003_description =>
      'Prone exercise where you move arms in snow angel motion. Strengthens posterior deltoids and upper back.';

  @override
  String get exercise_pull_003_beginner_tips =>
      'Keep arms straight and lift them off the ground. Move slowly and controlled through full range of motion.';

  @override
  String get exercise_pull_004_name => 'Y-T-W Raises';

  @override
  String get exercise_pull_004_description =>
      'Prone exercise series forming Y, T, and W shapes with arms. Targets entire upper back and rear deltoids.';

  @override
  String get exercise_pull_004_beginner_tips =>
      'Perform each letter shape separately. Keep core engaged and avoid arching lower back excessively.';

  @override
  String get exercise_pull_005_name => 'Wall Angels';

  @override
  String get exercise_pull_005_description =>
      'Standing exercise against wall mimicking snow angels. Improves posture and strengthens upper back muscles.';

  @override
  String get exercise_pull_005_beginner_tips =>
      'Keep back, head, and arms in contact with wall. Move slowly and maintain contact throughout movement.';

  @override
  String get exercise_pull_006_name => 'Prone Y Raise';

  @override
  String get exercise_pull_006_description =>
      'Prone exercise lifting arms in Y position. Targets upper traps and rear deltoids.';

  @override
  String get exercise_pull_006_beginner_tips =>
      'Lift arms at 45-degree angle. Squeeze shoulder blades together at the top.';

  @override
  String get exercise_pull_007_name => 'Prone T Raise';

  @override
  String get exercise_pull_007_description =>
      'Prone exercise lifting arms straight out to sides forming T shape. Strengthens rear deltoids and mid traps.';

  @override
  String get exercise_pull_007_beginner_tips =>
      'Keep arms straight and lift them parallel to ground. Focus on squeezing shoulder blades.';

  @override
  String get exercise_pull_008_name => 'Prone W Raise';

  @override
  String get exercise_pull_008_description =>
      'Prone exercise with arms bent forming W shape. Targets rhomboids and rear deltoids.';

  @override
  String get exercise_pull_008_beginner_tips =>
      'Bend elbows and lift arms, squeezing shoulder blades together. Keep core engaged.';

  @override
  String get exercise_pull_010_name => 'Scapular Wall Slides';

  @override
  String get exercise_pull_010_description =>
      'Posture exercise performed against wall. Strengthens upper back and improves shoulder mobility.';

  @override
  String get exercise_pull_010_beginner_tips =>
      'Keep back, head, and arms against wall. Slide arms up and down while maintaining contact.';

  @override
  String get exercise_pull_015_name => 'Doorway Row';

  @override
  String get exercise_pull_015_description =>
      'Rowing exercise using doorway frame. Stand in doorway, pull body toward frame using back muscles.';

  @override
  String get exercise_pull_015_beginner_tips =>
      'Use sturdy doorway. Place hands on frame, lean back, and pull body forward. Adjust angle for difficulty.';

  @override
  String get exercise_pull_018_name => 'Reverse Fly';

  @override
  String get exercise_pull_018_description =>
      'Prone exercise mimicking reverse fly motion. Strengthens rear deltoids and upper back without weights.';

  @override
  String get exercise_pull_018_beginner_tips =>
      'Lie face down, lift arms out to sides. Squeeze shoulder blades together at the top.';

  @override
  String get exercise_legs_001_name => 'Bodyweight Squat';

  @override
  String get exercise_legs_001_description =>
      'Fundamental lower body exercise. Stand with feet shoulder-width, lower down as if sitting in chair, then stand back up.';

  @override
  String get exercise_legs_001_beginner_tips =>
      'Keep knees tracking over toes. Lower until thighs are parallel to floor or as low as comfortable.';

  @override
  String get exercise_legs_005_name => 'Forward Lunge';

  @override
  String get exercise_legs_005_description =>
      'Unilateral leg exercise stepping forward. Targets quads, glutes, and improves balance.';

  @override
  String get exercise_legs_005_beginner_tips =>
      'Step forward, lower back knee toward ground. Keep front knee over ankle. Push back to start.';

  @override
  String get exercise_legs_006_name => 'Reverse Lunge';

  @override
  String get exercise_legs_006_description =>
      'Lunge variation stepping backward. Easier on knees and emphasizes glutes more than forward lunge.';

  @override
  String get exercise_legs_006_beginner_tips =>
      'Step backward, lower down until both knees form 90-degree angles. Push back to start position.';

  @override
  String get exercise_legs_009_name => 'Side Lunge';

  @override
  String get exercise_legs_009_description =>
      'Lateral lunge variation stepping to the side. Targets inner thighs and improves hip mobility.';

  @override
  String get exercise_legs_009_beginner_tips =>
      'Step to the side, lower down keeping other leg straight. Push back to center. Alternate sides.';

  @override
  String get exercise_legs_010_name => 'Calf Raise';

  @override
  String get exercise_legs_010_description =>
      'Isolated calf exercise. Stand on balls of feet, rise up onto toes, then lower down slowly.';

  @override
  String get exercise_legs_010_beginner_tips =>
      'Rise up as high as possible, hold briefly, then lower slowly. Can be done on floor or elevated surface.';

  @override
  String get exercise_legs_012_name => 'Glute Bridge';

  @override
  String get exercise_legs_012_description =>
      'Hip extension exercise targeting glutes and hamstrings. Lie on back, lift hips up, squeeze glutes.';

  @override
  String get exercise_legs_012_beginner_tips =>
      'Keep feet flat on floor, lift hips until body forms straight line. Squeeze glutes at the top.';

  @override
  String get exercise_legs_014_name => 'Donkey Kicks';

  @override
  String get exercise_legs_014_description =>
      'Quadruped exercise targeting glutes. Start on hands and knees, kick one leg back and up.';

  @override
  String get exercise_legs_014_beginner_tips =>
      'Keep core engaged and back straight. Lift leg without arching lower back. Squeeze glute at top.';

  @override
  String get exercise_legs_015_name => 'Fire Hydrants';

  @override
  String get exercise_legs_015_description =>
      'Quadruped exercise lifting leg to the side. Targets glutes and hip abductors.';

  @override
  String get exercise_legs_015_beginner_tips =>
      'Start on hands and knees. Lift leg out to side, keeping knee bent. Don\'t rotate hips.';

  @override
  String get exercise_legs_016_name => 'Clamshells';

  @override
  String get exercise_legs_016_description =>
      'Side-lying exercise targeting hip abductors and glutes. Lie on side, lift top knee while keeping feet together.';

  @override
  String get exercise_legs_016_beginner_tips =>
      'Keep feet together, lift only the knee. Don\'t roll backward. Move slowly and controlled.';

  @override
  String get exercise_legs_017_name => 'Leg Raises';

  @override
  String get exercise_legs_017_description =>
      'Core and hip flexor exercise. Lie on back, lift legs straight up, then lower down slowly.';

  @override
  String get exercise_legs_017_beginner_tips =>
      'Keep lower back pressed to floor. Lower legs only as far as you can maintain back contact.';

  @override
  String get exercise_legs_020_name => 'Step-up';

  @override
  String get exercise_legs_020_description =>
      'Unilateral leg exercise using chair or step. Step up onto surface, then step back down.';

  @override
  String get exercise_legs_020_beginner_tips =>
      'Use sturdy chair or step. Place entire foot on surface. Push through heel to step up.';

  @override
  String get exercise_legs_021_name => 'Sumo Squat';

  @override
  String get exercise_legs_021_description =>
      'Wide-stance squat variation. Targets inner thighs and glutes more than standard squat.';

  @override
  String get exercise_legs_021_beginner_tips =>
      'Stand with feet wider than shoulder-width, toes pointed slightly out. Lower down, keeping knees tracking over toes.';

  @override
  String get exercise_core_001_name => 'Plank';

  @override
  String get exercise_core_001_description =>
      'Fundamental core exercise. Hold body in straight line supported by forearms and toes. Builds core strength and stability.';

  @override
  String get exercise_core_001_beginner_tips =>
      'Keep body straight from head to heels. Don\'t let hips sag or rise. Start with 20-30 seconds.';

  @override
  String get exercise_core_002_name => 'Side Plank';

  @override
  String get exercise_core_002_description =>
      'Unilateral core exercise performed on side. Targets obliques and improves lateral stability.';

  @override
  String get exercise_core_002_beginner_tips =>
      'Support body on one forearm and side of foot. Keep body straight. Start with 15-20 seconds per side.';

  @override
  String get exercise_core_004_name => 'Bicycle Crunches';

  @override
  String get exercise_core_004_description =>
      'Rotational core exercise mimicking bicycle motion. Targets abs and obliques effectively.';

  @override
  String get exercise_core_004_beginner_tips =>
      'Lie on back, bring opposite elbow to knee. Extend other leg. Move slowly and controlled.';

  @override
  String get exercise_core_005_name => 'Russian Twists';

  @override
  String get exercise_core_005_description =>
      'Seated rotational exercise targeting obliques. Sit with knees bent, lean back slightly, rotate torso side to side.';

  @override
  String get exercise_core_005_beginner_tips =>
      'Keep core engaged and back straight. Rotate from torso, not just arms. Start without weight.';

  @override
  String get exercise_core_006_name => 'Flutter Kicks';

  @override
  String get exercise_core_006_description =>
      'Core exercise performed lying on back. Alternately kick legs up and down while keeping core engaged.';

  @override
  String get exercise_core_006_beginner_tips =>
      'Keep lower back pressed to floor. Move legs in small, controlled motions. Don\'t arch back.';

  @override
  String get exercise_core_007_name => 'Dead Bug';

  @override
  String get exercise_core_007_description =>
      'Core stability exercise performed on back. Extend opposite arm and leg while maintaining core engagement.';

  @override
  String get exercise_core_007_beginner_tips =>
      'Keep lower back pressed to floor. Move slowly and controlled. Alternate opposite arm and leg.';

  @override
  String get exercise_core_008_name => 'Bird Dog';

  @override
  String get exercise_core_008_description =>
      'Quadruped core stability exercise. Extend opposite arm and leg while maintaining balance.';

  @override
  String get exercise_core_008_beginner_tips =>
      'Start on hands and knees. Extend opposite arm and leg. Hold briefly, then switch sides.';

  @override
  String get exercise_core_011_name => 'Toe Touches';

  @override
  String get exercise_core_011_description =>
      'Core exercise reaching for toes. Lie on back, lift legs and reach hands toward toes.';

  @override
  String get exercise_core_011_beginner_tips =>
      'Keep legs as straight as possible. Lift shoulders off ground. Reach up, not forward.';

  @override
  String get exercise_core_012_name => 'Reverse Crunches';

  @override
  String get exercise_core_012_description =>
      'Core exercise lifting hips. Lie on back, bring knees toward chest, lift hips off ground.';

  @override
  String get exercise_core_012_beginner_tips =>
      'Keep knees bent. Lift hips by contracting abs, not by swinging legs. Lower slowly.';

  @override
  String get exercise_cardio_001_name => 'Jumping Jacks';

  @override
  String get exercise_cardio_001_description =>
      'Classic full-body cardio exercise. Jump feet apart while raising arms overhead, then return.';

  @override
  String get exercise_cardio_001_beginner_tips =>
      'Start slowly to master coordination. Land softly on balls of feet. Can be done low-impact by stepping instead of jumping.';

  @override
  String get exercise_cardio_002_name => 'High Knees';

  @override
  String get exercise_cardio_002_description =>
      'Running in place bringing knees up high. Excellent cardio exercise that also improves coordination.';

  @override
  String get exercise_cardio_002_beginner_tips =>
      'Run in place, bringing knees up toward chest. Pump arms naturally. Start with 20-30 seconds.';

  @override
  String get exercise_cardio_003_name => 'Butt Kicks';

  @override
  String get exercise_cardio_003_description =>
      'Running in place kicking heels toward glutes. Targets hamstrings while providing cardio benefits.';

  @override
  String get exercise_cardio_003_beginner_tips =>
      'Run in place, kick heels up toward glutes. Keep knees pointing down. Start with 20-30 seconds.';

  @override
  String get exercise_cardio_009_name => 'Shadow Boxing';

  @override
  String get exercise_cardio_009_description =>
      'Cardio exercise mimicking boxing movements. Throw punches in air, combining cardio with coordination.';

  @override
  String get exercise_cardio_009_beginner_tips =>
      'Throw jabs, crosses, hooks, and uppercuts. Keep moving, don\'t stop between punches. 30-60 seconds rounds.';

  @override
  String get exercise_cardio_010_name => 'Jump Rope (No Rope)';

  @override
  String get exercise_cardio_010_description =>
      'Mimic jump rope motion without equipment. Jump lightly on balls of feet, rotating wrists as if holding rope.';

  @override
  String get exercise_cardio_010_beginner_tips =>
      'Jump lightly on balls of feet. Rotate wrists as if holding rope. Start with 20-30 seconds.';

  @override
  String get exercise_cardio_014_name => 'Dancing in Place';

  @override
  String get exercise_cardio_014_description =>
      'Fun cardio exercise moving to music. Freestyle dance movements to get heart rate up.';

  @override
  String get exercise_cardio_014_beginner_tips =>
      'Move your body to music. Include arm movements, leg lifts, and hip movements. Have fun!';

  @override
  String get exercise_push_003_name => 'Decline Push-up';

  @override
  String get exercise_push_003_description =>
      'Advanced push-up variation with feet elevated on a chair. Increases difficulty by shifting more weight to upper body.';

  @override
  String get exercise_push_003_beginner_tips =>
      'Start with a low elevation and gradually increase. Ensure the chair is stable and won\'t slide.';

  @override
  String get exercise_push_004_name => 'Diamond Push-up';

  @override
  String get exercise_push_004_description =>
      'Push-up variation with hands forming a diamond shape. Emphasizes triceps and inner chest muscles.';

  @override
  String get exercise_push_004_beginner_tips =>
      'Start with regular push-ups to build strength. Place thumbs and index fingers together to form diamond.';

  @override
  String get exercise_push_006_name => 'Pike Push-up';

  @override
  String get exercise_push_006_description =>
      'Push-up performed in downward dog position. Excellent for building shoulder strength and preparing for handstand push-ups.';

  @override
  String get exercise_push_006_beginner_tips =>
      'Start with feet wider apart for better balance. Lower head toward floor between hands, then push back up.';

  @override
  String get exercise_push_010_name => 'Hindu Push-up';

  @override
  String get exercise_push_010_description =>
      'Dynamic push-up variation with flowing movement. Combines strength training with mobility work.';

  @override
  String get exercise_push_010_beginner_tips =>
      'Start in downward dog, lower into upward dog position, then return. Focus on smooth, controlled movement.';

  @override
  String get exercise_push_011_name => 'Spiderman Push-up';

  @override
  String get exercise_push_011_description =>
      'Push-up variation where you bring knee to elbow during the lowering phase. Adds core engagement and hip mobility.';

  @override
  String get exercise_push_011_beginner_tips =>
      'Start with regular push-ups. Add the knee movement once you\'re comfortable with the base exercise.';

  @override
  String get exercise_push_012_name => 'Shoulder Tap Push-up';

  @override
  String get exercise_push_012_description =>
      'Push-up variation where you tap opposite shoulder at the top of each rep. Challenges stability and core strength.';

  @override
  String get exercise_push_012_beginner_tips =>
      'Master regular push-ups first. Keep your hips level and avoid rotating your body when tapping.';

  @override
  String get exercise_push_013_name => 'Tricep Dips';

  @override
  String get exercise_push_013_description =>
      'Upper body exercise using a chair. Targets triceps, shoulders, and chest. Sit on edge of chair, lower body, then push up.';

  @override
  String get exercise_push_013_beginner_tips =>
      'Keep feet closer to chair for easier variation. Ensure chair is stable and won\'t tip over.';

  @override
  String get exercise_push_014_name => 'Diamond Tricep Dips';

  @override
  String get exercise_push_014_description =>
      'Tricep dips with hands close together in diamond position. Increases tricep emphasis and difficulty.';

  @override
  String get exercise_push_014_beginner_tips =>
      'Master regular tricep dips first. Place hands close together with fingers pointing forward.';

  @override
  String get exercise_push_020_name => 'Dive Bomber Push-up';

  @override
  String get exercise_push_020_description =>
      'Dynamic push-up variation combining downward dog, low push-up, and upward dog positions in one fluid motion.';

  @override
  String get exercise_push_020_beginner_tips =>
      'Start slowly to master the movement pattern. Focus on smooth transitions between positions.';

  @override
  String get exercise_pull_009_name => 'Reverse Plank';

  @override
  String get exercise_pull_009_description =>
      'Bodyweight exercise performed face-up. Strengthens posterior chain including back, glutes, and hamstrings.';

  @override
  String get exercise_pull_009_beginner_tips =>
      'Start with bent knees and gradually straighten legs as you get stronger. Keep hips lifted.';

  @override
  String get exercise_pull_011_name => 'Isometric Pull Hold';

  @override
  String get exercise_pull_011_description =>
      'Static hold exercise mimicking pull-up position. Builds grip strength and back endurance.';

  @override
  String get exercise_pull_011_beginner_tips =>
      'Hang from a bar or sturdy surface. Hold chin over bar as long as possible. Use assistance if needed.';

  @override
  String get exercise_pull_012_name => 'Reverse Plank Walk';

  @override
  String get exercise_pull_012_description =>
      'Dynamic reverse plank variation. Walk hands backward while maintaining reverse plank position.';

  @override
  String get exercise_pull_012_beginner_tips =>
      'Start with small steps. Keep hips elevated and body straight throughout movement.';

  @override
  String get exercise_pull_013_name => 'Single Arm Row';

  @override
  String get exercise_pull_013_description =>
      'Unilateral rowing exercise using bodyweight. Can be performed with towel or resistance band if available.';

  @override
  String get exercise_pull_013_beginner_tips =>
      'Use a towel wrapped around a door handle or sturdy anchor. Pull with one arm, focusing on squeezing back muscles.';

  @override
  String get exercise_pull_014_name => 'Towel Row';

  @override
  String get exercise_pull_014_description =>
      'Rowing exercise using a towel for grip. Wrap towel around door handle or sturdy anchor and row.';

  @override
  String get exercise_pull_014_beginner_tips =>
      'Ensure door or anchor is secure. Adjust distance to change difficulty. Closer = easier, farther = harder.';

  @override
  String get exercise_pull_016_name => 'Australian Pull-up';

  @override
  String get exercise_pull_016_description =>
      'Horizontal pulling exercise using table or bar. Body positioned horizontally, pull chest to surface.';

  @override
  String get exercise_pull_016_beginner_tips =>
      'Use sturdy table or low bar. Keep body straight. Higher surface = easier, lower = harder.';

  @override
  String get exercise_pull_017_name => 'Pull-up Negative';

  @override
  String get exercise_pull_017_description =>
      'Eccentric phase of pull-up. Jump or step up to top position, then lower slowly. Builds strength for full pull-ups.';

  @override
  String get exercise_pull_017_beginner_tips =>
      'Use a chair to reach top position. Lower as slowly as possible, aiming for 3-5 seconds descent.';

  @override
  String get exercise_pull_019_name => 'Wide Grip Inverted Row';

  @override
  String get exercise_pull_019_description =>
      'Inverted row with hands placed wider than shoulder-width. Emphasizes outer back and rear deltoids.';

  @override
  String get exercise_pull_019_beginner_tips =>
      'Use table or bar. Place hands wider than shoulders. Pull chest to surface while keeping body straight.';

  @override
  String get exercise_pull_020_name => 'Close Grip Inverted Row';

  @override
  String get exercise_pull_020_description =>
      'Inverted row with hands close together. Increases bicep emphasis and difficulty.';

  @override
  String get exercise_pull_020_beginner_tips =>
      'Place hands close together, palms facing each other if possible. Pull with biceps and back muscles.';

  @override
  String get exercise_legs_002_name => 'Jump Squat';

  @override
  String get exercise_legs_002_description =>
      'Explosive squat variation with jump at the top. Develops power and athleticism in lower body.';

  @override
  String get exercise_legs_002_beginner_tips =>
      'Master regular squats first. Land softly with knees slightly bent to absorb impact.';

  @override
  String get exercise_legs_004_name => 'Bulgarian Split Squat';

  @override
  String get exercise_legs_004_description =>
      'Single-leg squat with rear foot elevated on chair. Excellent for building unilateral leg strength.';

  @override
  String get exercise_legs_004_beginner_tips =>
      'Place rear foot on chair behind you. Lower down, keeping front knee over ankle. Start with shallow depth.';

  @override
  String get exercise_legs_007_name => 'Walking Lunge';

  @override
  String get exercise_legs_007_description =>
      'Dynamic lunge variation moving forward. Combines strength training with coordination.';

  @override
  String get exercise_legs_007_beginner_tips =>
      'Start with stationary lunges. Alternate legs as you move forward, maintaining good form.';

  @override
  String get exercise_legs_008_name => 'Jumping Lunge';

  @override
  String get exercise_legs_008_description =>
      'Explosive lunge variation with jump between reps. Develops power and cardiovascular fitness.';

  @override
  String get exercise_legs_008_beginner_tips =>
      'Master regular lunges first. Land softly and switch legs in the air. Start with low jumps.';

  @override
  String get exercise_legs_011_name => 'Single Leg Calf Raise';

  @override
  String get exercise_legs_011_description =>
      'Unilateral calf exercise. Performed on one leg to increase difficulty and address imbalances.';

  @override
  String get exercise_legs_011_beginner_tips =>
      'Master two-legged calf raises first. Hold onto something for balance if needed.';

  @override
  String get exercise_legs_013_name => 'Single Leg Glute Bridge';

  @override
  String get exercise_legs_013_description =>
      'Advanced glute bridge variation performed on one leg. Significantly increases difficulty and glute activation.';

  @override
  String get exercise_legs_013_beginner_tips =>
      'Master regular glute bridge first. Extend one leg straight, lift hips with one leg.';

  @override
  String get exercise_legs_018_name => 'Single Leg Deadlift';

  @override
  String get exercise_legs_018_description =>
      'Unilateral hip hinge exercise. Develops balance, hamstring strength, and glute activation.';

  @override
  String get exercise_legs_018_beginner_tips =>
      'Start with small range of motion. Hinge at hips, extend opposite leg back. Keep back straight.';

  @override
  String get exercise_legs_023_name => 'Cossack Squat';

  @override
  String get exercise_legs_023_description =>
      'Lateral squat variation with one leg extended. Improves hip mobility and builds leg strength.';

  @override
  String get exercise_legs_023_beginner_tips =>
      'Shift weight to one side, lower down while extending other leg. Keep extended leg straight.';

  @override
  String get exercise_legs_025_name => 'Wall Sit Pulse';

  @override
  String get exercise_legs_025_description =>
      'Dynamic wall sit variation. Hold wall sit position, then pulse up and down slightly.';

  @override
  String get exercise_legs_025_beginner_tips =>
      'Start in wall sit position. Pulse up and down 2-3 inches. Keep back against wall throughout.';

  @override
  String get exercise_core_003_name => 'Mountain Climbers';

  @override
  String get exercise_core_003_description =>
      'Dynamic core exercise alternating knees to chest. Combines strength with cardiovascular training.';

  @override
  String get exercise_core_003_beginner_tips =>
      'Start in plank position. Alternate bringing knees to chest. Keep hips level, don\'t bounce.';

  @override
  String get exercise_core_009_name => 'Hollow Body Hold';

  @override
  String get exercise_core_009_description =>
      'Advanced isometric core exercise. Lie on back, lift shoulders and legs, hold position.';

  @override
  String get exercise_core_009_beginner_tips =>
      'Start with bent knees. Gradually straighten legs as you get stronger. Keep lower back pressed to floor.';

  @override
  String get exercise_core_010_name => 'V-Ups';

  @override
  String get exercise_core_010_description =>
      'Advanced core exercise forming V shape. Lie on back, lift torso and legs simultaneously to touch.';

  @override
  String get exercise_core_010_beginner_tips =>
      'Start with knees bent. Gradually work toward straight legs. Don\'t use momentum.';

  @override
  String get exercise_core_013_name => 'Plank Jacks';

  @override
  String get exercise_core_013_description =>
      'Dynamic plank variation jumping feet apart and together. Combines core strength with cardio.';

  @override
  String get exercise_core_013_beginner_tips =>
      'Start in plank position. Jump feet apart and together while maintaining plank position.';

  @override
  String get exercise_core_014_name => 'Bear Crawl';

  @override
  String get exercise_core_014_description =>
      'Quadruped movement exercise. Crawl forward and backward on hands and feet, keeping knees off ground.';

  @override
  String get exercise_core_014_beginner_tips =>
      'Keep core engaged and back flat. Move opposite hand and foot together. Start with short distances.';

  @override
  String get exercise_core_015_name => 'Crab Walk';

  @override
  String get exercise_core_015_description =>
      'Reverse quadruped movement. Sit with hands behind you, lift hips, walk forward and backward.';

  @override
  String get exercise_core_015_beginner_tips =>
      'Keep hips lifted throughout. Move opposite hand and foot together. Start with short distances.';

  @override
  String get exercise_core_016_name => 'Windshield Wipers';

  @override
  String get exercise_core_016_description =>
      'Core exercise moving legs side to side. Lie on back, lift legs, rotate them side to side.';

  @override
  String get exercise_core_016_beginner_tips =>
      'Keep legs together and lower back pressed to floor. Move slowly and controlled.';

  @override
  String get exercise_core_018_name => 'Plank to Downward Dog';

  @override
  String get exercise_core_018_description =>
      'Dynamic movement transitioning from plank to downward dog. Combines core strength with mobility.';

  @override
  String get exercise_core_018_beginner_tips =>
      'Start in plank, push hips up to downward dog, then return. Move slowly and controlled.';

  @override
  String get exercise_core_019_name => 'Side Plank with Leg Lift';

  @override
  String get exercise_core_019_description =>
      'Advanced side plank variation. Hold side plank, lift top leg up and down.';

  @override
  String get exercise_core_019_beginner_tips =>
      'Master regular side plank first. Lift leg slowly, keeping body straight. Don\'t rotate hips.';

  @override
  String get exercise_core_020_name => 'Plank Up-Downs';

  @override
  String get exercise_core_020_description =>
      'Dynamic plank variation transitioning between high and low plank. Alternates between hands and forearms.';

  @override
  String get exercise_core_020_beginner_tips =>
      'Start in plank, push up to high plank one arm at a time, then lower back down. Keep core engaged.';

  @override
  String get exercise_cardio_004_name => 'Burpees';

  @override
  String get exercise_cardio_004_description =>
      'Full-body explosive exercise combining squat, plank, push-up, and jump. Ultimate bodyweight cardio challenge.';

  @override
  String get exercise_cardio_004_beginner_tips =>
      'Start with step-back burpees (no jump). Master each component separately before combining. Land softly from jump.';

  @override
  String get exercise_cardio_005_name => 'Skater Jumps';

  @override
  String get exercise_cardio_005_description =>
      'Lateral jumping exercise mimicking ice skating motion. Develops power, balance, and cardiovascular fitness.';

  @override
  String get exercise_cardio_005_beginner_tips =>
      'Jump side to side, landing on one foot. Swing opposite arm across body. Start with small jumps.';

  @override
  String get exercise_cardio_006_name => 'Star Jumps';

  @override
  String get exercise_cardio_006_description =>
      'Explosive jumping exercise forming star shape. Jump up, spread arms and legs wide, then return.';

  @override
  String get exercise_cardio_006_beginner_tips =>
      'Jump up, spread arms and legs wide at peak. Land softly with feet together. Start with low jumps.';

  @override
  String get exercise_cardio_007_name => 'Tuck Jumps';

  @override
  String get exercise_cardio_007_description =>
      'Explosive jump bringing knees to chest. Develops power and cardiovascular fitness.';

  @override
  String get exercise_cardio_007_beginner_tips =>
      'Jump as high as possible, bringing knees toward chest. Land softly with knees slightly bent.';

  @override
  String get exercise_cardio_008_name => 'Inchworms';

  @override
  String get exercise_cardio_008_description =>
      'Full-body movement exercise. Stand, walk hands out to plank, then walk feet back to hands.';

  @override
  String get exercise_cardio_008_beginner_tips =>
      'Keep legs as straight as possible when walking hands out. Move slowly and controlled.';

  @override
  String get exercise_cardio_011_name => 'Fast Feet';

  @override
  String get exercise_cardio_011_description =>
      'High-intensity cardio exercise. Run in place as fast as possible, staying on balls of feet.';

  @override
  String get exercise_cardio_011_beginner_tips =>
      'Stay on balls of feet, move feet as fast as possible. Keep core engaged. Start with 10-15 second bursts.';

  @override
  String get exercise_cardio_012_name => 'Squat Jumps';

  @override
  String get exercise_cardio_012_description =>
      'Explosive squat variation with jump. Combines strength training with high-intensity cardio.';

  @override
  String get exercise_cardio_012_beginner_tips =>
      'Squat down, then explode up into jump. Land softly and immediately go into next rep.';

  @override
  String get exercise_cardio_013_name => 'Lunge Jumps';

  @override
  String get exercise_cardio_013_description =>
      'Explosive lunge variation with jump. Alternates legs while jumping, providing intense cardio workout.';

  @override
  String get exercise_cardio_013_beginner_tips =>
      'Start in lunge position, jump up and switch legs in air. Land in opposite lunge position.';

  @override
  String get exercise_cardio_015_name => 'Jumping Lunges';

  @override
  String get exercise_cardio_015_description =>
      'High-intensity lunge variation with explosive jumps. Alternates legs while maintaining lunge position.';

  @override
  String get exercise_cardio_015_beginner_tips =>
      'Start in lunge, jump up and switch legs. Land softly in opposite lunge. Master regular lunges first.';

  @override
  String get exercise_push_009_name => 'Archer Push-up';

  @override
  String get exercise_push_009_description =>
      'Advanced unilateral push-up variation. Shifts weight to one arm while the other arm extends, building incredible strength.';

  @override
  String get exercise_push_009_beginner_tips =>
      'Master regular push-ups first. Start with a small shift and gradually increase the range.';

  @override
  String get exercise_push_016_name => 'Pseudo Planche Push-up';

  @override
  String get exercise_push_016_description =>
      'Advanced push-up with hands positioned further back toward waist. Extremely challenging variation that builds incredible strength.';

  @override
  String get exercise_push_016_beginner_tips =>
      'Start with hands slightly behind shoulders and gradually move them back as you get stronger.';

  @override
  String get exercise_push_017_name => 'Clapping Push-up';

  @override
  String get exercise_push_017_description =>
      'Explosive push-up variation where you clap hands together at the top. Develops power and upper body explosiveness.';

  @override
  String get exercise_push_017_beginner_tips =>
      'Master regular push-ups first. Start with small claps and gradually increase height. Land softly.';

  @override
  String get exercise_push_018_name => 'One-Arm Push-up';

  @override
  String get exercise_push_018_description =>
      'Ultimate push-up challenge performed with one arm. Requires exceptional strength, stability, and core control.';

  @override
  String get exercise_push_018_beginner_tips =>
      'Progress from archer push-ups. Start with feet wide apart and gradually bring them closer together.';

  @override
  String get exercise_push_019_name => 'Handstand Push-up';

  @override
  String get exercise_push_019_description =>
      'Advanced exercise performed in handstand position. Ultimate test of shoulder strength and stability.';

  @override
  String get exercise_push_019_beginner_tips =>
      'Master handstand hold first. Practice against a wall before attempting freestanding. Use pike push-ups to build strength.';

  @override
  String get exercise_legs_003_name => 'Pistol Squat';

  @override
  String get exercise_legs_003_description =>
      'Advanced single-leg squat. Requires exceptional strength, balance, and mobility. Ultimate leg strength test.';

  @override
  String get exercise_legs_003_beginner_tips =>
      'Start with assisted pistol squats using a chair or holding onto something. Progress gradually.';

  @override
  String get exercise_legs_019_name => 'Skater Squats';

  @override
  String get exercise_legs_019_description =>
      'Advanced single-leg squat variation. Requires exceptional balance and leg strength.';

  @override
  String get exercise_legs_019_beginner_tips =>
      'Start with assisted version holding onto something. Lower down on one leg, extend other leg forward.';

  @override
  String get exercise_legs_022_name => 'Single Leg Squat';

  @override
  String get exercise_legs_022_description =>
      'Advanced unilateral squat. Performed on one leg, requires exceptional strength and balance.';

  @override
  String get exercise_legs_022_beginner_tips =>
      'Start with assisted version or pistol squat progression. Lower down on one leg, extend other leg forward for balance.';

  @override
  String get exercise_legs_024_name => 'Jump Squat to Tuck';

  @override
  String get exercise_legs_024_description =>
      'Advanced jump squat variation bringing knees to chest in the air. Develops explosive power and core strength.';

  @override
  String get exercise_legs_024_beginner_tips =>
      'Master regular jump squats first. Bring knees toward chest at peak of jump. Land softly.';

  @override
  String get exercise_core_017_name => 'L-Sit';

  @override
  String get exercise_core_017_description =>
      'Advanced isometric core exercise. Sit with legs extended, lift body off ground using core and arms.';

  @override
  String get exercise_core_017_beginner_tips =>
      'Start with bent knees or using chair for support. Gradually work toward full L-sit.';
}
