import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}
