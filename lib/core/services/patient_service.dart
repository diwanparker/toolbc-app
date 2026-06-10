import 'package:flutter/foundation.dart';

import '../models/patient_data.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PatientService {
  PatientService._();

  static const Duration _cacheTtl = Duration(seconds: 30);
  static String? _lastUserId;

  static _CacheEntry<List<PatientSummary>>? _assignedPatientsCache;
  static String? _assignedPatientsDoctorId;
  static _CacheEntry<PatientDashboardData?>? _currentDashboardCache;
  static _CacheEntry<List<MedicationLogEntry>>? _medicationLogsCache;
  static _CacheEntry<List<NotificationEntryData>>? _notificationsCache;

  static void _resetIfUserChanged() {
    final currentUserId = AuthService.currentUser?.id;
    if (_lastUserId == currentUserId) return;
    _lastUserId = currentUserId;
    _assignedPatientsCache = null;
    _assignedPatientsDoctorId = null;
    _currentDashboardCache = null;
    _medicationLogsCache = null;
    _notificationsCache = null;
  }

  static bool _isFresh(DateTime? fetchedAt) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt) <= _cacheTtl;
  }

  static Future<List<PatientSummary>> fetchAssignedPatients({
    String? doctorId,
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!ApiService.isAuthenticated) return const [];

    final activeDoctorId = doctorId ?? AuthService.currentUser?.id;
    if (activeDoctorId == null) return const [];

    if (!forceRefresh &&
        _assignedPatientsCache != null &&
        _assignedPatientsDoctorId == activeDoctorId &&
        _isFresh(_assignedPatientsCache!.fetchedAt)) {
      return _assignedPatientsCache!.value;
    }

    try {
      final response = await ApiService.get('/doctors/me/patients');
      if (response is List) {
        final result = response
            .map((json) => PatientSummary.fromJson(json as Map<String, dynamic>))
            .toList(growable: false);
        _assignedPatientsCache = _CacheEntry(result, DateTime.now());
        _assignedPatientsDoctorId = activeDoctorId;
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching assigned patients: $e');
    }
    return const [];
  }

  static Future<PatientDashboardData?> fetchCurrentPatientDashboard({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!ApiService.isAuthenticated) return null;

    if (!forceRefresh &&
        _currentDashboardCache != null &&
        _isFresh(_currentDashboardCache!.fetchedAt)) {
      return _currentDashboardCache!.value;
    }

    final profile = AuthService.currentUser;
    if (profile == null) return null;

    try {
      final response = await ApiService.get('/patients/me/dashboard');
      if (response is Map<String, dynamic>) {
        final result = PatientDashboardData(
          profile: profile,
          treatment: response['treatment'] != null ? TreatmentSummary.fromJson(response['treatment']) : null,
          doctorName: response['doctorName'],
          medicalRecordNumber: response['medicalRecordNumber'],
        );
        _currentDashboardCache = _CacheEntry(result, DateTime.now());
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching patient dashboard: $e');
    }
    
    return PatientDashboardData(profile: profile);
  }

  static Future<List<MedicationLogEntry>> fetchCurrentMedicationLogs({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!ApiService.isAuthenticated) return const [];

    if (!forceRefresh &&
        _medicationLogsCache != null &&
        _isFresh(_medicationLogsCache!.fetchedAt)) {
      return _medicationLogsCache!.value;
    }

    try {
      final response = await ApiService.get('/patients/me/history');
      if (response is List) {
        final result = response
            .map((json) => MedicationLogEntry.fromJson(json as Map<String, dynamic>))
            .toList(growable: false);
        _medicationLogsCache = _CacheEntry(result, DateTime.now());
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching medication logs: $e');
    }
    return const [];
  }

  static Future<List<NotificationEntryData>> fetchCurrentNotifications({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!ApiService.isAuthenticated) return const [];

    if (!forceRefresh &&
        _notificationsCache != null &&
        _isFresh(_notificationsCache!.fetchedAt)) {
      return _notificationsCache!.value;
    }

    try {
      final response = await ApiService.get('/notifications');
      if (response is List) {
        final result = response
            .map((json) => NotificationEntryData.fromJson(json as Map<String, dynamic>))
            .toList(growable: false);
        _notificationsCache = _CacheEntry(result, DateTime.now());
        return result;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
    return const [];
  }

  /// Confirms a medication dose with the given status.
  static Future<Map<String, dynamic>> confirmMedicationDose({
    required String doseLogId,
    required String status,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'doseLogId': doseLogId,
      'status': status,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    return await ApiService.post('/patients/me/medication-logs', body: body);
  }

  /// Submits a symptom checkup report.
  static Future<Map<String, dynamic>> submitSymptomCheckup({
    required bool persistentCough,
    required bool feverOrChills,
    required bool nightSweats,
    required bool weightLoss,
  }) async {
    return await ApiService.post('/patients/me/symptom-logs', body: {
      'persistentCough': persistentCough,
      'feverOrChills': feverOrChills,
      'nightSweats': nightSweats,
      'weightLoss': weightLoss,
    });
  }
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.fetchedAt);

  final T value;
  final DateTime fetchedAt;
}
