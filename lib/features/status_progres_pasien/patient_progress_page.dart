import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';

class PatientProgressPage extends StatelessWidget {
  const PatientProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Progress History',
          subtitle: 'Track your treatment timeline and adherence streak.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adherence Streak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDDFEE3),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '7 days',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep going, every dose matters.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFDDFEE3)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                label: 'Treatment day',
                value: '24',
                icon: Icons.timeline_rounded,
                tint: kSurface,
                accent: kPrimary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Monthly adherence',
                value: '86%',
                icon: Icons.check_circle_outline_rounded,
                tint: kSurface,
                accent: Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'History Logs',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        const SizedBox(height: 12),
        const HistoryLogCard(
          title: 'Morning medicine completed',
          subtitle: 'Today • 08:04 WIB',
          leading: Icons.check_circle_rounded,
          tint: kSoftGreen,
          fg: Color(0xFF16A34A),
        ),
        const SizedBox(height: 12),
        const HistoryLogCard(
          title: 'Symptom log submitted',
          subtitle: 'Yesterday • Low risk feedback',
          leading: Icons.info_rounded,
          tint: kSoftBlue,
          fg: kPrimary,
        ),
        const SizedBox(height: 12),
        const HistoryLogCard(
          title: 'Reminder sent for evening dose',
          subtitle: '2 days ago • Confirmed after reminder',
          leading: Icons.notifications_active_rounded,
          tint: Color(0xFFFFF7ED),
          fg: Color(0xFFF97316),
        ),
      ],
    );
  }
}
