library flutter_tbc;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app/app.dart';
part 'app/theme/app_theme.dart';
part 'core/services/supabase_service.dart';
part 'core/widgets/app_shell.dart';
part 'core/widgets/ui_components.dart';
part 'features/admin/admin_pages.dart';
part 'features/auth/login_page.dart';
part 'features/auth/register_page.dart';
part 'features/doctor/doctor_pages.dart';
part 'features/dashboard_compliance/patient_compliance_dashboard_page.dart';
part 'features/notification/notification_center_page.dart';
part 'features/onboarding/onboarding_page.dart';
part 'features/profile/profile_pages.dart';
part 'features/reminder_obat/medication_reminder_page.dart';
part 'features/patient/patient_chat_page.dart';
part 'features/status_progres_pasien/patient_progress_page.dart';
part 'features/patient/patient_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}