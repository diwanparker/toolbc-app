import '../models/patient_data.dart';
import 'supabase_service.dart';

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
    final currentUserId = SupabaseService.currentUser?.id;
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
    if (!SupabaseService.isReady) return const [];

    final activeDoctorId = doctorId ?? SupabaseService.currentUser?.id;
    if (activeDoctorId == null) return const [];

    if (!forceRefresh &&
        _assignedPatientsCache != null &&
        _assignedPatientsDoctorId == activeDoctorId &&
        _isFresh(_assignedPatientsCache!.fetchedAt)) {
      return _assignedPatientsCache!.value;
    }

    final rows = await SupabaseService.client
        .from('patients_data')
        .select(
          'id, patient_id, assigned_doctor, treatment_phase, treatment_day, adherence_percent, risk_status',
        )
        .eq('assigned_doctor', activeDoctorId)
        .order('risk_status')
        .order('treatment_day', ascending: false);

    final data = (rows as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
    if (data.isEmpty) return const [];

    final profileIds = data
        .map((row) => row['patient_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final profiles = await _fetchProfilesByIds(profileIds);

    final result = data
        .map(
          (row) => PatientSummary.fromRows(
            data: row,
            profile: profiles[row['patient_id']],
          ),
        )
        .toList(growable: false);

    _assignedPatientsCache = _CacheEntry(result, DateTime.now());
    _assignedPatientsDoctorId = activeDoctorId;
    return result;
  }

  static Future<PatientDashboardData?> fetchCurrentPatientDashboard({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!SupabaseService.isReady) return null;

    if (!forceRefresh &&
        _currentDashboardCache != null &&
        _isFresh(_currentDashboardCache!.fetchedAt)) {
      return _currentDashboardCache!.value;
    }

    final profile = await SupabaseService.fetchCurrentProfile();
    if (profile == null) return null;

    final data = await SupabaseService.client
        .from('patients_data')
        .select(
          'id, patient_id, assigned_doctor, treatment_phase, treatment_day, adherence_percent, risk_status',
        )
        .eq('patient_id', profile.id)
        .maybeSingle();

    final patient = data == null
        ? null
        : PatientSummary.fromRows(
            data: data,
            profile: {'full_name': profile.fullName, 'email': profile.email},
          );

    final result = PatientDashboardData(profile: profile, patient: patient);
    _currentDashboardCache = _CacheEntry(result, DateTime.now());
    return result;
  }

  static Future<List<MedicationLogEntry>> fetchCurrentMedicationLogs({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!SupabaseService.isReady) return const [];

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return const [];

    if (!forceRefresh &&
        _medicationLogsCache != null &&
        _isFresh(_medicationLogsCache!.fetchedAt)) {
      return _medicationLogsCache!.value;
    }

    final rows = await SupabaseService.client
        .from('medication_logs')
        .select('title, status, created_at')
        .eq('patient_id', userId)
        .order('created_at', ascending: false)
        .limit(20);

    final result = (rows as List<dynamic>)
        .map((row) => MedicationLogEntry.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);

    _medicationLogsCache = _CacheEntry(result, DateTime.now());
    return result;
  }

  static Future<List<NotificationEntryData>> fetchCurrentNotifications({
    bool forceRefresh = false,
  }) async {
    _resetIfUserChanged();
    if (!SupabaseService.isReady) return const [];

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return const [];

    if (!forceRefresh &&
        _notificationsCache != null &&
        _isFresh(_notificationsCache!.fetchedAt)) {
      return _notificationsCache!.value;
    }

    final rows = await SupabaseService.client
        .from('notifications')
        .select('type, title, body, status, severity, is_read, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    final result = (rows as List<dynamic>)
        .map(
          (row) => NotificationEntryData.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);

    _notificationsCache = _CacheEntry(result, DateTime.now());
    return result;
  }

  static Future<Map<String, Map<String, dynamic>>> _fetchProfilesByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const {};

    final rows = await SupabaseService.client
        .from('profiles')
        .select('id, full_name, email')
        .inFilter('id', ids);

    return {
      for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>())
        row['id'] as String: row,
    };
  }
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.fetchedAt);

  final T value;
  final DateTime fetchedAt;
}
