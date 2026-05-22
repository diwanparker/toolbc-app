import 'user_profile.dart';

class PatientSummary {
  const PatientSummary({
    required this.id,
    required this.patientId,
    required this.fullName,
    required this.email,
    required this.assignedDoctorId,
    required this.treatmentPhase,
    required this.treatmentDay,
    required this.adherencePercent,
    required this.riskStatus,
  });

  final String id;
  final String patientId;
  final String fullName;
  final String email;
  final String assignedDoctorId;
  final String treatmentPhase;
  final int treatmentDay;
  final int adherencePercent;
  final String riskStatus;

  factory PatientSummary.fromRows({
    required Map<String, dynamic> data,
    required Map<String, dynamic>? profile,
  }) {
    return PatientSummary(
      id: data['id'] as String? ?? '',
      patientId: data['patient_id'] as String? ?? '',
      fullName: profile?['full_name'] as String? ?? 'Pasien tanpa nama',
      email: profile?['email'] as String? ?? '',
      assignedDoctorId: data['assigned_doctor'] as String? ?? '',
      treatmentPhase: data['treatment_phase'] as String? ?? 'Belum diatur',
      treatmentDay: _asInt(data['treatment_day']),
      adherencePercent: _asInt(data['adherence_percent']),
      riskStatus: data['risk_status'] as String? ?? 'new',
    );
  }

  String get treatmentLabel {
    if (treatmentDay <= 0) return 'Hari pengobatan belum diatur';
    return 'Hari ke-$treatmentDay (${_phaseLabel(treatmentPhase)})';
  }

  String get adherenceLabel => '$adherencePercent%';

  String get riskLabel {
    switch (riskStatus.toLowerCase()) {
      case 'high':
      case 'critical':
        return 'Risiko tinggi';
      case 'moderate':
      case 'medium':
        return 'Risiko sedang';
      case 'stable':
      case 'low':
        return 'Stabil';
      default:
        return 'Perlu data';
    }
  }

  static String _phaseLabel(String value) {
    switch (value.toLowerCase()) {
      case 'intensive':
        return 'Intensif';
      case 'continuation':
        return 'Lanjutan';
      default:
        return value;
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }
}

class PatientDashboardData {
  const PatientDashboardData({required this.profile, this.patient});

  final UserProfile profile;
  final PatientSummary? patient;
}

class MedicationLogEntry {
  const MedicationLogEntry({
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String title;
  final String status;
  final DateTime? createdAt;

  factory MedicationLogEntry.fromJson(Map<String, dynamic> json) {
    return MedicationLogEntry(
      title: json['title'] as String? ?? 'Catatan pengobatan',
      status: json['status'] as String? ?? 'info',
      createdAt: DateTime.tryParse('${json['created_at']}'),
    );
  }
}

class NotificationEntryData {
  const NotificationEntryData({
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.severity,
    required this.isRead,
    required this.createdAt,
  });

  final String type;
  final String title;
  final String body;
  final String status;
  final String severity;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationEntryData.fromJson(Map<String, dynamic> json) {
    return NotificationEntryData(
      type: json['type'] as String? ?? 'reminder',
      title: json['title'] as String? ?? 'Notifikasi',
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'Info',
      severity: json['severity'] as String? ?? 'normal',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse('${json['created_at']}'),
    );
  }
}
