part of flutter_tbc;

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
