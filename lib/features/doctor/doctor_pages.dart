import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Doctor Dashboard',
          subtitle: 'Review urgent cases and daily clinical workload.',
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                label: 'Assigned Patients',
                value: '48',
                icon: Icons.groups_rounded,
                tint: kSurface,
                accent: kPrimary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Urgent Alerts',
                value: '6',
                icon: Icons.notification_important_outlined,
                tint: kSurface,
                accent: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                label: 'Today Reviews',
                value: '22',
                icon: Icons.fact_check_outlined,
                tint: kSurface,
                accent: Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Pending Follow-up',
                value: '9',
                icon: Icons.pending_actions_rounded,
                tint: kSurface,
                accent: Color(0xFFF97316),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionCard(
          background: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFCA5A5),
          title: 'Critical Alert',
          trailing: StatusPill(
            text: 'Urgent',
            bg: Color(0xFFEF4444),
            fg: Colors.white,
          ),
          child: Text(
            '2 patients missed medication for > 24 hours. Immediate follow-up is recommended.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Today Queue',
          child: Column(
            children: [
              _DoctorQueueTile(
                name: 'Davina Karambol',
                status: 'Missed evening dose',
                severity: 'High',
              ),
              SizedBox(height: 10),
              _DoctorQueueTile(
                name: 'Nadia Putri',
                status: 'Mild symptom escalation',
                severity: 'Medium',
              ),
              SizedBox(height: 10),
              _DoctorQueueTile(
                name: 'Rizky Mahendra',
                status: 'Daily report submitted',
                severity: 'Low',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Patients',
          subtitle: 'Track assigned patients and current treatment status.',
        ),
        SizedBox(height: 16),
        _DoctorPatientTile(
          name: 'Davina Karambol',
          treatmentDay: 'Day 24',
          adherence: '86%',
          badge: 'Needs review',
        ),
        SizedBox(height: 12),
        _DoctorPatientTile(
          name: 'Nadia Putri',
          treatmentDay: 'Day 11',
          adherence: '78%',
          badge: 'Moderate risk',
        ),
        SizedBox(height: 12),
        _DoctorPatientTile(
          name: 'Rizky Mahendra',
          treatmentDay: 'Day 36',
          adherence: '92%',
          badge: 'Stable',
        ),
      ],
    );
  }
}

class DoctorAdherencePage extends StatelessWidget {
  const DoctorAdherencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Adherence',
          subtitle: 'Identify risk clusters from adherence trend.',
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly adherence trend',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Chart placeholder',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Top issue: evening dose misses increased by 8% this week.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Risk Buckets',
          child: Column(
            children: [
              _RiskBucketTile(
                label: 'High Risk',
                count: '6 patients',
                color: Color(0xFFEF4444),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Moderate Risk',
                count: '14 patients',
                color: Color(0xFFF97316),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Stable',
                count: '28 patients',
                color: Color(0xFF22C55E),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DoctorReminderPage extends StatelessWidget {
  const DoctorReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Reminder',
          subtitle: 'Medication reminders and escalations queue.',
        ),
        SizedBox(height: 16),
        SectionCard(
          background: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFDBA74),
          title: 'Escalation queue',
          trailing: StatusPill(
            text: '3 Active',
            bg: Color(0xFFF97316),
            fg: Colors.white,
          ),
          child: Text(
            '3 reminders are waiting for doctor confirmation.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
        SizedBox(height: 12),
        _ReminderQueueTile(
          name: 'Davina Karambol',
          message: 'Missed evening medication > 2 hours',
          status: 'Escalated',
        ),
        SizedBox(height: 10),
        _ReminderQueueTile(
          name: 'Nadia Putri',
          message: 'Pending confirmation after reminder',
          status: 'Pending',
        ),
        SizedBox(height: 10),
        _ReminderQueueTile(
          name: 'Rizky Mahendra',
          message: 'Reminder resolved by patient',
          status: 'Resolved',
        ),
      ],
    );
  }
}

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: const [
        PageHeader(
          title: 'Profile',
          subtitle: 'Doctor account, availability, and security settings.',
        ),
        SizedBox(height: 16),
        ProfileMenuTile(
          icon: Icons.badge_outlined,
          title: 'Professional Identity',
          subtitle: 'Dr. Arya Pratama • Pulmonology',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.schedule_outlined,
          title: 'Availability',
          subtitle: 'Set active consultation schedule',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.notifications_active_outlined,
          title: 'Reminder Preferences',
          subtitle: 'Escalation and alert threshold',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.security_outlined,
          title: 'Security',
          subtitle: 'Password and session management',
        ),
        SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Exit doctor account',
          titleColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _DoctorQueueTile extends StatelessWidget {
  const _DoctorQueueTile({
    required this.name,
    required this.status,
    required this.severity,
  });

  final String name;
  final String status;
  final String severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'High' => const Color(0xFFEF4444),
      'Medium' => const Color(0xFFF97316),
      _ => const Color(0xFF22C55E),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: severity,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientTile extends StatelessWidget {
  const _DoctorPatientTile({
    required this.name,
    required this.treatmentDay,
    required this.adherence,
    required this.badge,
  });

  final String name;
  final String treatmentDay;
  final String adherence;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE2E8F0),
            child: Text(
              name[0],
              style: const TextStyle(fontWeight: FontWeight.w700, color: kText),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$treatmentDay • Adherence $adherence',
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(text: badge, bg: const Color(0xFFF8FAFC), fg: kMuted),
        ],
      ),
    );
  }
}

class _RiskBucketTile extends StatelessWidget {
  const _RiskBucketTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
          ),
          Text(count, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      ),
    );
  }
}

class _ReminderQueueTile extends StatelessWidget {
  const _ReminderQueueTile({
    required this.name,
    required this.message,
    required this.status,
  });

  final String name;
  final String message;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Escalated' => const Color(0xFFEF4444),
      'Pending' => const Color(0xFFF97316),
      _ => const Color(0xFF16A34A),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: kPrimary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(fontSize: 10.5, color: kMuted),
                ),
              ],
            ),
          ),
          StatusPill(
            text: status,
            bg: color.withValues(alpha: 0.14),
            fg: color,
          ),
        ],
      ),
    );
  }
}
