import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/patient_data.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';
import 'patient_chat_page.dart';
import 'symptom_checkup_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late Future<PatientDashboardData?> _dashboardFuture;
  bool _confirmingDose = false;
  bool _doseTakenToday = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = PatientService.fetchCurrentPatientDashboard();
  }

  Future<void> _confirmDose() async {
    if (_confirmingDose || _doseTakenToday) return;
    setState(() => _confirmingDose = true);

    try {
      await PatientService.confirmMedicationDose(
        doseLogId: 'today',
        status: 'Taken',
      );
      if (!mounted) return;
      setState(() => _doseTakenToday = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obat hari ini berhasil dicatat! Tetap semangat! ✅')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengonfirmasi obat: $e')),
      );
    } finally {
      if (mounted) setState(() => _confirmingDose = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture =
          PatientService.fetchCurrentPatientDashboard(forceRefresh: true);
    });
    await _dashboardFuture;
  }

  void _openSymptomCheckup() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SymptomCheckupPage(),
      ),
    );
  }

  void _openAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: SafeArea(child: PatientChatPage()),
        ),
      ),
    );
  }

  void _showLabSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hasil Laboratorium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: kMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ActivityItemTile(
              title: 'TCM / GeneXpert Dahak',
              subtitle: '12 Agustus 2026 • Awal Terapi',
              icon: Icons.biotech_rounded,
              iconBg: kPastelCyan,
              iconFg: kPrimaryDark,
              trailingWidget: StatusPill(text: 'Positif (Sensitif RIF)', bg: kPastelAmber, fg: kWarning),
            ),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Foto Toraks (Rontgen Dada)',
              subtitle: '10 Agustus 2026 • Infiltrat Paru Kanan',
              icon: Icons.image_search_rounded,
              iconBg: kPastelGreen,
              iconFg: kSuccess,
              trailingWidget: StatusPill(text: 'TB Paru Aktif', bg: kPastelCyan, fg: kPrimaryDark),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Evaluasi sputum ulang dijadwalkan pada akhir Bulan ke-2.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEducationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Panduan Pengobatan TBC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: kMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _EduTile(
              icon: Icons.access_time_filled_rounded,
              title: 'Minum OAT Teratur Setiap Hari',
              desc: 'Jangan putus obat! Pengobatan TBC standar berlangsung 6 bulan (2 bulan Intensif HRZE + 4 bulan Lanjutan HR).',
            ),
            const SizedBox(height: 10),
            _EduTile(
              icon: Icons.masks_rounded,
              title: 'Etika Batuk & Ventilasi',
              desc: 'Gunakan masker saat batuk dan pastikan sirkulasi udara di rumah mendapat sinar matahari yang cukup.',
            ),
            const SizedBox(height: 10),
            _EduTile(
              icon: Icons.restaurant_rounded,
              title: 'Gizi & Nutrisi',
              desc: 'Konsumsi makanan tinggi protein (telur, ikan, tahu) untuk membantu pemulihan berat badan dan imunitas.',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientDashboardData?>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final treatment = data?.treatment;
        final day = treatment?.treatmentDay ?? 0;
        final totalDays = treatment?.totalDays ?? 180;
        final phase = treatment?.phase ?? 'Intensif';
        final adherence = treatment?.adherencePercent ?? 98;
        final weight = data?.weight ?? 55.0;

        return AppPage(
          onRefresh: _refresh,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Top Balance / Treatment Status Header (Reference Screen 2 Header)
            _TreatmentHeader(
              day: day,
              totalDays: totalDays,
              phase: phase,
              onNotificationsTap: widget.onOpenNotifications,
            ),
            const SizedBox(height: 24),

            // Service Row (5 Circular Pastel Buttons)
            const Text(
              'Layanan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularQuickAction(
                  label: 'Minum',
                  icon: Icons.medication_rounded,
                  bg: kPastelCyan,
                  fg: kPastelCyanFg,
                  onTap: _confirmDose,
                ),
                CircularQuickAction(
                  label: 'Gejala',
                  icon: Icons.health_and_safety_outlined,
                  bg: kPastelAmber,
                  fg: kPastelAmberFg,
                  onTap: _openSymptomCheckup,
                ),
                CircularQuickAction(
                  label: 'Tanya AI',
                  icon: Icons.smart_toy_outlined,
                  bg: kPastelPurple,
                  fg: kPastelPurpleFg,
                  onTap: _openAIChat,
                ),
                CircularQuickAction(
                  label: 'Hasil Lab',
                  icon: Icons.biotech_outlined,
                  bg: kPastelGreen,
                  fg: kPastelGreenFg,
                  onTap: _showLabSheet,
                ),
                CircularQuickAction(
                  label: 'Edukasi',
                  icon: Icons.menu_book_outlined,
                  bg: kPastelRose,
                  fg: kPastelRoseFg,
                  onTap: _showEducationSheet,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Target Terapi ("Goals" Horizontal Scroll Cards)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Target Terapi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                InkWell(
                  onTap: _showEducationSheet,
                  child: const Text(
                    'Panduan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 125,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  HorizontalGoalCard(
                    title: 'Fase Terapi',
                    subtitle: 'HRZE 4 Tablet',
                    value: 'Fase $phase',
                    icon: Icons.healing_rounded,
                    iconBg: kPastelCyan,
                    iconFg: kPastelCyanFg,
                    trendText: 'Aktif',
                  ),
                  const SizedBox(width: 12),
                  HorizontalGoalCard(
                    title: 'Kepatuhan OAT',
                    subtitle: 'Target ≥90%',
                    value: '$adherence%',
                    icon: Icons.verified_rounded,
                    iconBg: kPastelGreen,
                    iconFg: kPastelGreenFg,
                    trendText: 'Naik',
                  ),
                  const SizedBox(width: 12),
                  HorizontalGoalCard(
                    title: 'Berat Badan',
                    subtitle: 'Target: Naik',
                    value: '$weight kg',
                    icon: Icons.monitor_weight_outlined,
                    iconBg: kPastelAmber,
                    iconFg: kPastelAmberFg,
                    trendText: 'Stabil',
                  ),
                  const SizedBox(width: 12),
                  HorizontalGoalCard(
                    title: 'Hari Berturut',
                    subtitle: 'Streak Sempurna',
                    value: '${treatment?.streak ?? 1} Hari',
                    icon: Icons.local_fire_department_rounded,
                    iconBg: kPastelRose,
                    iconFg: kPastelRoseFg,
                    trendText: 'Streak',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Aktivitas Terbaru ("Received Activity" style)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Hari Ini',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                InkWell(
                  onTap: widget.onOpenNotifications,
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dose Card
            ActivityItemTile(
              title: _doseTakenToday
                  ? 'Dosis OAT Hari Ini Diminum'
                  : 'Waktunya Minum OAT (1x Sehari)',
              subtitle: _doseTakenToday
                  ? 'Tercatat di rekam medis • Hebat!'
                  : '08:00 AM • Sesudah makan pagi',
              icon: Icons.medication_rounded,
              iconBg: _doseTakenToday ? kPastelGreen : kPastelCyan,
              iconFg: _doseTakenToday ? kPastelGreenFg : kPastelCyanFg,
              trailingWidget: _doseTakenToday
                  ? const StatusPill(text: 'Selesai', bg: kPastelGreen, fg: kSuccess)
                  : (_confirmingDose
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : ElevatedButton(
                          onPressed: _confirmDose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Minum',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        )),
            ),
            const SizedBox(height: 10),

            // Symptom Checkup Tile
            ActivityItemTile(
              title: 'Checkup Gejala Mandiri',
              subtitle: 'Laporkan batuk, demam & keluhan',
              icon: Icons.health_and_safety_outlined,
              iconBg: kPastelAmber,
              iconFg: kPastelAmberFg,
              trailingWidget: TextButton(
                onPressed: _openSymptomCheckup,
                child: const Text(
                  'Cek Sekarang',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kWarning),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // AI Consultation Tile
            ActivityItemTile(
              title: 'Asisten Pintar ToolBC',
              subtitle: 'Tanya edukasi efek samping obat OAT',
              icon: Icons.smart_toy_outlined,
              iconBg: kPastelPurple,
              iconFg: kPastelPurpleFg,
              onTap: _openAIChat,
              trailingTitle: 'Aktif 24/7',
              trailingSubtitle: 'AI Assistant',
            ),
          ],
        );
      },
    );
  }
}

class _TreatmentHeader extends StatelessWidget {
  const _TreatmentHeader({
    required this.day,
    required this.totalDays,
    required this.phase,
    required this.onNotificationsTap,
  });

  final int day;
  final int totalDays;
  final String phase;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Pengobatan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: kMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day <= 0 ? 'Fase Persiapan' : 'Hari ke-$day',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: kText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'dari $totalDays Hari • Fase $phase',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kMuted,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: onNotificationsTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: kText,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EduTile extends StatelessWidget {
  const _EduTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: kText),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11.5, color: kTextSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
