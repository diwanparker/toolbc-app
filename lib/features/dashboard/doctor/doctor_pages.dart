import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/ui_components.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  late Future<_DoctorDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_DoctorDashboardStats> _loadStats() async {
    final supabase = SupabaseService.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      return const _DoctorDashboardStats(
        assignedPatients: 0,
        urgentAlerts: 0,
        todayReviews: 0,
        pendingFollowUp: 0,
      );
    }

    final patientsRes = await supabase
        .from('patients_data')
        .select('id')
        .eq('assigned_doctor', user.id);
    final assignedPatients = (patientsRes as List).length;

    final notificationsRes = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false);
    final urgentAlerts = (notificationsRes as List).length;

    final appointmentsRes = await supabase
        .from('appointments')
        .select('id, scheduled_at, status')
        .eq('doctor_id', user.id);

    final appointments = (appointmentsRes as List).cast<Map<String, dynamic>>();
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

    return _DoctorDashboardStats(
      assignedPatients: assignedPatients,
      urgentAlerts: urgentAlerts,
      todayReviews: todayReviews,
      pendingFollowUp: pendingFollowUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Doctor Dashboard',
          subtitle: 'Review urgent cases and daily clinical workload.',
        ),
        const SizedBox(height: 16),
        FutureBuilder<_DoctorDashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? const _DoctorDashboardStats(
              assignedPatients: 0,
              urgentAlerts: 0,
              todayReviews: 0,
              pendingFollowUp: 0,
            );

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Assigned Patients',
                        value: '${stats.assignedPatients}',
                        icon: Icons.groups_rounded,
                        tint: kSurface,
                        accent: kPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'Urgent Alerts',
                        value: '${stats.urgentAlerts}',
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
                        value: '${stats.todayReviews}',
                        icon: Icons.fact_check_outlined,
                        tint: kSurface,
                        accent: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'Pending Follow-up',
                        value: '${stats.pendingFollowUp}',
                        icon: Icons.pending_actions_rounded,
                        tint: kSurface,
                        accent: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  background: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFCA5A5),
                  title: 'Critical Alert',
                  trailing: StatusPill(
                    text: 'Urgent',
                    bg: const Color(0xFFEF4444),
                    fg: Colors.white,
                  ),
                  child: Text(
                    stats.urgentAlerts > 0
                        ? '${stats.urgentAlerts} unread alerts need review.'
                        : 'No urgent alerts right now.',
                    style: const TextStyle(fontSize: 10.5, color: kMuted),
                  ),
                ),
                const SizedBox(height: 16),
                const SectionCard(
                  title: 'Today Queue',
                  child: Column(
                    children: [
                      _DoctorQueueTile(
                        name: 'Davina Karambol',
                        status: 'Missed evening dose',
                        severity: 'High',
                      ),
                      SizedBox(height: 10),
                      _DoctorQueueTile(
                        name: 'Nadia Putri',
                        status: 'Mild symptom escalation',
                        severity: 'Medium',
                      ),
                      SizedBox(height: 10),
                      _DoctorQueueTile(
                        name: 'Rizky Mahendra',
                        status: 'Daily report submitted',
                        severity: 'Low',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DoctorDashboardStats {
  const _DoctorDashboardStats({
    required this.assignedPatients,
    required this.urgentAlerts,
    required this.todayReviews,
    required this.pendingFollowUp,
  });

  final int assignedPatients;
  final int urgentAlerts;
  final int todayReviews;
  final int pendingFollowUp;
}

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Pengingat',
          subtitle: 'Pantau status pengobatan dan antrian eskalasi pasien.',
        ),
        const SizedBox(height: 16),
        const SectionCard(
          background: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFDBA74),
          title: 'Antrian Eskalasi',
          trailing: StatusPill(
            text: '3 Aktif',
            bg: Color(0xFFF97316),
            fg: Colors.white,
          ),
          child: Text(
            '3 peringatan atau pengingat menunggu konfirmasi dokter.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
        const SizedBox(height: 12),
        const _ReminderQueueTile(
          name: 'Davina Karambol',
          message: 'Melewatkan obat pagi > 2 jam',
          status: 'Escalated',
        ),
        const SizedBox(height: 10),
        const _ReminderQueueTile(
          name: 'Nadia Putri',
          message: 'Menunggu konfirmasi setelah pengingat',
          status: 'Pending',
        ),
        const SizedBox(height: 16),
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
            Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DoctorAllPatientsPage(),
                  ));
                },
                child: const Text('Lihat Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _DoctorPatientTile(
          name: 'Davina Karambol',
          treatmentDay: 'Day 24',
          adherence: '86%',
          badge: 'Needs review',
        ),
        const SizedBox(height: 12),
        const _DoctorPatientTile(
          name: 'Nadia Putri',
          treatmentDay: 'Day 11',
          adherence: '78%',
          badge: 'Moderate risk',
        ),
        const SizedBox(height: 12),
        const _DoctorPatientTile(
          name: 'Rizky Mahendra',
          treatmentDay: 'Day 36',
          adherence: '92%',
          badge: 'Stable',
        ),
      ],
    );
  }
}

class DoctorAdherencePage extends StatelessWidget {
  const DoctorAdherencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Adherence',
          subtitle: 'Identify risk clusters from adherence trend.',
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly adherence trend',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Chart placeholder',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Top issue: evening dose misses increased by 8% this week.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Risk Buckets',
          child: Column(
            children: [
              _RiskBucketTile(
                label: 'High Risk',
                count: '6 patients',
                color: Color(0xFFEF4444),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Moderate Risk',
                count: '14 patients',
                color: Color(0xFFF97316),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Stable',
                count: '28 patients',
                color: Color(0xFF22C55E),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Profile',
          subtitle: 'Doctor account, availability, and security settings.',
        ),
        SizedBox(height: 16),
        ProfileMenuTile(
          icon: Icons.badge_outlined,
          title: 'Professional Identity',
          subtitle: 'Dr. Arya Pratama • Pulmonology',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.schedule_outlined,
          title: 'Availability',
          subtitle: 'Set active consultation schedule',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.notifications_active_outlined,
          title: 'Reminder Preferences',
          subtitle: 'Escalation and alert threshold',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.security_outlined,
          title: 'Security',
          subtitle: 'Password and session management',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Exit doctor account',
          titleColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _DoctorQueueTile extends StatelessWidget {
  const _DoctorQueueTile({
    required this.name,
    required this.status,
    required this.severity,
  });

  final String name;
  final String status;
  final String severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'High' => const Color(0xFFEF4444),
      'Medium' => const Color(0xFFF97316),
      _ => const Color(0xFF22C55E),
    };

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
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: severity,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientTile extends StatelessWidget {
  const _DoctorPatientTile({
    required this.name,
    required this.treatmentDay,
    required this.adherence,
    required this.badge,
  });

  final String name;
  final String treatmentDay;
  final String adherence;
  final String badge;

  @override
  Widget build(BuildContext context) {
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
              name[0],
              style: const TextStyle(fontWeight: FontWeight.w700, color: kText),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$treatmentDay • Adherence $adherence',
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(text: badge, bg: const Color(0xFFF8FAFC), fg: kMuted),
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

class _ReminderQueueTile extends StatelessWidget {
  const _ReminderQueueTile({
    required this.name,
    required this.message,
    required this.status,
  });

  final String name;
  final String message;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Escalated' => const Color(0xFFEF4444),
      'Pending' => const Color(0xFFF97316),
      _ => const Color(0xFF16A34A),
    };

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
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: status,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final allPatients = [
      {'name': 'Davina Karambol', 'day': 'Hari ke-24 (Intensif)', 'adh': '86%', 'badge': 'Perlu ditinjau'},
      {'name': 'Nadia Putri', 'day': 'Hari ke-11 (Intensif)', 'adh': '78%', 'badge': 'Risiko sedang'},
      {'name': 'Rizky Mahendra', 'day': 'Hari ke-36 (Intensif)', 'adh': '92%', 'badge': 'Stabil'},
      {'name': 'Budi Santoso', 'day': 'Hari ke-40 (Lanjutan)', 'adh': '95%', 'badge': 'Stabil'},
      {'name': 'Siti Aminah', 'day': 'Hari ke-5 (Intensif)', 'adh': '60%', 'badge': 'Risiko tinggi'},
    ];

    final filtered = allPatients
        .where((p) => p['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        leading: const BackButton(color: kText),
        title: const Text('Semua Pasien', style: TextStyle(fontWeight: FontWeight.w700, color: kText)),
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
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return _DoctorPatientTile(
                    name: p['name']!,
                    treatmentDay: p['day']!,
                    adherence: p['adh']!,
                    badge: p['badge']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
