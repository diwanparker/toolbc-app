import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/app_mode.dart';
import '../../features/dashboard/admin/admin_pages.dart';
import '../../features/dashboard/patient/dashboard_compliance/patient_compliance_dashboard_page.dart';
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
      MaterialPageRoute<void>(builder: (_) => const NotificationCenterPage()),
    );
  }

  List<_NavSpec> _navSpecsFor(AppMode mode) {
    switch (mode) {
      case AppMode.patient:
        return [
          _NavSpec(
            icon: Icons.home_rounded,
            label: 'Home',
            subtitle: 'Treatment progress and today\'s focus.',
            builder: (_) =>
                PatientHomePage(onOpenNotifications: _openNotifications),
          ),
          _NavSpec(
            icon: Icons.fact_check_outlined,
            label: 'Checkup',
            subtitle: 'Log symptoms and review feedback.',
            builder: _patientCheckupPage,
          ),
          _NavSpec(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chatbot',
            subtitle: 'Talk to your care team quickly.',
            builder: _patientChatPage,
          ),
          _NavSpec(
            icon: Icons.history_rounded,
            label: 'History',
            subtitle: 'Track adherence and milestones.',
            builder: _patientHistoryPage,
          ),
          _NavSpec(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'Account, settings, and privacy.',
            builder: _patientProfilePage,
          ),
        ];
      case AppMode.doctor:
        return [
          _NavSpec(
            icon: Icons.home_rounded,
            label: 'Home',
            subtitle: 'Doctor operations overview and urgent alerts.',
            builder: _doctorDashboardPage,
          ),
          _NavSpec(
            icon: Icons.groups_outlined,
            label: 'Patients',
            subtitle: 'Monitor assigned patients and current status.',
            builder: _doctorPatientsPage,
          ),
          _NavSpec(
            icon: Icons.insights_outlined,
            label: 'Adherence',
            subtitle: 'Review adherence trends and at-risk patients.',
            builder: _doctorAdherencePage,
          ),
          _NavSpec(
            icon: Icons.notifications_active_outlined,
            label: 'Reminder',
            subtitle: 'Medication reminders and escalation queue.',
            builder: _doctorReminderPage,
          ),
          _NavSpec(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'Doctor account and contact preferences.',
            builder: _doctorProfilePage,
          ),
        ];
      case AppMode.admin:
        return [
          _NavSpec(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Add Patient',
            subtitle: 'Create patient accounts requested by doctors.',
            builder: _adminPatientPage,
          ),
          _NavSpec(
            icon: Icons.medical_services_outlined,
            label: 'Add Doctor',
            subtitle: 'Create doctor accounts for the care team.',
            builder: _adminDoctorPage,
          ),
          _NavSpec(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'Account and workspace settings.',
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
      body: SafeArea(
        bottom: false,
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
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(current.label),
                  child: current.builder(context),
                ),
              ),
            ),
            _AppBottomNav(
              items: _navSpecs,
              selectedIndex: selectedIndex,
              onTap: _setIndex,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        border: const Border(bottom: BorderSide(color: Color(0x33E2E8F0))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: mode == AppMode.patient
                  ? kPrimary
                  : const Color(0xFFE7E7F3),
              child: Text(
                switch (mode) {
                  AppMode.patient => 'P',
                  AppMode.doctor => 'D',
                  AppMode.admin => 'A',
                },
                style: TextStyle(
                  color: mode == AppMode.patient ? Colors.white : kText,
                  fontWeight: FontWeight.w700,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: kMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onNotificationsTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1F2937),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: -1,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavSpec> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.7),
        border: Border(top: BorderSide(color: Color(0x99E2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? kSoftBlue.withValues(alpha: 0.55)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: selected ? kPrimary : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? kPrimary
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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

Widget _patientCheckupPage(BuildContext context) {
  return const PatientComplianceDashboardPage();
}

Widget _patientChatPage(BuildContext context) {
  return const PatientChatPage();
}

Widget _patientHistoryPage(BuildContext context) {
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

Widget _doctorReminderPage(BuildContext context) {
  return const DoctorReminderPage();
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
