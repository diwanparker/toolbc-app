import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/patient_data.dart';
import '../../core/services/patient_service.dart';
import '../../core/widgets/ui_components.dart';

class PatientProgressPage extends StatefulWidget {
  const PatientProgressPage({super.key});

  @override
  State<PatientProgressPage> createState() => _PatientProgressPageState();
}

class _PatientProgressPageState extends State<PatientProgressPage> {
  late final Future<_ProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadData();
  }

  Future<_ProgressData> _loadData() async {
    final results = await Future.wait([
      PatientService.fetchCurrentPatientDashboard(),
      PatientService.fetchCurrentMedicationLogs(),
    ]);
    return _ProgressData(
      dashboard: results[0] as PatientDashboardData?,
      logs: results[1] as List<MedicationLogEntry>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProgressData>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final dashboard = snapshot.data?.dashboard;
        final treatment = dashboard?.treatment;
        final logs = snapshot.data?.logs ?? const <MedicationLogEntry>[];

        return AppPage(
          children: [
            const PageHeader(
              title: 'Riwayat Pengobatan',
              subtitle: 'Pantau timeline pengobatan dan kepatuhan.',
            ),
            const SizedBox(height: 16),
            _ProgressHero(treatment: treatment),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Hari pengobatan',
                    value: '${treatment?.treatmentDay ?? 0}',
                    icon: Icons.timeline_rounded,
                    tint: kSurface,
                    accent: kPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Kepatuhan',
                    value: treatment != null ? '${treatment.adherencePercent}%' : '0%',
                    icon: Icons.check_circle_outline_rounded,
                    tint: kSurface,
                    accent: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Riwayat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada riwayat',
                message:
                    'Catatan obat dan checkup akan muncul setelah pasien mengirim laporan.',
              )
            else
              for (final log in logs) ...[
                HistoryLogCard(
                  title: log.title,
                  subtitle: _formatDate(log.createdAt),
                  leading: _logIcon(log.status),
                  tint: _logTint(log.status),
                  fg: _logColor(log.status),
                ),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

class _ProgressData {
  const _ProgressData({required this.dashboard, required this.logs});

  final PatientDashboardData? dashboard;
  final List<MedicationLogEntry> logs;
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.treatment});

  final TreatmentSummary? treatment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Kepatuhan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDDFEE3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  treatment != null ? '${treatment!.adherencePercent}%' : '0%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treatment == null ? 'Data pengobatan belum tersedia.' : (treatment!.treatmentDay <= 0 ? 'Hari pengobatan belum diatur' : 'Hari ke-${treatment!.treatmentDay}'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFDDFEE3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Waktu belum tersedia';
  return '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

IconData _logIcon(String status) {
  switch (status.toLowerCase()) {
    case 'taken':
    case 'completed':
      return Icons.check_circle_rounded;
    case 'missed':
      return Icons.warning_rounded;
    default:
      return Icons.info_rounded;
  }
}

Color _logTint(String status) {
  switch (status.toLowerCase()) {
    case 'taken':
    case 'completed':
      return kSoftGreen;
    case 'missed':
      return const Color(0xFFFFF7ED);
    default:
      return kSoftBlue;
  }
}

Color _logColor(String status) {
  switch (status.toLowerCase()) {
    case 'taken':
    case 'completed':
      return const Color(0xFF16A34A);
    case 'missed':
      return const Color(0xFFF97316);
    default:
      return kPrimary;
  }
}
