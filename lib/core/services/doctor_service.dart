import '../models/doctor_model.dart';
import 'api_service.dart';

/// Service for fetching and managing doctor data.
class DoctorService {
  DoctorService._();

  static const Duration _cacheTtl = Duration(seconds: 60);

  /// Cached doctor list to avoid repeated API calls within one session.
  static List<DoctorModel>? _cachedDoctors;
  static DateTime? _cachedAt;

  /// Fetches all registered doctors.
  static Future<List<DoctorModel>> fetchDoctors({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedDoctors != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) <= _cacheTtl) {
      return _cachedDoctors!;
    }

    if (!ApiService.isAuthenticated) {
      _cachedDoctors = const [];
      _cachedAt = DateTime.now();
      return _cachedDoctors!;
    }

    try {
      final response = await ApiService.get('/admin/doctors');
      if (response is List) {
        _cachedDoctors = response
            .map((row) => DoctorModel.fromSupabaseUser(row as Map<String, dynamic>))
            .toList(growable: false);
        _cachedAt = DateTime.now();
      } else {
        _cachedDoctors = const [];
        _cachedAt = DateTime.now();
      }
    } catch (_) {
      _cachedDoctors = const [];
      _cachedAt = DateTime.now();
    }

    return _cachedDoctors!;
  }

  /// Clears the cached doctor list so the next [fetchDoctors] will re-query.
  static void clearCache() {
    _cachedDoctors = null;
    _cachedAt = null;
  }
}
