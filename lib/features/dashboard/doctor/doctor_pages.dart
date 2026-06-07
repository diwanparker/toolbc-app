import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/patient_data.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/login_page.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  late final Future<_DoctorDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadData();
  }

  Future<_DoctorDashboardData> _loadData() async {
    if (!ApiService.isAuthenticated) {
      return const _DoctorDashboardData.empty();
    }

    try {
      final response = await ApiService.get('/doctors/me/dashboard');
      if (response != null && response is Map<String, dynamic>) {
        final patients = await PatientService.fetchAssignedPatients();
        final notifications = await PatientService.fetchCurrentNotifications();
        return _DoctorDashboardData.fromSupabase(
          patients: patients,
          notifications: notifications,
          appointments: (response['appointments'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[],
        );
      }
    } catch (_) {}
    return const _DoctorDashboardData.empty();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DoctorDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _DoctorDashboardData.empty();
        return AppPage(
          children: [
            const PageHeader(
              title: 'Doctor Dashboard',
              subtitle: 'Review urgent cases and daily clinical workload.',
            ),
            const SizedBox(height: 16),
            _DoctorMetricGrid(data: data),
            const SizedBox(height: 16),
            SectionCard(
              background: data.urgentAlerts > 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderColor: data.urgentAlerts > 0
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFBBF7D0),
              title: 'Critical Alert',
              trailing: StatusPill(
                text: data.urgentAlerts > 0 ? 'Urgent' : 'Clear',
                bg: data.urgentAlerts > 0
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
                fg: Colors.white,
              ),
              child: Text(
                data.urgentAlerts > 0
                    ? '${data.urgentAlerts} unread alerts need review.'
                    : 'No urgent alerts right now.',
                style: const TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ),
            const SizedBox(height: 16),
            if (data.queue.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada antrian klinis',
                message:
                    'Pasien dan eskalasi akan tampil setelah data Supabase tersedia.',
              )
            else
              SectionCard(
                title: 'Today Queue',
                child: Column(
                  children: [
                    for (final item in data.queue) ...[
                      _DoctorQueueTile(item: item),
                      if (item != data.queue.last) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  late final Future<_DoctorPatientsData> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _loadData();
  }

  Future<_DoctorPatientsData> _loadData() async {
    if (!ApiService.isAuthenticated) return const _DoctorPatientsData.empty();

    final patientsFuture = PatientService.fetchAssignedPatients();
    final notificationsFuture = PatientService.fetchCurrentNotifications();
    final results = await Future.wait([patientsFuture, notificationsFuture]);
    final patients = results[0] as List<PatientSummary>;
    final notifications = results[1] as List<NotificationEntryData>;

    return _DoctorPatientsData(
      patients: patients,
      notifications: notifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DoctorPatientsData>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _DoctorPatientsData.empty();
        final unread = data.notifications.where((item) => !item.isRead).length;

        return AppPage(
          children: [
            const PageHeader(
              title: 'Pengingat',
              subtitle: 'Pantau status pengobatan dan antrian eskalasi pasien.',
            ),
            const SizedBox(height: 16),
            SectionCard(
              background: unread > 0
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFF8FAFC),
              borderColor: unread > 0
                  ? const Color(0xFFFDBA74)
                  : const Color(0xFFE2E8F0),
              title: 'Antrian Eskalasi',
              trailing: StatusPill(
                text: '$unread Aktif',
                bg: unread > 0
                    ? const Color(0xFFF97316)
                    : const Color(0xFF64748B),
                fg: Colors.white,
              ),
              child: Text(
                unread > 0
                    ? '$unread peringatan atau pengingat menunggu konfirmasi dokter.'
                    : 'Tidak ada pengingat aktif untuk dokter ini.',
                style: const TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ),
            const SizedBox(height: 12),
            for (final item in data.notifications.take(3)) ...[
              _ReminderQueueTile(item: item),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pasien',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DoctorAllPatientsPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Lihat Selengkapnya',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (data.patients.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada pasien',
                message:
                    'Admin perlu membuat akun pasien dan memilih dokter penanggung jawab.',
              )
            else
              for (final patient in data.patients.take(5)) ...[
                _DoctorPatientTile(patient: patient),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

class DoctorAdherencePage extends StatefulWidget {
  const DoctorAdherencePage({super.key});

  @override
  State<DoctorAdherencePage> createState() => _DoctorAdherencePageState();
}

class _DoctorAdherencePageState extends State<DoctorAdherencePage> {
  late final Future<List<PatientSummary>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService.fetchAssignedPatients();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PatientSummary>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final patients = snapshot.data ?? const <PatientSummary>[];
        final buckets = _RiskBuckets.fromPatients(patients);
        final average = patients.isEmpty
            ? 0
            : patients
                      .map((patient) => patient.adherencePercent)
                      .reduce((a, b) => a + b) ~/
                  patients.length;

        return AppPage(
          children: [
            const PageHeader(
              title: 'Adherence',
              subtitle: 'Identify risk clusters from adherence trend.',
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Weekly adherence trend',
              child: patients.isEmpty
                  ? const Text(
                      'Belum ada data kepatuhan dari Supabase.',
                      style: TextStyle(fontSize: 10.5, color: kMuted),
                    )
                  : Text(
                      'Rata-rata kepatuhan pasien aktif: $average%.',
                      style: const TextStyle(fontSize: 10.5, color: kMuted),
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Risk Buckets',
              child: Column(
                children: [
                  _RiskBucketTile(
                    label: 'High Risk',
                    count: '${buckets.high} patients',
                    color: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 10),
                  _RiskBucketTile(
                    label: 'Moderate Risk',
                    count: '${buckets.moderate} patients',
                    color: const Color(0xFFF97316),
                  ),
                  const SizedBox(height: 10),
                  _RiskBucketTile(
                    label: 'Stable',
                    count: '${buckets.stable} patients',
                    color: const Color(0xFF22C55E),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = Future.value(AuthService.currentUser);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthLoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.displayName ?? 'Dokter ToolBC';
        final specialty = profile?.specialty ?? 'Spesialisasi belum diatur';

        return AppPage(
          children: [
            const PageHeader(
              title: 'Profile',
              subtitle: 'Doctor account, availability, and security settings.',
            ),
            const SizedBox(height: 16),
            ProfileMenuTile(
              icon: Icons.badge_outlined,
              title: 'Professional Identity',
              subtitle: '$name - $specialty',
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.schedule_outlined,
              title: 'Availability',
              subtitle: 'Set active consultation schedule',
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.notifications_active_outlined,
              title: 'Reminder Preferences',
              subtitle: 'Escalation and alert threshold',
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password and session management',
            ),
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Exit doctor account',
              titleColor: const Color(0xFFEF4444),
              onTap: () => _logout(context),
            ),
          ],
        );
      },
    );
  }
}

class DoctorAllPatientsPage extends StatefulWidget {
  const DoctorAllPatientsPage({super.key});

  @override
  State<DoctorAllPatientsPage> createState() => _DoctorAllPatientsPageState();
}

class _DoctorAllPatientsPageState extends State<DoctorAllPatientsPage> {
  String _searchQuery = '';
  late final Future<List<PatientSummary>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService.fetchAssignedPatients();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PatientSummary>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final allPatients = snapshot.data ?? const <PatientSummary>[];
        final query = _searchQuery.trim().toLowerCase();
        final filtered = query.isEmpty
            ? allPatients
            : allPatients
                  .where(
                    (patient) => patient.fullName.toLowerCase().contains(query),
                  )
                  .toList(growable: false);

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            elevation: 0,
            leading: const BackButton(color: kText),
            title: const Text(
              'Semua Pasien',
              style: TextStyle(fontWeight: FontWeight.w700, color: kText),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama pasien...',
                    hintStyle: const TextStyle(color: kMuted),
                    prefixIcon: const Icon(Icons.search, color: kMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyStateCard(
                          title: 'Tidak ada pasien',
                          message:
                              'Data pasien akan tampil setelah admin membuat akun dan mengatur penanggung jawab.',
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _DoctorPatientTile(patient: filtered[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DoctorDashboardData {
  const _DoctorDashboardData({
    required this.assignedPatients,
    required this.urgentAlerts,
    required this.todayReviews,
    required this.pendingFollowUp,
    required this.queue,
  });

  const _DoctorDashboardData.empty()
    : assignedPatients = 0,
      urgentAlerts = 0,
      todayReviews = 0,
      pendingFollowUp = 0,
      queue = const [];

  final int assignedPatients;
  final int urgentAlerts;
  final int todayReviews;
  final int pendingFollowUp;
  final List<_QueueItem> queue;

  factory _DoctorDashboardData.fromSupabase({
    required List<PatientSummary> patients,
    required List<NotificationEntryData> notifications,
    required List<Map<String, dynamic>> appointments,
  }) {
    final today = DateTime.now();
    final todayReviews = appointments.where((row) {
      final scheduledAt = DateTime.tryParse('${row['scheduled_at']}');
      if (scheduledAt == null) return false;
      return scheduledAt.year == today.year &&
          scheduledAt.month == today.month &&
          scheduledAt.day == today.day;
    }).length;

    final pendingFollowUp = appointments.where((row) {
      final status = '${row['status']}'.toLowerCase();
      return status != 'completed';
    }).length;

    final alerts = notifications
        .where((item) => !item.isRead && item.severity != 'normal')
        .toList(growable: false);
    final queue = <_QueueItem>[
      for (final alert in alerts.take(3))
        _QueueItem(
          name: alert.title,
          status: alert.body.isEmpty ? alert.status : alert.body,
          severity: alert.severity,
        ),
      if (alerts.isEmpty)
        for (final patient
            in patients
                .where((item) => item.riskStatus.toLowerCase() != 'stable')
                .take(3))
          _QueueItem(
            name: patient.fullName,
            status: patient.treatmentLabel,
            severity: patient.riskStatus,
          ),
    ];

    return _DoctorDashboardData(
      assignedPatients: patients.length,
      urgentAlerts: alerts.length,
      todayReviews: todayReviews,
      pendingFollowUp: pendingFollowUp,
      queue: queue,
    );
  }
}

class _DoctorPatientsData {
  const _DoctorPatientsData({
    required this.patients,
    required this.notifications,
  });

  const _DoctorPatientsData.empty()
    : patients = const [],
      notifications = const [];

  final List<PatientSummary> patients;
  final List<NotificationEntryData> notifications;
}

class _DoctorMetricGrid extends StatelessWidget {
  const _DoctorMetricGrid({required this.data});

  final _DoctorDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Assigned Patients',
                value: '${data.assignedPatients}',
                icon: Icons.groups_rounded,
                tint: kSurface,
                accent: kPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Urgent Alerts',
                value: '${data.urgentAlerts}',
                icon: Icons.notification_important_outlined,
                tint: kSurface,
                accent: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Today Reviews',
                value: '${data.todayReviews}',
                icon: Icons.fact_check_outlined,
                tint: kSurface,
                accent: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Pending Follow-up',
                value: '${data.pendingFollowUp}',
                icon: Icons.pending_actions_rounded,
                tint: kSurface,
                accent: const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QueueItem {
  const _QueueItem({
    required this.name,
    required this.status,
    required this.severity,
  });

  final String name;
  final String status;
  final String severity;
}

class _DoctorQueueTile extends StatelessWidget {
  const _DoctorQueueTile({required this.item});

  final _QueueItem item;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(item.severity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: _riskLabel(item.severity),
            bg: color,
            fg: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientTile extends StatelessWidget {
  const _DoctorPatientTile({required this.patient});

  final PatientSummary patient;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(patient.riskStatus);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE2E8F0),
            child: Text(
              patient.fullName.isEmpty ? '?' : patient.fullName[0],
              style: const TextStyle(fontWeight: FontWeight.w700, color: kText),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient.treatmentLabel} - Adherence ${patient.adherenceLabel}',
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: patient.riskLabel,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _ReminderQueueTile extends StatelessWidget {
  const _ReminderQueueTile({required this.item});

  final NotificationEntryData item;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(item.severity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: kPrimary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: item.status,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _RiskBucketTile extends StatelessWidget {
  const _RiskBucketTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          Text(count, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      ),
    );
  }
}

class _RiskBuckets {
  const _RiskBuckets({
    required this.high,
    required this.moderate,
    required this.stable,
  });

  final int high;
  final int moderate;
  final int stable;

  factory _RiskBuckets.fromPatients(List<PatientSummary> patients) {
    var high = 0;
    var moderate = 0;
    var stable = 0;

    for (final patient in patients) {
      switch (patient.riskStatus.toLowerCase()) {
        case 'high':
        case 'critical':
          high++;
          break;
        case 'moderate':
        case 'medium':
          moderate++;
          break;
        case 'stable':
        case 'low':
          stable++;
          break;
      }
    }

    return _RiskBuckets(high: high, moderate: moderate, stable: stable);
  }
}

Color _riskColor(String value) {
  switch (value.toLowerCase()) {
    case 'high':
    case 'critical':
    case 'urgent':
      return const Color(0xFFEF4444);
    case 'moderate':
    case 'medium':
    case 'warning':
      return const Color(0xFFF97316);
    default:
      return const Color(0xFF22C55E);
  }
}

String _riskLabel(String value) {
  switch (value.toLowerCase()) {
    case 'high':
    case 'critical':
    case 'urgent':
      return 'High';
    case 'moderate':
    case 'medium':
    case 'warning':
      return 'Medium';
    default:
      return 'Low';
  }
}
