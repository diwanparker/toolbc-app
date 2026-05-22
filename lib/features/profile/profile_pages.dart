import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/ui_components.dart';
import '../auth/login_page.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupabaseService.fetchCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return AppPage(
          children: [
            const PageHeader(
              title: 'Profile',
              subtitle: 'Patient details, treatment plan, and settings.',
            ),
            const SizedBox(height: 16),
            _IdentityCard(profile: profile, fallbackRole: 'Patient'),
            const SizedBox(height: 16),
            const ProfileMenuTile(
              icon: Icons.medication_outlined,
              title: 'Treatment Plan',
              subtitle: 'Medicine schedule and care phase',
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.notifications_active_outlined,
              title: 'Reminder Settings',
              subtitle: 'Medication and checkup alerts',
            ),
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Change app language (ID/EN)',
              onTap: () => showLanguageDialog(context),
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password and login control',
            ),
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Exit patient account',
              titleColor: const Color(0xFFEF4444),
              onTap: () => _logout(context),
            ),
          ],
        );
      },
    );
  }
}

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupabaseService.fetchCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return AppPage(
          children: [
            const PageHeader(title: 'Profile'),
            const SizedBox(height: 16),
            _IdentityCard(profile: profile, fallbackRole: 'Admin'),
            const SizedBox(height: 16),
            const ProfileMenuTile(
              icon: Icons.person_rounded,
              title: 'Workspace',
              subtitle: 'Admin dashboard access',
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Preferences',
              subtitle: 'Theme, alerts, and tools',
            ),
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Change app language (ID/EN)',
              onTap: () => showLanguageDialog(context),
            ),
            const SizedBox(height: 10),
            const ProfileMenuTile(
              icon: Icons.lock_outline_rounded,
              title: 'Security',
              subtitle: 'Login and session controls',
            ),
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Exit admin account',
              titleColor: const Color(0xFFEF4444),
              onTap: () => _logout(context),
            ),
          ],
        );
      },
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.fallbackRole});

  final UserProfile? profile;
  final String fallbackRole;

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.displayName ?? 'Pengguna ToolBC';
    final email = profile?.email ?? 'Email belum tersedia';

    return SectionCard(
      child: Column(
        children: [
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF93C5FD),
            child: Text(
              profile?.initials ?? 'T',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 11, color: kMuted)),
          const SizedBox(height: 12),
          StatusPill(
            text: profile == null ? fallbackRole : profile!.role.name,
            bg: const Color(0xFFDDFEE3),
            fg: const Color(0xFF15803D),
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await SupabaseService.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const AuthLoginPage()),
    (_) => false,
  );
}
