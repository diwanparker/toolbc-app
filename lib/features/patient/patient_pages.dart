part of flutter_tbc;

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Good morning, Davina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('You are doing well. Keep your treatment on track.', style: TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x331D4ED8), blurRadius: 24, offset: Offset(0, 14))],
            ),
            child: Stack(
              children: [
                Positioned(right: -18, top: -18, child: _orb(108, Colors.white.withValues(alpha: 0.11))),
                Positioned(right: 10, bottom: -24, child: _orb(88, Colors.white.withValues(alpha: 0.06))),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Treatment Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFDBEAFE))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Day 24', style: TextStyle(fontSize: 30, height: 1.05, fontWeight: FontWeight.w700, color: Colors.white)),
                                SizedBox(height: 6),
                                Text('60% completed • stay consistent', style: TextStyle(fontSize: 11, color: Color(0xFFDBEAFE))),
                              ],
                            ),
                          ),
                          Container(
                            width: 96,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                                SizedBox(height: 6),
                                Text('Streak 7 days', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _MetricCard(label: 'Adherence', value: '86%', icon: Icons.check_circle_outline_rounded, tint: Color(0xFFD4F7DD), accent: Color(0xFF16A34A))),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Next Checkup', value: 'Fri 09:30', icon: Icons.calendar_month_rounded, tint: Color(0xFFEFF6FF), accent: kPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Medication Reminder',
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
                  children: [
                    Expanded(child: _ActionChip(label: 'I have taken it', filled: true, fillColor: Color(0xFF22C55E), fg: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionChip(label: 'Remind me later', filled: false, fillColor: kSoftBlue, fg: kPrimary, onTap: onOpenNotifications)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Reminder Status',
            trailing: const _StatusPill(text: 'Active', bg: Color(0xFFDDF7E0), fg: Color(0xFF15803D)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto reminder sent 5 min ago.', style: TextStyle(fontSize: 10.5, color: kMuted)),
                SizedBox(height: 4),
                Text('Next reminder in 10 minutes if not confirmed.', style: TextStyle(fontSize: 10.5, color: kMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Daily Checklist',
            child: Row(
              children: const [
                Expanded(child: _ChecklistTile(label: 'Take medicine', active: false)),
                SizedBox(width: 10),
                Expanded(child: _ChecklistTile(label: 'Log symptoms', active: true)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Quick Support',
            child: Row(
              children: [
                Expanded(child: _ActionChip(label: 'Ask AI', filled: false, fillColor: kSoftBlue, fg: kPrimary, onTap: onOpenNotifications)),
                const SizedBox(width: 10),
                const Expanded(child: _ActionChip(label: 'Call doctor', filled: false, fillColor: kSoftBlue, fg: kPrimary)),
                const SizedBox(width: 10),
                const Expanded(child: _ActionChip(label: 'Send report', filled: false, fillColor: kSoftBlue, fg: kPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
