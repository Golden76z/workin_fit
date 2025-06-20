// import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_app/app_theme.dart';
import 'package:sport_app/constants/routes.dart';
import 'package:sport_app/services/auth/bloc/auth_bloc.dart';
import 'package:sport_app/services/auth/bloc/auth_event.dart';
import 'package:sport_app/services/auth/bloc/auth_state.dart';
import 'package:sport_app/services/auth/firebase_auth_provider.dart';
import 'package:sport_app/views/auth/authentication_view.dart';
import 'package:sport_app/views/home_page.dart';
import 'package:sport_app/views/notes/create_update_note_view.dart';
import 'package:sport_app/views/auth/register_view.dart';
import 'package:sport_app/views/auth/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: AthleticEnergyTheme.lightTheme,
    darkTheme: AthleticEnergyTheme.darkTheme,
    themeMode: ThemeMode.system,
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),

    // Setting up the routes of our functions
    routes: {
      // homeRoute: (context) => NotesView(),
      // loginRoute: (context) => LoginView(),
      // registerRoute: (context) => RegisterView(),
      // verifyEmailRoute: (context) => VerifyEmailView(),
      createOrUpdateNoteRoute: (context) => CreateUpdateNoteView(),
      // profileRoute: (context) => ProfileView(),
    },
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.redAccent[200], // Navigation bar color
    systemNavigationBarIconBrightness: Brightness.light, // Icon color
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const HomePageAuth();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const AuthenticationView();
      } else if (state is AuthEventShouldRegister) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
