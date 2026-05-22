import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/app_mode.dart';
import '../../core/models/patient_data.dart';
import '../../core/services/patient_service.dart';
import '../../core/widgets/ui_components.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key, required this.mode});

  final AppMode mode;

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  _NotificationFilter _filter = _NotificationFilter.all;
  late final Future<List<NotificationEntryData>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = PatientService.fetchCurrentNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationEntryData>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        final allNotifications =
            snapshot.data ?? const <NotificationEntryData>[];
        final items = _filter.apply(allNotifications);
        final unread = allNotifications.where((item) => !item.isRead).length;

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
              SectionCard(
                background: unread > 0
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFF8FAFC),
                borderColor: unread > 0
                    ? const Color(0xFFFDBA74)
                    : const Color(0xFFE2E8F0),
                title: widget.mode == AppMode.doctor
                    ? 'Ringkasan Eskalasi'
                    : 'Ringkasan Pengingat',
                trailing: StatusPill(
                  text: '$unread Baru',
                  bg: unread > 0
                      ? const Color(0xFFF97316)
                      : const Color(0xFF64748B),
                  fg: Colors.white,
                ),
                child: Text(
                  unread > 0
                      ? '$unread notifikasi belum dibaca.'
                      : 'Tidak ada notifikasi aktif saat ini.',
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<_NotificationFilter>(
                segments: const [
                  ButtonSegment(
                    value: _NotificationFilter.all,
                    label: Text('Semua'),
                  ),
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
              if (items.isEmpty)
                const EmptyStateCard(
                  title: 'Belum ada notifikasi',
                  message:
                      'Notifikasi dari Supabase akan muncul sesuai akun yang sedang login.',
                )
              else
                for (final item in items) ...[
                  NotificationCard(
                    icon: _iconFor(item),
                    title: item.title,
                    subtitle: item.body,
                    status: item.status,
                    statusBg: _statusBg(item),
                    statusFg: _statusFg(item),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        );
      },
    );
  }
}

enum _NotificationFilter { all, reminders, alerts }

extension on _NotificationFilter {
  List<NotificationEntryData> apply(List<NotificationEntryData> source) {
    switch (this) {
      case _NotificationFilter.all:
        return source;
      case _NotificationFilter.reminders:
        return source
            .where((entry) => entry.type.toLowerCase() == 'reminder')
            .toList(growable: false);
      case _NotificationFilter.alerts:
        return source
            .where((entry) => entry.type.toLowerCase() == 'alert')
            .toList(growable: false);
    }
  }
}

IconData _iconFor(NotificationEntryData item) {
  switch (item.type.toLowerCase()) {
    case 'alert':
      return Icons.warning_rounded;
    case 'reminder':
      return Icons.notifications_active_rounded;
    default:
      return Icons.info_rounded;
  }
}

Color _statusBg(NotificationEntryData item) {
  switch (item.severity.toLowerCase()) {
    case 'high':
    case 'critical':
      return const Color(0xFFFEE2E2);
    case 'moderate':
    case 'medium':
      return const Color(0xFFFFF3C7);
    default:
      return const Color(0xFFE0F2FE);
  }
}

Color _statusFg(NotificationEntryData item) {
  switch (item.severity.toLowerCase()) {
    case 'high':
    case 'critical':
      return const Color(0xFFB91C1C);
    case 'moderate':
    case 'medium':
      return const Color(0xFF92400E);
    default:
      return const Color(0xFF0369A1);
  }
}
