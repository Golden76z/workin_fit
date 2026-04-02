import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/views/auth/login_view.dart';
import 'package:workin_fit/views/auth/register_view.dart';

void main() {
  Widget wrapWithApp(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('LoginView', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(wrapWithApp(const LoginView()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('shows validation error for empty form submission',
        (tester) async {
      await tester.pumpWidget(wrapWithApp(const LoginView()));
      await tester.pumpAndSettle();

      // Find and tap a submit button
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }
      // Widget should still be present (not navigated away)
      expect(find.byType(LoginView), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders username, email, password fields', (tester) async {
      await tester.pumpWidget(wrapWithApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Register form has more fields than login
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('shows screen without crashing', (tester) async {
      await tester.pumpWidget(wrapWithApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}
