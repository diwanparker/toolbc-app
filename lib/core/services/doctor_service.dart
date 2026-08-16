import 'package:flutter/foundation.dart';
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
            .map((row) => DoctorModel.fromJson(row as Map<String, dynamic>))
            .toList(growable: false);
        _cachedAt = DateTime.now();
      } else {
        _cachedDoctors = const [];
        _cachedAt = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
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

  /// Transitions a patient to the next treatment phase.
  static Future<void> transitionPhase(String patientProfileId) async {
    await ApiService.post('/doctor/patients/$patientProfileId/transition-phase');
  }

  /// Fetches lab results for a patient.
  static Future<List<Map<String, dynamic>>> fetchLabResults(String patientProfileId) async {
    try {
      final response = await ApiService.get('/doctor/patients/$patientProfileId/lab-results');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint('Error fetching lab results: $e');
    }
    return [];
  }

  /// Adds a new lab result for a patient.
  static Future<void> addLabResult(
    String patientProfileId,
    String testType,
    String result,
    String? notes,
  ) async {
    final body = <String, dynamic>{
      'testType': testType,
      'result': result,
    };
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }
    await ApiService.post('/doctor/patients/$patientProfileId/lab-results', body: body);
  }

  /// Fetches weight history for a patient.
  static Future<List<Map<String, dynamic>>> fetchWeightHistory(String patientProfileId) async {
    try {
      final response = await ApiService.get('/doctor/patients/$patientProfileId/weight-history');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint('Error fetching weight history: $e');
    }
    return [];
  }
}
