import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the bundled .env asset.
  // If Supabase is missing, the app still opens but login is blocked.
  try {
    await dotenv.load(fileName: '.env');
    await SupabaseService.initializeFromEnv();
  } catch (_) {
    // Ignore startup config errors so the login screen can explain the issue.
  }
  runApp(const MyApp());
}
