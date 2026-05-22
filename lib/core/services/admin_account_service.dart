import 'package:supabase_flutter/supabase_flutter.dart';

import 'doctor_service.dart';
import 'supabase_service.dart';

class AdminAccountService {
  AdminAccountService._();

  static Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? specialty,
    String? assignedDoctorId,
  }) async {
    if (!SupabaseService.isReady) {
      throw StateError('Supabase belum dikonfigurasi.');
    }

    try {
      await SupabaseService.client.functions.invoke(
        'create-account',
        body: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
          if (specialty != null && specialty.isNotEmpty) 'specialty': specialty,
          if (assignedDoctorId != null && assignedDoctorId.isNotEmpty)
            'assigned_doctor_id': assignedDoctorId,
        },
      );
      DoctorService.clearCache();
    } on FunctionException catch (error) {
      throw StateError(_functionMessage(error));
    }
  }

  static String _functionMessage(FunctionException error) {
    final details = error.details;
    if (details is Map && details['error'] != null) {
      return '${details['error']}';
    }
    if (details is Map && details['message'] != null) {
      return '${details['message']}';
    }
    if (details is String && details.trim().isNotEmpty) {
      return details;
    }
    return error.reasonPhrase ?? 'Gagal membuat akun.';
  }
}
