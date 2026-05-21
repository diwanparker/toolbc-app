import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/ui_components.dart';

class PatientComplianceDashboardPage extends StatelessWidget {
  const PatientComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Daily Checkup',
          subtitle: 'Log your condition and get supportive feedback.',
        ),
        const SizedBox(height: 16),
        SectionCard(
          background: kSoftBlue,
          borderColor: const Color(0xFFBFDBFE),
          title: 'Today\'s symptom log',
          trailing: const StatusPill(text: 'i', bg: kPrimary, fg: Colors.white),
          child: const Text(
            'Select symptoms you feel today before analysis.',
            style: TextStyle(fontSize: 9.8, color: kMuted),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Symptom Checker',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        const SizedBox(height: 12),
        const SymptomTile(
          label: 'Persistent cough',
          icon: Icons.air_rounded,
          tint: kSoftRed,
          selected: true,
          onToggle: _noop,
        ),
        const SizedBox(height: 12),
        const SymptomTile(
          label: 'Fever / chills',
          icon: Icons.thermostat_rounded,
          tint: kSoftAmber,
          selected: true,
          onToggle: _noop,
        ),
        const SizedBox(height: 12),
        const SymptomTile(
          label: 'Night sweats',
          icon: Icons.nightlight_round,
          tint: kSoftBlue,
          selected: false,
          onToggle: _noop,
        ),
        const SizedBox(height: 12),
        const SymptomTile(
          label: 'Weight loss / low appetite',
          icon: Icons.restaurant_rounded,
          tint: Color(0xFFF0FDF4),
          selected: false,
          onToggle: _noop,
        ),
        const SizedBox(height: 6),
        const PrimaryBannerButton(label: 'Analyze Symptoms'),
        const SizedBox(height: 16),
        SectionCard(
          background: const Color(0xFFFFF7ED),
          borderColor: const Color(0xFFFDBA74),
          title: 'Moderate Risk Feedback',
          trailing: const StatusPill(
            text: '!',
            bg: Color(0xFFF97316),
            fg: Colors.white,
          ),
          child: const Text(
            'Please keep taking medicine and report persistent fever to your doctor.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}
