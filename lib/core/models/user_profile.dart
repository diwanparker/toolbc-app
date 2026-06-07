import 'app_mode.dart';

enum UserRole {
  patient,
  doctor,
  admin;

  AppMode get appMode {
    switch (this) {
      case UserRole.patient:
        return AppMode.patient;
      case UserRole.doctor:
        return AppMode.doctor;
      case UserRole.admin:
        return AppMode.admin;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.specialty,
    this.assignedDoctorId,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? specialty;
  final String? assignedDoctorId;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _parseRole(json['role']),
      specialty: json['specialty'] as String?,
      assignedDoctorId: json['assignedDoctorId'] as String? ?? json['assigned_doctor_id'] as String?,
    );
  }

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return 'Pengguna ToolBC';
  }

  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return 'T';
    final words = source.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length <= 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  static UserRole _parseRole(dynamic value) {
    switch ('$value'.trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'doctor':
      case 'dokter':
        return UserRole.doctor;
      case 'patient':
      case 'pasien':
      case 'user':
        return UserRole.patient;
      default:
        throw FormatException('Role profil tidak valid: $value');
    }
  }
}
