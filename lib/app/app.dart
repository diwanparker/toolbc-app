import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../core/widgets/app_shell.dart';
import '../features/auth/login_page.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthService.isLoggedIn();
    final profile = AuthService.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TBC Care',
      theme: buildAppTheme(),
      home: loggedIn && profile != null
          ? AppShell(initialMode: profile.role.appMode)
          : const AuthLoginPage(),
    );
  }
}
