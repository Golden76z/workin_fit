// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workin_fit/views/test/test_page_001.dart';

void main() {
  testWidgets('AuthPage renders inside MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthPage(),
      ),
    );

    expect(find.text('Workin Fit'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('this is a test button'), findsOneWidget);
  });
}
