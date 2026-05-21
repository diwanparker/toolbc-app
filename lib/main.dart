import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the bundled .env asset.
  // If it is missing or invalid, the app still starts in demo mode.
  try {
    await dotenv.load(fileName: '.env');
    await SupabaseService.initializeFromEnv();
  } catch (_) {
    // Ignore startup config errors so the UI can still render.
  }
  runApp(const MyApp());
}
