part of flutter_tbc;

class PatientChatPage extends StatelessWidget {
  const PatientChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chat Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('Ask your doctor or AI assistant for help.', style: TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 16),
          _SectionCard(
            background: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            title: 'Dr. Arya is available',
            trailing: const _StatusPill(text: 'Dr', bg: Color(0xFF22C55E), fg: Colors.white),
            child: const Text('Usually replies within 15 minutes.', style: TextStyle(fontSize: 9.5, color: kMuted)),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Messages',
            child: Column(
              children: const [
                _ChatBubble(text: 'Hi Davina, have you taken your evening medicine?', incoming: true),
                SizedBox(height: 10),
                _ChatBubble(text: 'Not yet, I will take it after dinner.', incoming: false),
                SizedBox(height: 10),
                _ChatBubble(text: 'Great. Please confirm once done. If fever continues, log symptoms through Checkup.', incoming: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Quick Actions',
            child: Row(
              children: const [
                Expanded(child: _ActionChip(label: 'Taken now', filled: false, fillColor: kSoftGreen, fg: Color(0xFF15803D))),
                SizedBox(width: 10),
                Expanded(child: _ActionChip(label: 'Need help', filled: false, fillColor: kSoftBlue, fg: kPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            background: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE5E7EB),
            child: Row(
              children: [
                const Expanded(child: Text('Type message...', style: TextStyle(fontSize: 11, color: kMuted))),
                Container(width: 36, height: 36, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
