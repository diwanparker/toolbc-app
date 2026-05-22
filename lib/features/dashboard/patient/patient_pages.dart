import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/patient_data.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late final Future<PatientDashboardData?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = PatientService.fetchCurrentPatientDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientDashboardData?>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final profile = data?.profile;
        final patient = data?.patient;
        final firstName = profile?.displayName.split(' ').first ?? 'Pasien';

        return AppPage(
          children: [
            PageHeader(
              title: 'Halo, $firstName',
              subtitle: patient == null
                  ? 'Data pengobatan kamu belum diatur oleh admin.'
                  : 'Tetap konsisten mengikuti rencana pengobatan.',
            ),
            const SizedBox(height: 18),
            _TreatmentSummaryCard(patient: patient),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Adherence',
                    value: patient?.adherenceLabel ?? '0%',
                    icon: Icons.check_circle_outline_rounded,
                    tint: const Color(0xFFD4F7DD),
                    accent: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Hari Pengobatan',
                    value: '${patient?.treatmentDay ?? 0}',
                    icon: Icons.timeline_rounded,
                    tint: const Color(0xFFEFF6FF),
                    accent: kPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Pengingat Obat',
              trailing: StatusPill(
                text: patient == null ? 'Belum aktif' : 'Aktif',
                bg: patient == null
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFDDF7E0),
                fg: patient == null
                    ? const Color(0xFF475569)
                    : const Color(0xFF15803D),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient == null
                        ? 'Admin atau dokter perlu melengkapi data rencana pengobatan terlebih dahulu.'
                        : 'Ikuti jadwal obat yang sudah ditentukan oleh dokter penanggung jawab.',
                    style: const TextStyle(fontSize: 10.5, color: kMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: AppActionChip(
                          label: 'Sudah diminum',
                          filled: true,
                          fillColor: Color(0xFF22C55E),
                          fg: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppActionChip(
                          label: 'Ingatkan nanti',
                          filled: false,
                          fillColor: kSoftBlue,
                          fg: kPrimary,
                          onTap: widget.onOpenNotifications,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Checklist Harian',
              child: ChecklistTile(
                label: patient == null
                    ? 'Data checklist belum tersedia'
                    : 'Minum obat sesuai jadwal',
                active: false,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Quick Support',
              child: Row(
                children: const [
                  Expanded(
                    child: AppActionChip(
                      label: 'Tanya AI',
                      filled: false,
                      fillColor: kSoftBlue,
                      fg: kPrimary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AppActionChip(
                      label: 'Hubungi dokter',
                      filled: false,
                      fillColor: kSoftBlue,
                      fg: kPrimary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AppActionChip(
                      label: 'Kirim laporan',
                      filled: false,
                      fillColor: kSoftBlue,
                      fg: kPrimary,
                    ),
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

class _TreatmentSummaryCard extends StatelessWidget {
  const _TreatmentSummaryCard({required this.patient});

  final PatientSummary? patient;

  @override
  Widget build(BuildContext context) {
    final progress = ((patient?.treatmentDay ?? 0) / 180).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331D4ED8),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient?.treatmentLabel ?? 'Rencana pengobatan belum ada',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDBEAFE),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient == null
                        ? 'Menunggu data'
                        : 'Day ${patient!.treatmentDay}',
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    patient == null
                        ? 'Hubungi admin bila data belum muncul.'
                        : '${(progress * 100).round()}% estimasi selesai.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFDBEAFE),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 96,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medication_liquid_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    patient?.riskLabel ?? 'Belum aktif',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
