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
  late Future<_ProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadData();
  }

  Future<void> _refresh() async {
    setState(() {
      _progressFuture = _loadData(forceRefresh: true);
    });
    await _progressFuture;
  }

  Future<_ProgressData> _loadData({bool forceRefresh = false}) async {
    final results = await Future.wait([
      PatientService.fetchCurrentPatientDashboard(forceRefresh: forceRefresh),
      PatientService.fetchCurrentMedicationLogs(forceRefresh: forceRefresh),
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
          onRefresh: _refresh,
          children: [
            const PageHeader(
              title: 'Riwayat & Kepatuhan 📈',
              subtitle: 'Pantau catatan minum obat harian dan riwayat laporan klinis.',
            ),
            const SizedBox(height: 16),
            _ProgressHero(treatment: treatment),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Hari Terlalui',
                    value: '${treatment?.treatmentDay ?? 0}',
                    icon: Icons.calendar_today_rounded,
                    tint: kSoftBlue,
                    accent: kPrimary,
                    subtitle: 'Fase pengobatan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Skor Kepatuhan',
                    value: treatment != null ? '${treatment.adherencePercent}%' : '0%',
                    icon: Icons.verified_rounded,
                    tint: kSoftGreen,
                    accent: kSuccess,
                    subtitle: 'Rasio minum teratur',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan Log Obat & Checkup',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              const EmptyStateCard(
                title: 'Belum ada catatan log',
                message:
                    'Riwayat dosis obat dan checkup mandiri Anda akan otomatis tercatat di sini.',
                icon: Icons.history_rounded,
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
                const SizedBox(height: 10),
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
    final adherence = treatment?.adherencePercent ?? 0;
    final day = treatment?.treatmentDay ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: kHeroShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Performa Kepatuhan Terapi',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (treatment != null) ...[
                      const SizedBox(width: 8),
                      StatusPill(
                        text: treatment!.phase.toLowerCase() == 'completed' ? 'Selesai' : 'Fase ${treatment!.phase}',
                        bg: Colors.white.withValues(alpha: 0.18),
                        fg: Colors.white,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$adherence%',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treatment == null
                      ? 'Rencana pengobatan belum diatur.'
                      : (day <= 0
                          ? 'Memulai hari pertama pengobatan'
                          : 'Telah menjalani $day hari pengobatan rutin'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD1FAE5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Waktu belum tersedia';
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} • ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} WIB';
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
      return kSoftAmber;
    default:
      return kSoftBlue;
  }
}

Color _logColor(String status) {
  switch (status.toLowerCase()) {
    case 'taken':
    case 'completed':
      return kSuccess;
    case 'missed':
      return kWarning;
    default:
      return kPrimary;
  }
}
