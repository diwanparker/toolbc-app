import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/app_mode.dart';
import '../../core/widgets/ui_components.dart';
import '../../features/dashboard/admin/admin_pages.dart';
import '../../features/dashboard/doctor/doctor_pages.dart';
import '../../features/notification/notification_center_page.dart';
import '../../features/dashboard/patient/patient_chat_page.dart';
import '../../features/dashboard/patient/patient_pages.dart';
import '../../features/profile/profile_pages.dart';
import '../../features/status_progres_pasien/patient_progress_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialMode = AppMode.patient});

  final AppMode initialMode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final AppMode _mode;
  late final List<_NavSpec> _navSpecs;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _navSpecs = _navSpecsFor(_mode);
  }

  void _setIndex(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationCenterPage(mode: _mode),
      ),
    );
  }

  void _openAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: SafeArea(child: PatientChatPage()),
        ),
      ),
    );
  }

  List<_NavSpec> _navSpecsFor(AppMode mode) {
    switch (mode) {
      case AppMode.patient:
        return [
          _NavSpec(
            icon: Icons.home_rounded,
            label: 'Home',
            subtitle: 'Progres pengobatan dan fokus hari ini.',
            builder: (_) =>
                PatientHomePage(onOpenNotifications: _openNotifications),
          ),
          _NavSpec(
            icon: Icons.history_rounded,
            label: 'History',
            subtitle: 'Catatan log obat dan checkup mandiri.',
            builder: _patientHistoryPage,
          ),
          _NavSpec(
            icon: Icons.insights_rounded,
            label: 'Statistics',
            subtitle: 'Analitik kepatuhan dan performa terapi.',
            builder: _patientProgressPage,
          ),
          _NavSpec(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'Akun, kontak dokter, dan pengaturan.',
            builder: _patientProfilePage,
          ),
        ];
      case AppMode.doctor:
        return [
          _NavSpec(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            subtitle: 'Ringkasan operasional dan peringatan klinis.',
            builder: _doctorDashboardPage,
          ),
          _NavSpec(
            icon: Icons.people_alt_outlined,
            label: 'Patients',
            subtitle: 'Pantau status pengobatan dan eskalasi pasien.',
            builder: _doctorPatientsPage,
          ),
          _NavSpec(
            icon: Icons.insights_rounded,
            label: 'Adherence',
            subtitle: 'Analitik kepatuhan dan pasien berisiko.',
            builder: _doctorAdherencePage,
          ),
          _NavSpec(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'Akun dokter dan preferensi klinik.',
            builder: _doctorProfilePage,
          ),
        ];
      case AppMode.admin:
        return [
          _NavSpec(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Pasien Baru',
            subtitle: 'Pendaftaran akun pasien dan dokter PJ.',
            builder: _adminPatientPage,
          ),
          _NavSpec(
            icon: Icons.medical_services_outlined,
            label: 'Dokter Baru',
            subtitle: 'Pendaftaran akun dokter penanggung jawab.',
            builder: _adminDoctorPage,
          ),
          _NavSpec(
            icon: Icons.manage_accounts_outlined,
            label: 'Profil',
            subtitle: 'Akun dan manajemen sistem.',
            builder: _adminProfilePage,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _index.clamp(0, _navSpecs.length - 1);
    final current = _navSpecs[selectedIndex];

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _AppTopBar(
                    title: current.label,
                    subtitle: current.subtitle,
                    mode: _mode,
                    onNotificationsTap: _openNotifications,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(current.label),
                        child: current.builder(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 76), // Space for floating bottom nav
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _FloatingBottomNav(
                items: _navSpecs,
                selectedIndex: selectedIndex,
                onTap: _setIndex,
                onCenterTap: _openAIChat,
                showCenterAI: _mode == AppMode.patient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTopBar extends StatelessWidget {
  const _AppTopBar({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.onNotificationsTap,
  });

  final String title;
  final String subtitle;
  final AppMode mode;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final (roleText, roleBg, roleFg) = switch (mode) {
      AppMode.patient => ('Pasien', kPastelCyan, kPrimary),
      AppMode.doctor => ('Dokter', kPastelGreen, kSuccess),
      AppMode.admin => ('Admin', kPastelAmber, kWarning),
    };

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roleText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: roleFg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: kText,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          if (mode == AppMode.patient) ...[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onNotificationsTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: kText,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.onCenterTap,
    this.showCenterAI = true,
  });

  final List<_NavSpec> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;
  final bool showCenterAI;

  @override
  Widget build(BuildContext context) {
    final has4Items = items.length == 4;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: kFloatingShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (has4Items && showCenterAI) ...[
            _buildNavItem(0),
            _buildNavItem(1),
            // Signature Center 4-dot AI Button
            InkWell(
              onTap: onCenterTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: const FourDotIndicator(),
              ),
            ),
            _buildNavItem(2),
            _buildNavItem(3),
          ] else ...[
            for (int i = 0; i < items.length; i++) _buildNavItem(i),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final selected = index == selectedIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected ? kPrimary : const Color(0xFF94A3B8),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kPrimary : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final WidgetBuilder builder;
}

Widget _patientHistoryPage(BuildContext context) {
  return const PatientProgressPage();
}

Widget _patientProgressPage(BuildContext context) {
  return const PatientProgressPage();
}

Widget _patientProfilePage(BuildContext context) {
  return const PatientProfilePage();
}

Widget _doctorDashboardPage(BuildContext context) {
  return const DoctorDashboardPage();
}

Widget _doctorPatientsPage(BuildContext context) {
  return const DoctorPatientsPage();
}

Widget _doctorAdherencePage(BuildContext context) {
  return const DoctorAdherencePage();
}

Widget _doctorProfilePage(BuildContext context) {
  return const DoctorProfilePage();
}

Widget _adminPatientPage(BuildContext context) {
  return const AdminCreateAccountPage(target: AdminAccountTarget.patient);
}

Widget _adminDoctorPage(BuildContext context) {
  return const AdminCreateAccountPage(target: AdminAccountTarget.doctor);
}

Widget _adminProfilePage(BuildContext context) {
  return const AdminProfilePage();
}
