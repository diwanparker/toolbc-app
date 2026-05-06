import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';

const List<_NotificationEntry> _allNotifications = [
  _NotificationEntry(
    type: _NotificationType.reminder,
    icon: Icons.check_circle_rounded,
    title: 'Morning dose completed',
    subtitle: 'Today - 08:04 WIB',
    status: 'Done',
    statusBg: Color(0xFFDDFEE3),
    statusFg: Color(0xFF15803D),
  ),
  _NotificationEntry(
    type: _NotificationType.reminder,
    icon: Icons.notifications_active_rounded,
    title: 'Evening dose reminder',
    subtitle: 'Today - 19:55 WIB',
    status: 'Pending',
    statusBg: Color(0xFFFFF3C7),
    statusFg: Color(0xFF92400E),
  ),
  _NotificationEntry(
    type: _NotificationType.alert,
    icon: Icons.info_rounded,
    title: 'Symptom log submitted',
    subtitle: 'Yesterday - low risk feedback',
    status: 'Read',
    statusBg: Color(0xFFDDFEE3),
    statusFg: Color(0xFF15803D),
  ),
];

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final items = _filter.apply(_allNotifications);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionCard(
            background: Color(0xFFFFF7ED),
            borderColor: Color(0xFFFDBA74),
            title: 'Evening medicine pending',
            trailing: StatusPill(
              text: 'Confirm',
              bg: Color(0xFFF97316),
              fg: Colors.white,
            ),
            child: Text(
              'Reminder sent 5 minutes ago.',
              style: TextStyle(fontSize: 10.5, color: kMuted),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<_NotificationFilter>(
            segments: const [
              ButtonSegment(value: _NotificationFilter.all, label: Text('All')),
              ButtonSegment(
                value: _NotificationFilter.reminders,
                label: Text('Reminders'),
              ),
              ButtonSegment(
                value: _NotificationFilter.alerts,
                label: Text('Alerts'),
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
            const SizedBox(height: 12),
          ],
          SectionCard(
            background: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            title: 'Reminder Summary',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto reminders: 6 sent this week.',
                  style: TextStyle(fontSize: 10, color: kMuted),
                ),
                SizedBox(height: 4),
                Text(
                  'Missed reminders: 1 resolved after follow-up.',
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
