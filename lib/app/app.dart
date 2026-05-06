import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TBC Care',
      theme: buildAppTheme(),
      home: const AuthLoginPage(),
    );
  }
}
