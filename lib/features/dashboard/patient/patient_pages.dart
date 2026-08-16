import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/patient_data.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientDashboardData?>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final profile = data?.profile;
        final treatment = data?.treatment;
        final firstName = profile?.displayName.split(' ').first ?? 'Pasien';

        return AppPage(
          onRefresh: _refresh,
          children: [
            PageHeader(
              title: 'Halo, $firstName 👋',
              subtitle: treatment == null
                  ? 'Data rencana pengobatan sedang disiapkan oleh tim medis.'
                  : 'Fokus kepatuhan obat dan pemulihan kesehatan hari ini.',
            ),
            const SizedBox(height: 16),
            _TreatmentHeroCard(treatment: treatment, weight: data?.weight),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Kepatuhan Minum',
                    value: treatment != null ? '${treatment.adherencePercent}%' : '0%',
                    icon: Icons.verified_rounded,
                    tint: kSoftGreen,
                    accent: kSuccess,
                    subtitle: 'Target kepatuhan ≥90%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Hari Pengobatan',
                    value: '${treatment?.treatmentDay ?? 0}',
                    icon: Icons.calendar_month_rounded,
                    tint: kSoftBlue,
                    accent: kPrimary,
                    subtitle: 'Dari total fase terapi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Jadwal Obat Hari Ini',
              trailing: StatusPill(
                text: _doseTakenToday
                    ? 'Selesai'
                    : (treatment == null ? 'Menunggu' : 'Waktunya Minum'),
                bg: _doseTakenToday ? kSoftGreen : kSoftAmber,
                fg: _doseTakenToday ? kSuccess : kWarning,
                icon: _doseTakenToday
                    ? Icons.check_circle_rounded
                    : Icons.access_time_filled_rounded,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kombinasi Dosis Tetap (OAT KDT) - 1x sehari sesudah makan.',
                    style: TextStyle(fontSize: 12.5, color: kTextSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  if (_doseTakenToday)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSoftGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorderGreen),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: kSuccess, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hebat! Anda sudah minum obat hari ini.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _confirmingDose
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.4),
                                  ),
                                )
                              : InkWell(
                                  onTap: _confirmDose,
                                  borderRadius: BorderRadius.circular(12),
                                  child: const PrimaryBannerButton(
                                    label: 'Sudah Minum Obat',
                                    icon: Icons.check_rounded,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: widget.onOpenNotifications,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_active_outlined,
                                color: kPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Layanan Cepat',
              child: Column(
                children: [
                  AccountRowTile(
                    title: 'Checkup Gejala Harian',
                    subtitle: 'Laporkan batuk, demam, atau keluhan lainnya.',
                    icon: Icons.health_and_safety_outlined,
                    onTap: _openSymptomCheckup,
                  ),
                  const SizedBox(height: 10),
                  AccountRowTile(
                    title: 'Pengingat & Notifikasi',
                    subtitle: 'Lihat daftar pengingat minum obat dan jadwal kontrol.',
                    icon: Icons.notifications_none_rounded,
                    onTap: widget.onOpenNotifications,
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

class _TreatmentHeroCard extends StatelessWidget {
  const _TreatmentHeroCard({required this.treatment, this.weight});

  final TreatmentSummary? treatment;
  final double? weight;

  @override
  Widget build(BuildContext context) {
    final day = treatment?.treatmentDay ?? 0;
    final percent = treatment?.completionPercent ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryGradientStart, kPrimary, kPrimaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: kHeroShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  StatusPill(
                    text: treatment != null ? (treatment!.phase.toLowerCase() == 'completed' ? 'Selesai' : 'Fase ${treatment!.phase}') : 'Fase Pengobatan TBC',
                    bg: Colors.white.withValues(alpha: 0.18),
                    fg: Colors.white,
                  ),
                  if (weight != null) ...[
                    const SizedBox(width: 8),
                    StatusPill(
                      text: '$weight kg',
                      bg: Colors.white.withValues(alpha: 0.18),
                      fg: Colors.white,
                      icon: Icons.monitor_weight_outlined,
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percent% Selesai',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day <= 0 ? 'Fase Awal' : 'Hari ke-$day',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      treatment == null
                          ? 'Menunggu sinkronisasi data rekam medis.'
                          : (treatment!.medicineSummary.isNotEmpty 
                              ? 'Obat: ${treatment!.medicineSummary}\nTerus pertahankan kepatuhan hingga tuntas sembuh.'
                              : 'Terus pertahankan kepatuhan hingga tuntas sembuh.'),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent > 0 ? (percent / 100.0).clamp(0.0, 1.0) : 0.05,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
