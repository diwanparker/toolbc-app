import 'api_service.dart';
import 'doctor_service.dart';

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
    if (!ApiService.isAuthenticated) {
      throw StateError('Anda harus login sebagai admin.');
    }

    // Role enum string validation based on .NET backend (Patient, Doctor, Admin)
    final roleValue = role.trim().toLowerCase() == 'doctor' ? 'Doctor' 
                    : role.trim().toLowerCase() == 'admin' ? 'Admin' 
                    : 'Patient';

    final body = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': roleValue,
    };

    if (specialty != null && specialty.isNotEmpty) {
      body['note'] = specialty;
    }
    
    if (assignedDoctorId != null && assignedDoctorId.isNotEmpty) {
      body['assignedDoctorId'] = assignedDoctorId;
    }

    try {
      await ApiService.post('/admin/users', body: body);
      DoctorService.clearCache();
    } catch (error) {
      throw StateError(_functionMessage(error));
    }
  }

  static String _functionMessage(Object error) {
    if (error is StateError) {
      return error.message;
    }
    return error.toString();
  }
}
