import '../models/doctor_model.dart';
import 'supabase_service.dart';

/// Service for fetching and managing doctor data.
class DoctorService {
  DoctorService._();

  /// Cached doctor list to avoid repeated API calls within one session.
  static List<DoctorModel>? _cachedDoctors;

  /// Demo/fallback doctor list for offline or unconfigured Supabase.
  static const List<DoctorModel> _demoDoctors = [
    DoctorModel(
      id: 'demo-doc-1',
      fullName: 'Dr. Arya Pratama',
      specialty: 'Pulmonology',
      email: 'arya@dokter.com',
    ),
    DoctorModel(
      id: 'demo-doc-2',
      fullName: 'Dr. Siti Rahmawati',
      specialty: 'Internal Medicine',
      email: 'siti@dokter.com',
    ),
    DoctorModel(
      id: 'demo-doc-3',
      fullName: 'Dr. Budi Santoso',
      specialty: 'Infectious Disease',
      email: 'budi@dokter.com',
    ),
  ];

  /// Fetches all registered doctors.
  ///
  /// If Supabase is configured, it queries users with role = 'doctor'.
  /// Otherwise, returns demo doctor list for development/preview.
  static Future<List<DoctorModel>> fetchDoctors({
    bool forceRefresh = false,
  }) async {
    if (_cachedDoctors != null && !forceRefresh) return _cachedDoctors!;

    if (!SupabaseService.isConfigured) {
      _cachedDoctors = _demoDoctors;
      return _cachedDoctors!;
    }

    try {
      // Query from a 'profiles' table (common Supabase pattern)
      // or from auth.admin.listUsers if you have admin privileges.
      // Adjust the table/column names to your actual Supabase schema.
      final response = await SupabaseService.client
          .from('profiles')
          .select('id, full_name, specialty, email')
          .eq('role', 'doctor')
          .order('full_name');

      final data = response as List<dynamic>;
      _cachedDoctors = data
          .map((row) => DoctorModel.fromSupabaseUser(row as Map<String, dynamic>))
          .toList();

      // If the query returned nothing, fall back to demo list.
      if (_cachedDoctors!.isEmpty) _cachedDoctors = _demoDoctors;

      return _cachedDoctors!;
    } catch (_) {
      // On any error (table doesn't exist yet, etc.) fall back to demo list.
      _cachedDoctors = _demoDoctors;
      return _cachedDoctors!;
    }
  }

  /// Clears the cached doctor list so the next [fetchDoctors] will re-query.
  static void clearCache() => _cachedDoctors = null;
}
