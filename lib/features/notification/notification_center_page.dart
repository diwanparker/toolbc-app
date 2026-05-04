part of flutter_tbc;

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionCard(
            background: Color(0xFFFFF7ED),
            borderColor: Color(0xFFFDBA74),
            title: 'Evening medicine pending',
            trailing: _StatusPill(text: 'Confirm', bg: Color(0xFFF97316), fg: Colors.white),
            child: Text('Reminder sent 5 minutes ago.', style: TextStyle(fontSize: 10.5, color: kMuted)),
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('All')),
              ButtonSegment(value: 1, label: Text('Reminders')),
              ButtonSegment(value: 2, label: Text('Alerts')),
            ],
            selected: {_filter},
            onSelectionChanged: (values) => setState(() => _filter = values.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          const _NotificationCard(icon: Icons.check_circle_rounded, title: 'Morning dose completed', subtitle: 'Today • 08:04 WIB', status: 'Done', statusBg: Color(0xFFDDFEE3), statusFg: Color(0xFF15803D)),
          const SizedBox(height: 12),
          const _NotificationCard(icon: Icons.notifications_active_rounded, title: 'Evening dose reminder', subtitle: 'Today • 19:55 WIB', status: 'Pending', statusBg: Color(0xFFFFF3C7), statusFg: Color(0xFF92400E)),
          const SizedBox(height: 12),
          const _NotificationCard(icon: Icons.info_rounded, title: 'Symptom log submitted', subtitle: 'Yesterday • low risk feedback', status: 'Read', statusBg: Color(0xFFDDFEE3), statusFg: Color(0xFF15803D)),
          const SizedBox(height: 16),
          _SectionCard(
            background: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            title: 'Reminder Summary',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto reminders: 6 sent this week.', style: TextStyle(fontSize: 10, color: kMuted)),
                SizedBox(height: 4),
                Text('Missed reminders: 1 resolved after follow-up.', style: TextStyle(fontSize: 10, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
