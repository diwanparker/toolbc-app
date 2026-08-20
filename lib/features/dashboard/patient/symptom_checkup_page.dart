import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/widgets/ui_components.dart';

class SymptomCheckupPage extends StatefulWidget {
  const SymptomCheckupPage({super.key});

  @override
  State<SymptomCheckupPage> createState() => _SymptomCheckupPageState();
}

class _SymptomCheckupPageState extends State<SymptomCheckupPage> {
  bool _persistentCough = false;
  bool _feverOrChills = false;
  bool _nightSweats = false;
  bool _weightLoss = false;
  bool _submitting = false;
  String? _resultRisk;
  String? _resultFeedback;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _resultRisk = null;
      _resultFeedback = null;
    });

    try {
      final response = await PatientService.submitSymptomCheckup(
        persistentCough: _persistentCough,
        feverOrChills: _feverOrChills,
        nightSweats: _nightSweats,
        weightLoss: _weightLoss,
      );
      if (!mounted) return;
      final risk = response['riskLevel']?.toString() ?? 'Low';
      final feedback = response['feedback']?.toString();
      setState(() {
        _resultRisk = risk;
        _resultFeedback = feedback;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkup gejala berhasil terkirim ke dokter PJ! ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim checkup: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: const BackButton(color: kText),
        title: const Text(
          'Checkup Gejala Mandiri',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: kText),
        ),
      ),
      body: AppPage(
        children: [
          const PageHeader(
            title: 'Laporan Gejala Harian 📋',
            subtitle: 'Centang keluhan yang Anda rasakan untuk evaluasi risiko klinis otomatis.',
          ),
          const SizedBox(height: 16),
          SymptomTile(
            label: 'Batuk Menetap',
            description: 'Batuk berdahak atau bercampur darah lebih dari 2 minggu.',
            icon: Icons.air_rounded,
            tint: kSoftRed,
            selected: _persistentCough,
            onToggle: () => setState(() => _persistentCough = !_persistentCough),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Demam / Menggigil',
            description: 'Suhu tubuh meningkat terutama menjelang sore atau malam hari.',
            icon: Icons.thermostat_rounded,
            tint: kSoftAmber,
            selected: _feverOrChills,
            onToggle: () => setState(() => _feverOrChills = !_feverOrChills),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Keringat Malam Berlebih',
            description: 'Berkeringat basah saat tidur meski suhu ruangan sejuk.',
            icon: Icons.nightlight_round,
            tint: kSoftBlue,
            selected: _nightSweats,
            onToggle: () => setState(() => _nightSweats = !_nightSweats),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Penurunan Berat Badan',
            description: 'Nafsu makan berkurang drastis atau berat badan turun signifikan.',
            icon: Icons.monitor_weight_outlined,
            tint: kSoftGreen,
            selected: _weightLoss,
            onToggle: () => setState(() => _weightLoss = !_weightLoss),
          ),
          const SizedBox(height: 24),
          _submitting
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                )
              : InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(16),
                  child: const PrimaryBannerButton(
                    label: 'Kirim Log Gejala ke Dokter',
                    icon: Icons.send_rounded,
                  ),
                ),
          const SizedBox(height: 16),
          if (_resultRisk != null)
            _RiskResultCard(
              risk: _resultRisk!,
              feedback: _resultFeedback,
            ),
        ],
      ),
    );
  }
}

class _RiskResultCard extends StatelessWidget {
  const _RiskResultCard({required this.risk, this.feedback});

  final String risk;
  final String? feedback;

  @override
  Widget build(BuildContext context) {
    final isHigh = risk.toLowerCase() == 'high' || risk.toLowerCase() == 'critical';
    final isModerate = risk.toLowerCase() == 'moderate' || risk.toLowerCase() == 'medium';

    final Color bg;
    final Color borderColor;
    final Color pillBg;
    final String label;
    final IconData icon;
    final String defaultMessage;

    if (isHigh) {
      bg = kSoftRed;
      borderColor = kBorderRed;
      pillBg = kDanger;
      label = 'Risiko Tinggi';
      icon = Icons.warning_rounded;
      defaultMessage =
          'Segera hubungi dokter penanggung jawab Anda atau kunjungi fasilitas kesehatan terdekat. Tetap minum obat sesuai anjuran.';
    } else if (isModerate) {
      bg = kSoftAmber;
      borderColor = kBorderAmber;
      pillBg = kWarning;
      label = 'Risiko Sedang';
      icon = Icons.info_rounded;
      defaultMessage =
          'Tetap minum obat secara disiplin dan pantau perkembangan gejala dalam 1-2 hari ke depan.';
    } else {
      bg = kSoftGreen;
      borderColor = kBorderGreen;
      pillBg = kSuccess;
      label = 'Kondisi Stabil';
      icon = Icons.check_circle_rounded;
      defaultMessage =
          'Kondisi klinis kamu terpantau baik. Pertahankan pola hidup sehat dan kepatuhan minum obat!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: pillBg, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hasil Evaluasi Klinis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ),
              StatusPill(text: label, bg: pillBg, fg: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (feedback != null && feedback!.isNotEmpty) ? feedback! : defaultMessage,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }
}
