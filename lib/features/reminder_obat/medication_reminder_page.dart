part of flutter_tbc;

class MedicationReminderPage extends StatelessWidget {
  const MedicationReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        title: const Text('Medication Reminder', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: 'Next dose',
            trailing: const _StatusPill(text: 'Pending', bg: Color(0xFFFFF7ED), fg: Color(0xFF92400E)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _TimeBadge(time: '20:00 WIB'),
                    SizedBox(width: 12),
                    Expanded(child: Text('Rifampicin + Isoniazid • after meal', style: TextStyle(fontSize: 10.5, color: kMuted))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _ActionChip(label: 'Taken', filled: true, fillColor: Color(0xFF22C55E), fg: Colors.white)),
                    SizedBox(width: 10),
                    Expanded(child: _ActionChip(label: 'Snooze', filled: false, fillColor: kSoftBlue, fg: kPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Schedule summary',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Morning dose: done', style: TextStyle(fontSize: 10.5, color: kMuted)),
                SizedBox(height: 4),
                Text('Evening dose: pending', style: TextStyle(fontSize: 10.5, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
