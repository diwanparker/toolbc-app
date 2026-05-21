import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/ui_components.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const PageHeader(
          title: 'Good morning, Davina',
          subtitle: 'You are doing well. Keep your treatment on track.',
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331D4ED8),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -18,
                child: _orb(108, Colors.white.withValues(alpha: 0.11)),
              ),
              Positioned(
                right: 10,
                bottom: -24,
                child: _orb(88, Colors.white.withValues(alpha: 0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fase Intensif • Minggu ke-4 dari 8',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDBEAFE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day 24',
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.05,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '14% selesai • tetap konsisten!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFDBEAFE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 96,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Streak 7 days',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
                label: 'Adherence',
                value: '86%',
                icon: Icons.check_circle_outline_rounded,
                tint: Color(0xFFD4F7DD),
                accent: Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Tes Dahak',
                value: 'Bulan ke-2',
                icon: Icons.biotech_rounded,
                tint: Color(0xFFEFF6FF),
                accent: kPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Pengingat Obat',
          trailing: const StatusPill(
            text: 'Belum',
            bg: Color(0xFFFFF7ED),
            fg: Color(0xFF92400E),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  TimeBadge(time: '07:00 WIB'),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'RHZE (Rifampicin, Isoniazid,\nPyrazinamide, Ethambutol)\n• sebelum makan, perut kosong',
                      style: TextStyle(fontSize: 10.5, color: kMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFF97316)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Urin berwarna merah/oranye setelah minum Rifampicin adalah NORMAL.',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppActionChip(
                      label: 'Sudah diminum',
                      filled: true,
                      fillColor: Color(0xFF22C55E),
                      fg: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppActionChip(
                      label: 'Ingatkan nanti',
                      filled: false,
                      fillColor: kSoftBlue,
                      fg: kPrimary,
                      onTap: onOpenNotifications,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Status Pengingat',
          trailing: const StatusPill(
            text: 'Aktif',
            bg: Color(0xFFDDF7E0),
            fg: Color(0xFF15803D),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengingat otomatis terkirim 5 menit lalu.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
              SizedBox(height: 4),
              Text(
                'Pengingat berikutnya dalam 10 menit jika belum dikonfirmasi.',
                style: TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Checklist Harian',
          child: const ChecklistTile(label: 'Minum obat pagi', active: false),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Quick Support',
          child: Row(
            children: [
              Expanded(
                child: AppActionChip(
                  label: 'Tanya AI',
                  filled: false,
                  fillColor: kSoftBlue,
                  fg: kPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: AppActionChip(
                  label: 'Hubungi dokter',
                  filled: false,
                  fillColor: kSoftBlue,
                  fg: kPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: AppActionChip(
                  label: 'Kirim laporan',
                  filled: false,
                  fillColor: kSoftBlue,
                  fg: kPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
