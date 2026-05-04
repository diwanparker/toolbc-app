part of flutter_tbc;

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _SectionCard(
            title: 'Onboarding',
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('First-run education and setup live here.', style: TextStyle(fontSize: 12, color: kMuted)),
                SizedBox(height: 12),
                _StatusPill(text: 'Scaffold', bg: kSoftGreen, fg: Color(0xFF15803D)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
