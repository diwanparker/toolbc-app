import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tbc/app/app.dart';

void main() {
  testWidgets('login is blocked when Supabase is not configured', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('Monitoring Pengobatan TBC Lebih Teratur & Tuntas'), findsOneWidget);
    final loginButton = find.byKey(const ValueKey('auth_login_button'));
    expect(loginButton, findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('auth_email_field')),
      'tester@pasien.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth_password_field')),
      '123456',
    );

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Monitoring Pengobatan TBC Lebih Teratur & Tuntas'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);
  });
}
