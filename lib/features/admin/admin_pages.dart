part of flutter_tbc;

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.onOpenDoctors, required this.onOpenPatients});

  final VoidCallback onOpenDoctors;
  final VoidCallback onOpenPatients;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('High-level care operations and quick actions.', style: TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _MetricCard(label: 'Active patients', value: '128', icon: Icons.groups_rounded, tint: kSurface, accent: kPrimary)),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Pending reviews', value: '14', icon: Icons.pending_actions_rounded, tint: kSurface, accent: Color(0xFFF97316))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _MetricCard(label: 'Completed today', value: '43', icon: Icons.check_circle_outline_rounded, tint: kSurface, accent: Color(0xFF16A34A))),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Alerts', value: '2', icon: Icons.notification_important_outlined, tint: kSurface, accent: Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Quick Actions',
            child: Row(
              children: [
                Expanded(child: _ActionChip(label: 'Doctors', filled: true, fillColor: kPrimary, fg: Colors.white, onTap: onOpenDoctors)),
                const SizedBox(width: 10),
                Expanded(child: _ActionChip(label: 'Patients', filled: true, fillColor: const Color(0xFFDBEAFE), fg: kPrimary, onTap: onOpenPatients)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _PreviewHeader(title: 'Doctors Preview', action: 'View all'),
          const SizedBox(height: 10),
          const _DoctorPreviewCard(name: 'Dr. Arya', specialty: 'Pulmonologist', badge: 'Available'),
          const SizedBox(height: 10),
          const _DoctorPreviewCard(name: 'Dr. Bima', specialty: 'General Practitioner', badge: 'Online', muted: true),
          const SizedBox(height: 16),
          const _PreviewHeader(title: 'Patients Preview', action: 'View all'),
          const SizedBox(height: 10),
          const _PatientPreviewCard(name: 'Davina', status: 'Assigned to Dr. Arya', badge: 'Needs review'),
          const SizedBox(height: 10),
          const _PatientPreviewCard(name: 'Rizky', status: 'Assigned to Dr. Arya', badge: 'Stable'),
        ],
      ),
    );
  }
}

class DoctorsListPage extends StatelessWidget {
  const DoctorsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Doctors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kText)),
          SizedBox(height: 16),
          _DoctorListItem(name: 'Dr. Sarah Jenkins', specialty: 'Pulmonologist', badge: 'Top match'),
          SizedBox(height: 12),
          _DoctorListItem(name: 'Dr. Marcus Thorne', specialty: 'General Practitioner', badge: 'Available', muted: true),
          SizedBox(height: 12),
          _DoctorListItem(name: 'Dr. Elena Rodriguez', specialty: 'TB Care', badge: 'Recommended'),
        ],
      ),
    );
  }
}

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Patients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kText)),
          SizedBox(height: 16),
          _PatientListItem(name: 'Davina', status: 'Assigned to Dr. Arya', badge: 'Needs review'),
          SizedBox(height: 12),
          _PatientListItem(name: 'Rizky', status: 'Assigned to Dr. Arya', badge: 'Stable'),
          SizedBox(height: 12),
          _PatientListItem(name: 'Nadia', status: 'Assigned to Dr. Arya', badge: 'Stable'),
        ],
      ),
    );
  }
}
