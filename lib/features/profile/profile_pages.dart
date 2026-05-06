import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Profile',
          subtitle: 'Patient details, treatment plan, and settings.',
        ),
        SizedBox(height: 16),
        _PatientIdentityCard(),
        SizedBox(height: 16),
        ProfileMenuTile(
          icon: Icons.medication_outlined,
          title: 'Treatment Plan',
          subtitle: 'Medicine schedule and care phase',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.notifications_active_outlined,
          title: 'Reminder Settings',
          subtitle: 'Medication and checkup alerts',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.phone_in_talk_outlined,
          title: 'Doctor Contact',
          subtitle: 'Dr. Arya Pratama - TB Care',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'Medical Data Privacy',
          subtitle: 'Control data access and consent',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.security_outlined,
          title: 'Security',
          subtitle: 'Password and login control',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Exit patient account',
          titleColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(title: 'Profile'),
        SizedBox(height: 16),
        ProfileMenuTile(
          icon: Icons.person_rounded,
          title: 'Workspace',
          subtitle: 'Admin dashboard access',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.settings_outlined,
          title: 'Preferences',
          subtitle: 'Theme, alerts, and tools',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'Security',
          subtitle: 'Login and session controls',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Exit admin account',
          titleColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _PatientIdentityCard extends StatelessWidget {
  const _PatientIdentityCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: const [
          SizedBox(height: 4),
          CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFF8B4C8),
            child: Text(
              'D',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Davina Karambol',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'TBC Recovery Patient',
            style: TextStyle(fontSize: 11, color: kMuted),
          ),
          SizedBox(height: 4),
          Text('ID: HE-9201', style: TextStyle(fontSize: 10, color: kMuted)),
          SizedBox(height: 12),
          StatusPill(
            text: 'Verified Status',
            bg: Color(0xFFDDFEE3),
            fg: Color(0xFF15803D),
          ),
        ],
      ),
    );
  }
}
