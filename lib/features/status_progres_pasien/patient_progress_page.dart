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
  String _selectedFilter = 'Semua';

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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  'Filter Riwayat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: kMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Semua', 'Minum Obat', 'Checkup Gejala', 'Hasil Lab'].map((filter) {
                final selected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  selectedColor: kPastelCyan,
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? kPrimary : const Color(0xFFE2E8F0),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? kPrimaryDark : kTextSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedFilter = filter);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat & Statistik',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: kText,
                  ),
                ),
                InkWell(
                  onTap: _showFilterModal,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: kText,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Performance Summary (Two Side-by-Side Cards)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kepatuhan Terapi',
                          style: TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${treatment?.adherencePercent ?? 98}%',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kSuccess),
                        ),
                        const SizedBox(height: 2),
                        const Text('Kondisi Sangat Baik', style: TextStyle(fontSize: 11, color: kMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder),
                      boxShadow: kCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hari Pengobatan',
                          style: TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${treatment?.treatmentDay ?? 0}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text('Fase ${treatment?.phase ?? "Intensif"}', style: const TextStyle(fontSize: 11, color: kMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Group 1: Hari Ini
            const _DateGroupHeader(title: 'Hari Ini, 16 Agustus 2026'),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Minum OAT KDT (HRZE)',
              subtitle: '08:15 AM • Tepat Waktu',
              icon: Icons.medication_rounded,
              iconBg: kPastelGreen,
              iconFg: kSuccess,
              trailingTitle: 'Diminum',
              trailingSubtitle: '100% Kepatuhan',
            ),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Checkup Gejala Mandiri',
              subtitle: '09:30 AM • Laporan Triase',
              icon: Icons.health_and_safety_outlined,
              iconBg: kPastelAmber,
              iconFg: kWarning,
              trailingTitle: 'Risiko Rendah',
              trailingSubtitle: 'Aman',
            ),
            const SizedBox(height: 22),

            // Date Group 2: Kemarin
            const _DateGroupHeader(title: 'Kemarin, 15 Agustus 2026'),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Minum OAT KDT (HRZE)',
              subtitle: '08:00 AM • Tepat Waktu',
              icon: Icons.medication_rounded,
              iconBg: kPastelGreen,
              iconFg: kSuccess,
              trailingTitle: 'Diminum',
              trailingSubtitle: '100% Kepatuhan',
            ),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Konsultasi Tanya AI',
              subtitle: '02:15 PM • Efek Samping Ringan',
              icon: Icons.smart_toy_outlined,
              iconBg: kPastelPurple,
              iconFg: kPastelPurpleFg,
              trailingTitle: 'Terjawab',
              trailingSubtitle: 'Edukasi OAT',
            ),
            const SizedBox(height: 22),

            // Date Group 3: 14 Agustus
            const _DateGroupHeader(title: '14 Agustus 2026'),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Pemeriksaan TCM Dahak',
              subtitle: '10:00 AM • RSUD / Puskesmas',
              icon: Icons.biotech_rounded,
              iconBg: kPastelCyan,
              iconFg: kPrimaryDark,
              trailingTitle: 'Hasil Tercatat',
              trailingSubtitle: 'Sensitif RIF',
            ),
            const SizedBox(height: 10),
            const ActivityItemTile(
              title: 'Minum OAT KDT (HRZE)',
              subtitle: '08:30 AM • Tepat Waktu',
              icon: Icons.medication_rounded,
              iconBg: kPastelGreen,
              iconFg: kSuccess,
              trailingTitle: 'Diminum',
              trailingSubtitle: '100% Kepatuhan',
            ),

            if (logs.isNotEmpty) ...[
              const SizedBox(height: 22),
              const _DateGroupHeader(title: 'Riwayat Sebelumnya'),
              const SizedBox(height: 10),
              for (final log in logs.take(6)) ...[
                ActivityItemTile(
                  title: log.title,
                  subtitle: _formatDate(log.createdAt),
                  icon: _logIcon(log.status),
                  iconBg: _logTint(log.status),
                  iconFg: _logColor(log.status),
                  trailingTitle: log.status,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kTextSecondary,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down_rounded, color: kMuted, size: 18),
      ],
    );
  }
}

class _ProgressData {
  const _ProgressData({required this.dashboard, required this.logs});

  final PatientDashboardData? dashboard;
  final List<MedicationLogEntry> logs;
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
      return kPastelGreen;
    case 'missed':
      return kPastelAmber;
    default:
      return kPastelCyan;
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
