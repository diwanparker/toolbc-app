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
          title: 'Dashboard Dokter',
          subtitle: 'Tinjau kasus mendesak dan beban kerja klinis harian.',
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                label: 'Pasien Terdaftar',
                value: '48',
                icon: Icons.groups_rounded,
                tint: kSurface,
                accent: kPrimary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Peringatan Mendesak',
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
                label: 'Tinjauan Hari Ini',
                value: '22',
                icon: Icons.fact_check_outlined,
                tint: kSurface,
                accent: Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Tindak Lanjut',
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
          title: 'Peringatan Kritis',
          trailing: StatusPill(
            text: 'Mendesak',
            bg: Color(0xFFEF4444),
            fg: Colors.white,
          ),
          child: Text(
            '2 pasien tidak minum obat pagi > 24 jam. Tindak lanjut segera diperlukan.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Antrian Hari Ini',
          child: Column(
            children: [
              _DoctorQueueTile(
                name: 'Davina Karambol',
                status: 'Melewatkan dosis pagi',
                severity: 'High',
              ),
              SizedBox(height: 10),
              _DoctorQueueTile(
                name: 'Nadia Putri',
                status: 'Eskalasi gejala ringan',
                severity: 'Medium',
              ),
              SizedBox(height: 10),
              _DoctorQueueTile(
                name: 'Rizky Mahendra',
                status: 'Laporan harian dikirim',
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
          title: 'Pasien & Eskalasi',
          subtitle: 'Pantau status pengobatan dan antrian eskalasi pasien.',
        ),
        SizedBox(height: 16),
        SectionCard(
          background: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFDBA74),
          title: 'Antrian Eskalasi',
          trailing: StatusPill(
            text: '3 Aktif',
            bg: Color(0xFFF97316),
            fg: Colors.white,
          ),
          child: Text(
            '3 peringatan atau pengingat menunggu konfirmasi dokter.',
            style: TextStyle(fontSize: 10.5, color: kMuted),
          ),
        ),
        SizedBox(height: 12),
        _ReminderQueueTile(
          name: 'Davina Karambol',
          message: 'Melewatkan obat pagi > 2 jam',
          status: 'Escalated',
        ),
        SizedBox(height: 10),
        _ReminderQueueTile(
          name: 'Nadia Putri',
          message: 'Menunggu konfirmasi setelah pengingat',
          status: 'Pending',
        ),
        SizedBox(height: 16),
        Text(
          'Daftar Pasien',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        SizedBox(height: 12),
        _DoctorPatientTile(
          name: 'Davina Karambol',
          treatmentDay: 'Hari ke-24 (Intensif)',
          adherence: '86%',
          badge: 'Perlu ditinjau',
        ),
        SizedBox(height: 12),
        _DoctorPatientTile(
          name: 'Nadia Putri',
          treatmentDay: 'Hari ke-11 (Intensif)',
          adherence: '78%',
          badge: 'Risiko sedang',
        ),
        SizedBox(height: 12),
        _DoctorPatientTile(
          name: 'Rizky Mahendra',
          treatmentDay: 'Hari ke-36 (Intensif)',
          adherence: '92%',
          badge: 'Stabil',
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
          title: 'Kepatuhan Minum Obat',
          subtitle: 'Identifikasi klaster risiko dari tren kepatuhan.',
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tren kepatuhan mingguan',
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
                  'Grafik (segera hadir)',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masalah utama: dosis pagi terlewat meningkat 8% minggu ini.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Kelompok Risiko',
          child: Column(
            children: [
              _RiskBucketTile(
                label: 'Risiko Tinggi',
                count: '6 pasien',
                color: Color(0xFFEF4444),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Risiko Sedang',
                count: '14 pasien',
                color: Color(0xFFF97316),
              ),
              SizedBox(height: 10),
              _RiskBucketTile(
                label: 'Stabil',
                count: '28 pasien',
                color: Color(0xFF22C55E),
              ),
            ],
          ),
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
      children: [
        const PageHeader(
          title: 'Profil',
          subtitle: 'Akun dokter, jadwal, dan pengaturan keamanan.',
        ),
        const SizedBox(height: 16),
        const ProfileMenuTile(
          icon: Icons.badge_outlined,
          title: 'Identitas Profesional',
          subtitle: 'Dr. Arya Pratama • Pulmonologi',
        ),
        const SizedBox(height: 10),
        const ProfileMenuTile(
          icon: Icons.schedule_outlined,
          title: 'Ketersediaan',
          subtitle: 'Atur jadwal konsultasi aktif',
        ),
        const SizedBox(height: 10),
        const ProfileMenuTile(
          icon: Icons.notifications_active_outlined,
          title: 'Preferensi Pengingat',
          subtitle: 'Eskalasi dan batas peringatan',
        ),
        const SizedBox(height: 10),
        ProfileMenuTile(
          icon: Icons.language_rounded,
          title: 'Bahasa',
          subtitle: 'Ganti bahasa aplikasi (ID/EN)',
          onTap: () => showLanguageDialog(context),
        ),
        const SizedBox(height: 10),
        const ProfileMenuTile(
          icon: Icons.security_outlined,
          title: 'Keamanan',
          subtitle: 'Password dan manajemen sesi',
        ),
        const SizedBox(height: 10),
        const ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Keluar',
          subtitle: 'Keluar dari akun dokter',
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
                  '$treatmentDay • Kepatuhan $adherence',
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
