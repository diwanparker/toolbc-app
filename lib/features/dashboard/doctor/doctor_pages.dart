import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/patient_data.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/doctor_service.dart';
import '../../auth/login_page.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  late Future<_DoctorDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadData();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadData(forceRefresh: true);
    });
    await _dashboardFuture;
  }

  Future<_DoctorDashboardData> _loadData({bool forceRefresh = false}) async {
    if (!ApiService.isAuthenticated) {
      return const _DoctorDashboardData.empty();
    }

    try {
      final response = await ApiService.get('/doctors/me/dashboard');
      if (response != null && response is Map<String, dynamic>) {
        final patients = await PatientService.fetchAssignedPatients(forceRefresh: forceRefresh);
        final notifications = await PatientService.fetchCurrentNotifications(forceRefresh: forceRefresh);
        return _DoctorDashboardData.fromApiResponse(
          json: response,
          patients: patients,
          notifications: notifications,
        );
      }
    } catch (e) {
      debugPrint('Error loading doctor dashboard: $e');
    }
    return const _DoctorDashboardData.empty();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DoctorDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _DoctorDashboardData.empty();
        return AppPage(
          onRefresh: _refresh,
          children: [
            const PageHeader(
              title: 'Dasbor Dokter 🩺',
              subtitle: 'Pantau beban kerja klinis, eskalasi, dan kondisi pasien.',
            ),
            const SizedBox(height: 16),
            _DoctorMetricGrid(data: data),
            const SizedBox(height: 16),
            SectionCard(
              background: data.urgentAlerts > 0 ? kSoftRed : kSoftGreen,
              borderColor: data.urgentAlerts > 0 ? kBorderRed : kBorderGreen,
              title: 'Peringatan Klinis',
              trailing: StatusPill(
                text: data.urgentAlerts > 0 ? 'Perlu Ditinjau' : 'Aman',
                bg: data.urgentAlerts > 0 ? kDanger : kSuccess,
                fg: Colors.white,
                icon: data.urgentAlerts > 0
                    ? Icons.warning_rounded
                    : Icons.check_circle_rounded,
              ),
              child: Text(
                data.urgentAlerts > 0
                    ? '${data.urgentAlerts} peringatan risiko memerlukan perhatian atau kontak pasien.'
                    : 'Tidak ada kasus kritis mendesak saat ini.',
                style: const TextStyle(fontSize: 12, color: kTextSecondary, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            if (data.queue.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada antrian eskalasi',
                message:
                    'Laporan checkup gejala berisiko dan pengingat akan muncul di sini.',
                icon: Icons.checklist_rtl_rounded,
              )
            else
              SectionCard(
                title: 'Antrian Tindak Lanjut Hari Ini',
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
  late Future<_DoctorPatientsData> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _loadData();
  }

  Future<void> _refresh() async {
    setState(() {
      _patientsFuture = _loadData(forceRefresh: true);
    });
    await _patientsFuture;
  }

  Future<_DoctorPatientsData> _loadData({bool forceRefresh = false}) async {
    if (!ApiService.isAuthenticated) return const _DoctorPatientsData.empty();

    final patientsFuture = PatientService.fetchAssignedPatients(forceRefresh: forceRefresh);

    List<NotificationEntryData> reminders = const [];
    try {
      final response = await ApiService.get('/doctors/me/reminders');
      if (response is List) {
        reminders = response
            .map((json) => NotificationEntryData.fromJson(json as Map<String, dynamic>))
            .toList(growable: false);
      }
    } catch (e) {
      debugPrint('Error fetching doctor reminders: $e');
      reminders = await PatientService.fetchCurrentNotifications(forceRefresh: forceRefresh);
    }

    final patients = await patientsFuture;

    return _DoctorPatientsData(
      patients: patients,
      notifications: reminders,
    );
  }

  Future<void> _updateReminderStatus(String reminderId, String status) async {
    try {
      await ApiService.patch('/reminders/$reminderId/status?status=$status');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengingat telah ditandai: $status ✅')),
      );
      _refresh();
    } catch (e) {
      debugPrint('Error updating reminder status: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DoctorPatientsData>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _DoctorPatientsData.empty();
        final unread = data.notifications.where((item) => !item.isRead).length;

        return AppPage(
          onRefresh: _refresh,
          children: [
            const PageHeader(
              title: 'Pengingat & Pasien',
              subtitle: 'Pantau kepatuhan pasien dan selesaikan antrian eskalasi.',
            ),
            // Top Search Bar (Reference Screen 4)
            CleanSearchBar(
              hint: 'Cari nama atau no. RM pasien...',
              trailing: IconButton(
                icon: const Icon(Icons.tune_rounded, color: kMuted, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorAllPatientsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Horizontal Recent Patients Avatars (Reference Screen 4 'Recent Contacts')
            if (data.patients.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pasien Terpantau',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
                      'Lihat Semua',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    // 'Add' Button (First item in reference image)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: kPastelCyan,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person_add_alt_1_rounded, color: kPrimary, size: 22),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tambah',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    for (final patient in data.patients.take(6)) ...[
                      InkWell(
                        onTap: () => _showPatientDetail(context, patient),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: patient.phase.toLowerCase() == 'intensif' ? kPastelAmber : kPastelGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: patient.phase.toLowerCase() == 'intensif' ? kBorderAmber : kBorderGreen,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: patient.phase.toLowerCase() == 'intensif' ? kWarning : kSuccess,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  patient.fullName.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            SectionCard(
              background: unread > 0 ? kSoftAmber : const Color(0xFFF8FAFC),
              borderColor: unread > 0 ? kBorderAmber : kBorder,
              title: 'Antrian Pengingat & Kasus',
              trailing: StatusPill(
                text: '$unread Aktif',
                bg: unread > 0 ? kWarning : const Color(0xFF64748B),
                fg: Colors.white,
              ),
              child: Text(
                unread > 0
                    ? '$unread pengingat menunggu konfirmasi atau tindak lanjut dokter.'
                    : 'Tidak ada pengingat tertunda saat ini.',
                style: const TextStyle(fontSize: 12, color: kTextSecondary, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            for (final item in data.notifications.take(4)) ...[
              _ReminderQueueTile(
                item: item,
                onUpdateStatus: _updateReminderStatus,
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pasien Binaan',
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
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: kPrimary),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18, color: kPrimary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (data.patients.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada pasien terdaftar',
                message:
                    'Pasien binaan akan muncul setelah admin mendaftarkan akun pasien.',
                icon: Icons.person_search_outlined,
              )
            else
              for (final patient in data.patients.take(6)) ...[
                _DoctorPatientTile(
                  patient: patient,
                  onTap: () => _showPatientDetail(context, patient),
                ),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }

  void _showPatientDetail(BuildContext context, PatientSummary patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DoctorPatientDetailSheet(patient: patient),
    );
  }
}

class DoctorAdherencePage extends StatefulWidget {
  const DoctorAdherencePage({super.key});

  @override
  State<DoctorAdherencePage> createState() => _DoctorAdherencePageState();
}

class _DoctorAdherencePageState extends State<DoctorAdherencePage> {
  late Future<_AdherenceData> _adherenceFuture;

  @override
  void initState() {
    super.initState();
    _adherenceFuture = _loadAdherence();
  }

  Future<void> _refresh() async {
    setState(() {
      _adherenceFuture = _loadAdherence(forceRefresh: true);
    });
    await _adherenceFuture;
  }

  Future<_AdherenceData> _loadAdherence({bool forceRefresh = false}) async {
    if (!ApiService.isAuthenticated) {
      return const _AdherenceData(patients: [], apiBuckets: null);
    }

    final patients = await PatientService.fetchAssignedPatients(forceRefresh: forceRefresh);

    _RiskBuckets? apiBuckets;
    try {
      final response = await ApiService.get('/doctors/me/adherence');
      if (response is List) {
        int high = 0, moderate = 0, stable = 0;
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            final label = '${item['label']}'.toLowerCase();
            final count = item['count'] as int? ?? 0;
            if (label.contains('high')) {
              high = count;
            } else if (label.contains('mod')) {
              moderate = count;
            } else if (label.contains('stab')) {
              stable = count;
            }
          }
        }
        apiBuckets = _RiskBuckets(high: high, moderate: moderate, stable: stable);
      }
    } catch (e) {
      debugPrint('Error fetching adherence data: $e');
    }

    return _AdherenceData(patients: patients, apiBuckets: apiBuckets);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AdherenceData>(
      future: _adherenceFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final patients = data?.patients ?? const <PatientSummary>[];
        final buckets = data?.apiBuckets ?? _RiskBuckets.fromPatients(patients);
        final totalPatients = patients.length;
        final average = patients.isEmpty
            ? 0
            : (patients
                      .map((patient) => patient.adherencePercent)
                      .reduce((a, b) => a + b) ~/
                  patients.length);

        return AppPage(
          onRefresh: _refresh,
          children: [
            const PageHeader(
              title: 'Analisis Kepatuhan 📊',
              subtitle: 'Identifikasi klaster risiko dan kepatuhan minum obat harian.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: kHeroShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rata-rata Kepatuhan Pasien',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD1FAE5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$average%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total $totalPatients pasien dalam pengawasan aktif.',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFD1FAE5)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Klaster Risiko Pasien',
              child: Column(
                children: [
                  _RiskBucketTile(
                    label: 'Risiko Tinggi (<75% Adherence)',
                    count: '${buckets.high} Pasien',
                    color: kDanger,
                    bg: kSoftRed,
                  ),
                  const SizedBox(height: 10),
                  _RiskBucketTile(
                    label: 'Risiko Sedang (75-90% Adherence)',
                    count: '${buckets.moderate} Pasien',
                    color: kWarning,
                    bg: kSoftAmber,
                  ),
                  const SizedBox(height: 10),
                  _RiskBucketTile(
                    label: 'Stabil (≥90% Adherence)',
                    count: '${buckets.stable} Pasien',
                    color: kSuccess,
                    bg: kSoftGreen,
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
    final confirmed = await showConfirmLogoutDialog(context);
    if (confirmed != true || !context.mounted) return;
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
        final specialty = profile?.specialty ?? 'Spesialis Paru / Poli TB';
        final email = profile?.email ?? 'dokter@dokter.com';

        return AppPage(
          children: [
            const PageHeader(
              title: 'Profil Dokter 🩺',
              subtitle: 'Identitas profesional, jadwal, dan pengaturan akun.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
                boxShadow: kCardShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: kSoftGreen,
                    child: Text(
                      name.isNotEmpty ? name[0] : 'D',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kSuccess,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialty,
                          style: const TextStyle(fontSize: 12.5, color: kPrimary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 11, color: kMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Pengaturan & Keamanan',
              child: Column(
                children: [
                  AccountRowTile(
                    icon: Icons.schedule_outlined,
                    title: 'Jadwal Konsultasi',
                    subtitle: 'Atur jam ketersediaan respons klinis',
                  ),
                  const SizedBox(height: 10),
                  AccountRowTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Preferensi Pengingat',
                    subtitle: 'Ambang batas peringatan risiko',
                  ),
                  const SizedBox(height: 10),
                  AccountRowTile(
                    icon: Icons.security_outlined,
                    title: 'Keamanan Akun',
                    subtitle: 'Kata sandi dan sesi aktif',
                  ),
                  const SizedBox(height: 10),
                  AccountRowTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    subtitle: 'Keluar dari akun dokter',
                    onTap: () => _logout(context),
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

class DoctorAllPatientsPage extends StatefulWidget {
  const DoctorAllPatientsPage({super.key});

  @override
  State<DoctorAllPatientsPage> createState() => _DoctorAllPatientsPageState();
}

class _DoctorAllPatientsPageState extends State<DoctorAllPatientsPage> {
  String _searchQuery = '';
  late Future<List<PatientSummary>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService.fetchAssignedPatients();
  }

  Future<void> _refresh() async {
    setState(() {
      _patientsFuture = PatientService.fetchAssignedPatients(forceRefresh: true);
    });
    await _patientsFuture;
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
              'Semua Pasien Binaan',
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
                    hintStyle: const TextStyle(color: kMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: kMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyStateCard(
                          title: 'Tidak ada pasien ditemukan',
                          message:
                              'Coba periksa kata kunci pencarian Anda atau segarkan data.',
                          icon: Icons.person_search_outlined,
                        )
                      : RefreshIndicator(
                          color: kPrimary,
                          backgroundColor: Colors.white,
                          onRefresh: _refresh,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final patient = filtered[index];
                              return _DoctorPatientTile(
                                patient: patient,
                                onTap: () => _showPatientDetail(context, patient),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPatientDetail(BuildContext context, PatientSummary patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DoctorPatientDetailSheet(patient: patient),
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

  factory _DoctorDashboardData.fromApiResponse({
    required Map<String, dynamic> json,
    required List<PatientSummary> patients,
    required List<NotificationEntryData> notifications,
  }) {
    final assignedPatients = json['assignedPatients'] as int? ?? patients.length;
    final urgentAlerts = json['urgentAlerts'] as int? ??
        notifications.where((item) => !item.isRead && item.severity != 'normal').length;
    final todayReviews = json['todayReviews'] as int? ?? 0;
    final pendingFollowUp = json['pendingFollowUp'] as int? ?? 0;

    final alerts = notifications
        .where((item) => !item.isRead && item.severity != 'normal')
        .toList(growable: false);
    final queue = <_QueueItem>[
      for (final alert in alerts.take(4))
        _QueueItem(
          name: alert.title,
          status: alert.body.isEmpty ? alert.status : alert.body,
          severity: alert.severity,
        ),
      if (alerts.isEmpty)
        for (final patient
            in patients
                .where((item) => item.riskStatus.toLowerCase() != 'stable')
                .take(4))
          _QueueItem(
            name: patient.fullName,
            status: patient.treatmentLabel,
            severity: patient.riskStatus,
          ),
    ];

    return _DoctorDashboardData(
      assignedPatients: assignedPatients,
      urgentAlerts: urgentAlerts,
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

class _AdherenceData {
  const _AdherenceData({required this.patients, required this.apiBuckets});

  final List<PatientSummary> patients;
  final _RiskBuckets? apiBuckets;
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
                label: 'Pasien Binaan',
                value: '${data.assignedPatients}',
                icon: Icons.groups_rounded,
                tint: kSoftBlue,
                accent: kPrimary,
                subtitle: 'Dalam pengawasan',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Peringatan Urgen',
                value: '${data.urgentAlerts}',
                icon: Icons.warning_amber_rounded,
                tint: kSoftRed,
                accent: kDanger,
                subtitle: 'Memerlukan review',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Review Hari Ini',
                value: '${data.todayReviews}',
                icon: Icons.fact_check_outlined,
                tint: kSoftGreen,
                accent: kSuccess,
                subtitle: 'Laporan tervalidasi',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Tindak Lanjut',
                value: '${data.pendingFollowUp}',
                icon: Icons.pending_actions_rounded,
                tint: kSoftAmber,
                accent: kWarning,
                subtitle: 'Menunggu respon',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status,
                  style: const TextStyle(fontSize: 11, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: _riskLabel(item.severity),
            bg: color.withValues(alpha: 0.12),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientTile extends StatelessWidget {
  const _DoctorPatientTile({required this.patient, this.onTap});

  final PatientSummary patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(patient.riskStatus);
    final isOverdue = patient.treatmentDay >= 56 && patient.phase.toLowerCase() == 'intensif';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kSoftBlue,
            child: Text(
              patient.fullName.isEmpty ? '?' : patient.fullName[0],
              style: const TextStyle(fontWeight: FontWeight.w800, color: kPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.warning_rounded, color: kDanger, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusPill(
                      text: patient.phase,
                      bg: patient.phase.toLowerCase() == 'intensif' ? kSoftAmber : kSoftGreen,
                      fg: patient.phase.toLowerCase() == 'intensif' ? kWarning : kSuccess,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• ${patient.treatmentLabel} • ${patient.adherenceLabel}',
                        style: const TextStyle(fontSize: 10.5, color: kMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StatusPill(
            text: patient.riskLabel,
            bg: color.withValues(alpha: 0.12),
            fg: color,
          ),
        ],
      ),
      ),
    );
  }
}

class _DoctorPatientDetailSheet extends StatefulWidget {
  const _DoctorPatientDetailSheet({required this.patient});
  final PatientSummary patient;

  @override
  State<_DoctorPatientDetailSheet> createState() => _DoctorPatientDetailSheetState();
}

class _DoctorPatientDetailSheetState extends State<_DoctorPatientDetailSheet> {
  bool _loading = false;
  List<Map<String, dynamic>> _labResults = [];
  double? _weight;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _loading = true);
    final results = await DoctorService.fetchLabResults(widget.patient.id);
    final history = await DoctorService.fetchWeightHistory(widget.patient.id);
    if (mounted) {
      setState(() {
        _labResults = results;
        if (history.isNotEmpty) {
          _weight = double.tryParse('${history.last['weight']}');
        }
        _loading = false;
      });
    }
  }

  Future<void> _transitionPhase() async {
    setState(() => _loading = true);
    try {
      await DoctorService.transitionPhase(widget.patient.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil transisi fase ✅')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addLabResult() async {
    // A simple mock for now or use a dialog
    setState(() => _loading = true);
    try {
      await DoctorService.addLabResult(widget.patient.id, 'Dahak Mikroskopis', 'Negatif', 'Hasil aman');
      await _loadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.patient.treatmentDay >= 56 && widget.patient.phase.toLowerCase() == 'intensif';

    return Container(
      decoration: const BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.patient.fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText),
              ),
              const CloseButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatusPill(text: widget.patient.phase, bg: kSoftBlue, fg: kPrimary),
              const SizedBox(width: 8),
              if (_weight != null)
                StatusPill(text: '$_weight kg', bg: kSoftGreen, fg: kSuccess, icon: Icons.monitor_weight_outlined),
            ],
          ),
          const SizedBox(height: 16),
          if (isOverdue)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kSoftAmber, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: kWarning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transisi Fase Diperlukan', style: TextStyle(fontWeight: FontWeight.w700, color: kWarning, fontSize: 13)),
                        Text('Pasien sudah hari ke-${widget.patient.treatmentDay}', style: const TextStyle(color: kWarning, fontSize: 11)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _transitionPhase,
                    style: ElevatedButton.styleFrom(backgroundColor: kWarning, foregroundColor: Colors.white),
                    child: const Text('Transisi Fase'),
                  ),
                ],
              ),
            ),
          SectionCard(
            title: 'Hasil Lab',
            trailing: InkWell(
              onTap: _loading ? null : _addLabResult,
              child: const Icon(Icons.add_circle_outline, color: kPrimary),
            ),
            child: _loading && _labResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _labResults.isEmpty
                    ? const Text('Belum ada data lab', style: TextStyle(color: kMuted, fontSize: 12))
                    : Column(
                        children: _labResults.map((e) {
                          final isPos = '${e['result']}'.toLowerCase() == 'positif';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${e['testType']}', style: const TextStyle(fontSize: 12)),
                                StatusPill(text: '${e['result']}', bg: isPos ? kSoftRed : kSoftGreen, fg: isPos ? kDanger : kSuccess),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReminderQueueTile extends StatelessWidget {
  const _ReminderQueueTile({required this.item, this.onUpdateStatus});

  final NotificationEntryData item;
  final void Function(String reminderId, String status)? onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(item.severity);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onUpdateStatus != null && !item.isRead && item.id.isNotEmpty
          ? () => onUpdateStatus!(item.id, 'Resolved')
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kSoftBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: kPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
            StatusPill(
              text: item.status,
              bg: color.withValues(alpha: 0.12),
              fg: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBucketTile extends StatelessWidget {
  const _RiskBucketTile({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  final String label;
  final String count;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
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
      return kDanger;
    case 'moderate':
    case 'medium':
    case 'warning':
      return kWarning;
    default:
      return kSuccess;
  }
}

String _riskLabel(String value) {
  switch (value.toLowerCase()) {
    case 'high':
    case 'critical':
    case 'urgent':
      return 'Risiko Tinggi';
    case 'moderate':
    case 'medium':
    case 'warning':
      return 'Risiko Sedang';
    default:
      return 'Stabil';
  }
}
