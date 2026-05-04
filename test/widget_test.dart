import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tbc/main.dart';

void main() {
  testWidgets('login routes patient into the dashboard and checkup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('auth_email_field')), 'tester@pasien.com');
    await tester.enterText(find.byKey(const ValueKey('auth_password_field')), '123456');

    final loginButton = find.byKey(const ValueKey('auth_login_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Davina'), findsOneWidget);
    expect(find.text('Treatment Progress'), findsOneWidget);

    await tester.tap(find.text('Checkup').last);
    await tester.pumpAndSettle();

    expect(find.text('Daily Checkup'), findsOneWidget);
    expect(find.text('Symptom Checker'), findsOneWidget);
  });
}
