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
  late Future<List<NotificationEntryData>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = PatientService.fetchCurrentNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _notificationsFuture =
          PatientService.fetchCurrentNotifications(forceRefresh: true);
    });
    await _notificationsFuture;
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
            leading: const BackButton(color: kText),
            title: const Text(
              'Pusat Notifikasi 🔔',
              style: TextStyle(fontWeight: FontWeight.w800, color: kText),
            ),
          ),
          body: RefreshIndicator(
            color: kPrimary,
            backgroundColor: Colors.white,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                SectionCard(
                  background: unread > 0 ? kSoftAmber : kSurface,
                  borderColor: unread > 0 ? kBorderAmber : kBorder,
                  title: widget.mode == AppMode.doctor
                      ? 'Ringkasan Antrian Dokter'
                      : 'Ringkasan Pengingat Pasien',
                  trailing: StatusPill(
                    text: '$unread Baru',
                    bg: unread > 0 ? kWarning : const Color(0xFF64748B),
                    fg: Colors.white,
                  ),
                  child: Text(
                    unread > 0
                        ? '$unread notifikasi memerlukan perhatian Anda.'
                        : 'Semua jadwal dan pengingat sudah tertangani dengan baik.',
                    style: const TextStyle(fontSize: 12, color: kTextSecondary, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<_NotificationFilter>(
                  segments: const [
                    ButtonSegment(
                      value: _NotificationFilter.all,
                      label: Text('Semua', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    ButtonSegment(
                      value: _NotificationFilter.reminders,
                      label: Text('Pengingat', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    ButtonSegment(
                      value: _NotificationFilter.alerts,
                      label: Text('Peringatan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (values) =>
                      setState(() => _filter = values.first),
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return kSoftBlue;
                      }
                      return Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return kPrimary;
                      }
                      return kMuted;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const EmptyStateCard(
                    title: 'Belum ada notifikasi',
                    message:
                        'Pengingat minum obat, jadwal kontrol, dan peringatan klinis akan tampil di sini.',
                    icon: Icons.notifications_none_rounded,
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
                    const SizedBox(height: 12),
                  ],
              ],
            ),
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
      return kSoftRed;
    case 'moderate':
    case 'medium':
      return kSoftAmber;
    default:
      return kSoftBlue;
  }
}

Color _statusFg(NotificationEntryData item) {
  switch (item.severity.toLowerCase()) {
    case 'high':
    case 'critical':
      return kDanger;
    case 'moderate':
    case 'medium':
      return kWarning;
    default:
      return kPrimary;
  }
}
