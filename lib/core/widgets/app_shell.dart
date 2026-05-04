part of flutter_tbc;

enum AppMode { patient, doctor, admin }

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialMode = AppMode.patient});

  final AppMode initialMode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppMode _mode;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _setMode(AppMode mode) {
    setState(() {
      _mode = mode;
      _index = 0;
    });
  }

  void _setIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  List<_NavItem> get _navItems {
    switch (_mode) {
      case AppMode.patient:
        return const [
          _NavItem(Icons.home_rounded, 'Home'),
          _NavItem(Icons.fact_check_outlined, 'Checkup'),
          _NavItem(Icons.chat_bubble_outline_rounded, 'Chatbot'),
          _NavItem(Icons.history_rounded, 'History'),
          _NavItem(Icons.person_outline_rounded, 'Profile'),
        ];
      case AppMode.doctor:
        return const [
          _NavItem(Icons.home_rounded, 'Home'),
          _NavItem(Icons.groups_outlined, 'Patients'),
          _NavItem(Icons.insights_outlined, 'Adherence'),
          _NavItem(Icons.notifications_active_outlined, 'Reminder'),
          _NavItem(Icons.person_outline_rounded, 'Profile'),
        ];
      case AppMode.admin:
        return const [
          _NavItem(Icons.dashboard_rounded, 'Dashboard'),
          _NavItem(Icons.medical_services_outlined, 'Doctors'),
          _NavItem(Icons.groups_outlined, 'Patients'),
          _NavItem(Icons.person_outline_rounded, 'Profile'),
        ];
    }
  }

  Widget _currentPage() {
    switch (_mode) {
      case AppMode.patient:
        switch (_index) {
          case 0:
            return PatientHomePage(onOpenNotifications: () {
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationCenterPage()));
            });
          case 1:
            return const PatientComplianceDashboardPage();
          case 2:
            return const PatientChatPage();
          case 3:
            return const PatientProgressPage();
          default:
            return const PatientProfilePage();
        }
      case AppMode.doctor:
        switch (_index) {
          case 0:
            return const DoctorDashboardPage();
          case 1:
            return const DoctorPatientsPage();
          case 2:
            return const DoctorAdherencePage();
          case 3:
            return const DoctorReminderPage();
          default:
            return const DoctorProfilePage();
        }
      case AppMode.admin:
        switch (_index) {
          case 0:
            return AdminDashboardPage(onOpenDoctors: () => _setIndex(1), onOpenPatients: () => _setIndex(2));
          case 1:
            return const DoctorsListPage();
          case 2:
            return const PatientsListPage();
          default:
            return const AdminProfilePage();
        }
    }
  }

  String _title() {
    switch (_mode) {
      case AppMode.patient:
        return const ['Home', 'Checkup', 'Chatbot', 'History', 'Profile'][_index];
      case AppMode.doctor:
        return const ['Home', 'Patients', 'Adherence', 'Reminder', 'Profile'][_index];
      case AppMode.admin:
        return const ['Dashboard', 'Doctors', 'Patients', 'Profile'][_index];
    }
  }

  String _subtitle() {
    switch (_mode) {
      case AppMode.patient:
        switch (_index) {
          case 0:
            return 'Treatment progress and today\'s focus.';
          case 1:
            return 'Log symptoms and review feedback.';
          case 2:
            return 'Talk to your care team quickly.';
          case 3:
            return 'Track adherence and milestones.';
          default:
            return 'Account, settings, and privacy.';
        }
      case AppMode.doctor:
        switch (_index) {
          case 0:
            return 'Doctor operations overview and urgent alerts.';
          case 1:
            return 'Monitor assigned patients and current status.';
          case 2:
            return 'Review adherence trends and at-risk patients.';
          case 3:
            return 'Medication reminders and escalation queue.';
          default:
            return 'Doctor account and contact preferences.';
        }
      case AppMode.admin:
        switch (_index) {
          case 0:
            return 'Operations snapshot and quick actions.';
          case 1:
            return 'Care providers and availability.';
          case 2:
            return 'Patient roster and assignment.';
          default:
            return 'Account and workspace settings.';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _navItems;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppTopBar(
              title: _title(),
              subtitle: _subtitle(),
              mode: _mode,
              onModeChanged: _setMode,
              onNotificationsTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationCenterPage()));
              },
            ),
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: _currentPage())),
            _AppBottomNav(items: navItems, selectedIndex: _index.clamp(0, navItems.length - 1), onTap: _setIndex),
          ],
        ),
      ),
    );
  }
}

class _AppTopBar extends StatelessWidget {
  const _AppTopBar({required this.title, required this.subtitle, required this.mode, required this.onModeChanged, required this.onNotificationsTap});

  final String title;
  final String subtitle;
  final AppMode mode;
  final ValueChanged<AppMode> onModeChanged;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        border: const Border(bottom: BorderSide(color: Color(0x33E2E8F0))),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 1))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: mode == AppMode.patient ? kPrimary : const Color(0xFFE7E7F3),
              child: Text(
                mode == AppMode.admin ? 'A' : 'D',
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
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: kMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SegmentedButton<AppMode>(
              segments: const [
                ButtonSegment(value: AppMode.patient, label: Text('Patient')),
                ButtonSegment(value: AppMode.doctor, label: Text('Doctor')),
                ButtonSegment(value: AppMode.admin, label: Text('Admin')),
              ],
              selected: {mode},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                side: MaterialStateProperty.all(const BorderSide(color: Color(0xFFE2E8F0))),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              ),
              onSelectionChanged: (values) => onModeChanged(values.first),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onNotificationsTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                    child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1F2937), size: 20),
                  ),
                  Positioned(
                    right: -1,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(999)),
                      alignment: Alignment.center,
                      child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
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
  const _AppBottomNav({required this.items, required this.selectedIndex, required this.onTap});

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.7),
        border: Border(top: BorderSide(color: Color(0x99E2E8F0))),
        boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -4))],
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
                      color: selected ? kSoftBlue.withValues(alpha: 0.55) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: selected ? kPrimary : const Color(0xFF94A3B8), size: 22),
                        const SizedBox(height: 4),
                        Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? kPrimary : const Color(0xFF94A3B8))),
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

class _NavItem {
  const _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
