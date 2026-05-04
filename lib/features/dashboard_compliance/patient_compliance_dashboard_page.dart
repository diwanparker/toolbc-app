part of flutter_tbc;

class PatientComplianceDashboardPage extends StatelessWidget {
  const PatientComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Checkup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('Log your condition and get supportive feedback.', style: TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 16),
          _SectionCard(
            background: kSoftBlue,
            borderColor: const Color(0xFFBFDBFE),
            title: 'Today\'s symptom log',
            trailing: const _StatusPill(text: 'i', bg: kPrimary, fg: Colors.white),
            child: const Text('Select symptoms you feel today before analysis.', style: TextStyle(fontSize: 9.8, color: kMuted)),
          ),
          const SizedBox(height: 16),
          const Text('Symptom Checker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 12),
          const _SymptomTile(label: 'Persistent cough', icon: Icons.air_rounded, tint: kSoftRed, selected: true, onToggle: _noop),
          const SizedBox(height: 12),
          const _SymptomTile(label: 'Fever / chills', icon: Icons.thermostat_rounded, tint: kSoftAmber, selected: true, onToggle: _noop),
          const SizedBox(height: 12),
          const _SymptomTile(label: 'Night sweats', icon: Icons.nightlight_round, tint: kSoftBlue, selected: false, onToggle: _noop),
          const SizedBox(height: 12),
          const _SymptomTile(label: 'Weight loss / low appetite', icon: Icons.restaurant_rounded, tint: Color(0xFFF0FDF4), selected: false, onToggle: _noop),
          const SizedBox(height: 6),
          const _PrimaryBannerButton(label: 'Analyze Symptoms'),
          const SizedBox(height: 16),
          _SectionCard(
            background: const Color(0xFFFFF7ED),
            borderColor: const Color(0xFFFDBA74),
            title: 'Moderate Risk Feedback',
            trailing: const _StatusPill(text: '!', bg: Color(0xFFF97316), fg: Colors.white),
            child: const Text('Please keep taking medicine and report persistent fever to your doctor.', style: TextStyle(fontSize: 10.5, color: kMuted)),
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}
