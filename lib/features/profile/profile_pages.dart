import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/auth_service.dart';
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
    _profileFuture = Future.value(AuthService.currentUser);
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
              title: 'Profil Pasien 👤',
              subtitle: 'Data identitas, rencana terapi, dan pengaturan akun.',
            ),
            const SizedBox(height: 16),
            _IdentityCard(profile: profile, fallbackRole: 'Pasien'),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Pengaturan Akun & Layanan',
              child: Column(
                children: [
                  const ProfileMenuTile(
                    icon: Icons.medication_outlined,
                    title: 'Rencana Pengobatan',
                    subtitle: 'Jadwal dosis obat OAT dan fase terapi aktif',
                  ),
                  const SizedBox(height: 10),
                  const ProfileMenuTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pengaturan Pengingat',
                    subtitle: 'Waktu notifikasi minum obat & jadwal kontrol',
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuTile(
                    icon: Icons.language_rounded,
                    title: 'Bahasa / Language',
                    subtitle: 'Bahasa Indonesia (ID)',
                    onTap: () => showLanguageDialog(context),
                  ),
                  const SizedBox(height: 10),
                  const ProfileMenuTile(
                    icon: Icons.security_outlined,
                    title: 'Keamanan & Privasi',
                    subtitle: 'Ganti password dan kendali akses data medis',
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar Akun',
                    subtitle: 'Keluar dari aplikasi ToolBC',
                    titleColor: kDanger,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
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
    _profileFuture = Future.value(AuthService.currentUser);
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
              title: 'Profil Administrator 🛡️',
              subtitle: 'Manajemen hak akses, audit log, dan pengaturan sistem.',
            ),
            const SizedBox(height: 16),
            _IdentityCard(profile: profile, fallbackRole: 'Administrator'),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Manajemen Sistem',
              child: Column(
                children: [
                  const ProfileMenuTile(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Workspace Admin',
                    subtitle: 'Akses kontrol data master klinik dan pasien',
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuTile(
                    icon: Icons.language_rounded,
                    title: 'Bahasa / Language',
                    subtitle: 'Bahasa Indonesia (ID)',
                    onTap: () => showLanguageDialog(context),
                  ),
                  const SizedBox(height: 10),
                  const ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Keamanan Sesi',
                    subtitle: 'Audit log login dan token sesi',
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar Akun',
                    subtitle: 'Keluar dari sesi administrator',
                    titleColor: kDanger,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: kSoftBlue,
            child: Text(
              profile?.initials ?? 'T',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: kText,
            ),
          ),
          const SizedBox(height: 3),
          Text(email, style: const TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 12),
          StatusPill(
            text: profile == null ? fallbackRole : profile!.role.name.toUpperCase(),
            bg: kSoftGreen,
            fg: kSuccess,
          ),
        ],
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  final confirmed = await showConfirmLogoutDialog(context);
  if (confirmed != true || !context.mounted) return;
  await AuthService.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const AuthLoginPage()),
    (_) => false,
  );
}
