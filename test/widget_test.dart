import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tbc/app/app.dart';

void main() {
  testWidgets('login is blocked when Supabase is not configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome\nback!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('auth_email_field')),
      'tester@pasien.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth_password_field')),
      '123456',
    );

    final loginButton = find.byKey(const ValueKey('auth_login_button'));
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Welcome\nback!'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);
  });
}
