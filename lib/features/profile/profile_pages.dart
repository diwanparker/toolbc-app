part of flutter_tbc;

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('Patient details, treatment plan, and settings.', style: TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              children: [
                const SizedBox(height: 4),
                const CircleAvatar(radius: 34, backgroundColor: Color(0xFFF8B4C8), child: Text('D', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white))),
                const SizedBox(height: 12),
                const Text('Davina Karambol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 4),
                const Text('TBC Recovery Patient', style: TextStyle(fontSize: 11, color: kMuted)),
                const SizedBox(height: 4),
                const Text('ID: HE-9201', style: TextStyle(fontSize: 10, color: kMuted)),
                const SizedBox(height: 12),
                const _StatusPill(text: 'Verified Status', bg: Color(0xFFDDFEE3), fg: Color(0xFF15803D)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ProfileMenuTile(icon: Icons.medication_outlined, title: 'Treatment Plan', subtitle: 'Medicine schedule and care phase'),
          const SizedBox(height: 10),
          const _ProfileMenuTile(icon: Icons.notifications_active_outlined, title: 'Reminder Settings', subtitle: 'Medication and checkup alerts'),
          const SizedBox(height: 10),
          const _ProfileMenuTile(icon: Icons.phone_in_talk_outlined, title: 'Doctor Contact', subtitle: 'Dr. Arya Pratama • TB Care'),
          const SizedBox(height: 10),
          const _ProfileMenuTile(icon: Icons.lock_outline_rounded, title: 'Medical Data Privacy', subtitle: 'Control data access and consent'),
          const SizedBox(height: 10),
          const _ProfileMenuTile(icon: Icons.security_outlined, title: 'Security', subtitle: 'Password and login control'),
          const SizedBox(height: 10),
          const _ProfileMenuTile(icon: Icons.logout_rounded, title: 'Logout', subtitle: 'Exit patient account', titleColor: Color(0xFFEF4444)),
        ],
      ),
    );
  }
}

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          SizedBox(height: 16),
          _ProfileMenuTile(icon: Icons.person_rounded, title: 'Workspace', subtitle: 'Admin dashboard access'),
          SizedBox(height: 10),
          _ProfileMenuTile(icon: Icons.settings_outlined, title: 'Preferences', subtitle: 'Theme, alerts, and tools'),
          SizedBox(height: 10),
          _ProfileMenuTile(icon: Icons.lock_outline_rounded, title: 'Security', subtitle: 'Login and session controls'),
          SizedBox(height: 10),
          _ProfileMenuTile(icon: Icons.logout_rounded, title: 'Logout', subtitle: 'Exit admin account', titleColor: Color(0xFFEF4444)),
        ],
      ),
    );
  }
}
