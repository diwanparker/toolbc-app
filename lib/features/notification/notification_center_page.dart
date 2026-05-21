import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/app_mode.dart';
import '../../core/widgets/ui_components.dart';

const List<_NotificationEntry> _patientNotifications = [
  _NotificationEntry(
    type: _NotificationType.reminder,
    icon: Icons.check_circle_rounded,
    title: 'Obat pagi sudah diminum',
    subtitle: 'Hari ini - 07:04 WIB',
    status: 'Selesai',
    statusBg: Color(0xFFDDFEE3),
    statusFg: Color(0xFF15803D),
  ),
  _NotificationEntry(
    type: _NotificationType.reminder,
    icon: Icons.notifications_active_rounded,
    title: 'Pengingat dosis pagi',
    subtitle: 'Hari ini - 06:55 WIB',
    status: 'Menunggu',
    statusBg: Color(0xFFFFF3C7),
    statusFg: Color(0xFF92400E),
  ),
  _NotificationEntry(
    type: _NotificationType.alert,
    icon: Icons.info_rounded,
    title: 'Jadwal tes dahak bulan ke-2',
    subtitle: 'Minggu depan - Evaluasi fase intensif',
    status: 'Info',
    statusBg: Color(0xFFDDFEE3),
    statusFg: Color(0xFF15803D),
  ),
];

const List<_NotificationEntry> _doctorNotifications = [
  _NotificationEntry(
    type: _NotificationType.alert,
    icon: Icons.warning_rounded,
    title: 'Eskalasi: Pasien Davina',
    subtitle: 'Melewatkan dosis pagi > 2 jam',
    status: 'Tindak Lanjut',
    statusBg: Color(0xFFFEE2E2),
    statusFg: Color(0xFFB91C1C),
  ),
  _NotificationEntry(
    type: _NotificationType.reminder,
    icon: Icons.info_rounded,
    title: 'Jadwal Tes Dahak',
    subtitle: 'Pasien Nadia (Bulan ke-2) minggu depan',
    status: 'Info',
    statusBg: Color(0xFFE0F2FE),
    statusFg: Color(0xFF0369A1),
  ),
];

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key, required this.mode});

  final AppMode mode;

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  _NotificationFilter _filter = _NotificationFilter.all;
  late final List<_NotificationEntry> _allNotifications;

  @override
  void initState() {
    super.initState();
    _allNotifications = widget.mode == AppMode.doctor
        ? _doctorNotifications
        : _patientNotifications;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filter.apply(_allNotifications);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.mode == AppMode.doctor)
            const SectionCard(
              background: Color(0xFFFEF2F2),
              borderColor: Color(0xFFFCA5A5),
              title: 'Peringatan Kritis: Pasien Davina',
              trailing: StatusPill(
                text: 'Mendesak',
                bg: Color(0xFFEF4444),
                fg: Colors.white,
              ),
              child: Text(
                'Melewatkan dosis pagi > 2 jam. Tindak lanjut segera direkomendasikan.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            )
          else
            const SectionCard(
              background: Color(0xFFFFF7ED),
              borderColor: Color(0xFFFDBA74),
              title: 'Obat pagi belum diminum',
              trailing: StatusPill(
                text: 'Konfirmasi',
                bg: Color(0xFFF97316),
                fg: Colors.white,
              ),
              child: Text(
                'Pengingat dikirim 5 menit yang lalu.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ),
          const SizedBox(height: 16),
          SegmentedButton<_NotificationFilter>(
            segments: const [
              ButtonSegment(value: _NotificationFilter.all, label: Text('Semua')),
              ButtonSegment(
                value: _NotificationFilter.reminders,
                label: Text('Pengingat'),
              ),
              ButtonSegment(
                value: _NotificationFilter.alerts,
                label: Text('Peringatan'),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (values) =>
                setState(() => _filter = values.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          for (final item in items) ...[
            NotificationCard(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              status: item.status,
              statusBg: item.statusBg,
              statusFg: item.statusFg,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.mode == AppMode.doctor)
            const SectionCard(
              background: Color(0xFFF8FAFC),
              borderColor: Color(0xFFE2E8F0),
              title: 'Ringkasan Eskalasi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peringatan aktif: 3 butuh konfirmasi.',
                    style: TextStyle(fontSize: 10, color: kMuted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Peringatan diselesaikan: 5 minggu ini.',
                    style: TextStyle(fontSize: 10, color: kMuted),
                  ),
                ],
              ),
            )
          else
            const SectionCard(
              background: Color(0xFFF8FAFC),
              borderColor: Color(0xFFE2E8F0),
              title: 'Ringkasan Pengingat',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengingat otomatis: 6 terkirim minggu ini.',
                    style: TextStyle(fontSize: 10, color: kMuted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pengingat terlewat: 1 diselesaikan setelah tindak lanjut.',
                    style: TextStyle(fontSize: 10, color: kMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _NotificationFilter { all, reminders, alerts }

enum _NotificationType { reminder, alert }

class _NotificationEntry {
  const _NotificationEntry({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusBg,
    required this.statusFg,
  });

  final _NotificationType type;
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusBg;
  final Color statusFg;
}

extension on _NotificationFilter {
  List<_NotificationEntry> apply(List<_NotificationEntry> source) {
    switch (this) {
      case _NotificationFilter.all:
        return source;
      case _NotificationFilter.reminders:
        return source
            .where((entry) => entry.type == _NotificationType.reminder)
            .toList(growable: false);
      case _NotificationFilter.alerts:
        return source
            .where((entry) => entry.type == _NotificationType.alert)
            .toList(growable: false);
    }
  }
}
