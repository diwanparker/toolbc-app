import '../models/doctor_model.dart';
import 'supabase_service.dart';

/// Service for fetching and managing doctor data.
class DoctorService {
  DoctorService._();

  /// Cached doctor list to avoid repeated API calls within one session.
  static List<DoctorModel>? _cachedDoctors;

  /// Fetches all registered doctors.
  static Future<List<DoctorModel>> fetchDoctors({
    bool forceRefresh = false,
  }) async {
    if (_cachedDoctors != null && !forceRefresh) return _cachedDoctors!;

    if (!SupabaseService.isReady) {
      _cachedDoctors = const [];
      return _cachedDoctors!;
    }

    final response = await SupabaseService.client
        .from('profiles')
        .select('id, full_name, specialty, email')
        .eq('role', 'doctor')
        .order('full_name');

    final data = response as List<dynamic>;
    _cachedDoctors = data
        .map((row) => DoctorModel.fromSupabaseUser(row as Map<String, dynamic>))
        .toList(growable: false);

    return _cachedDoctors!;
  }

  /// Clears the cached doctor list so the next [fetchDoctors] will re-query.
  static void clearCache() => _cachedDoctors = null;
}
