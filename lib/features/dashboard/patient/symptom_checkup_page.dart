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

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _resultRisk = null;
    });

    try {
      final response = await PatientService.submitSymptomCheckup(
        persistentCough: _persistentCough,
        feverOrChills: _feverOrChills,
        nightSweats: _nightSweats,
        weightLoss: _weightLoss,
      );
      if (!mounted) return;
      final risk = response['riskLevel']?.toString() ?? 'unknown';
      setState(() => _resultRisk = risk);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkup gejala berhasil dikirim! ✅')),
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
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        leading: const BackButton(color: kText),
        title: const Text(
          'Checkup Gejala',
          style: TextStyle(fontWeight: FontWeight.w700, color: kText),
        ),
      ),
      body: AppPage(
        children: [
          const PageHeader(
            title: 'Log Gejala Harian',
            subtitle: 'Pilih gejala yang kamu rasakan hari ini.',
          ),
          const SizedBox(height: 16),
          SectionCard(
            background: kSoftBlue,
            borderColor: const Color(0xFFBFDBFE),
            title: 'Symptom Checker',
            trailing: const StatusPill(text: 'i', bg: kPrimary, fg: Colors.white),
            child: const Text(
              'Centang gejala yang kamu rasakan, lalu tekan Kirim untuk analisis.',
              style: TextStyle(fontSize: 9.8, color: kMuted),
            ),
          ),
          const SizedBox(height: 16),
          SymptomTile(
            label: 'Batuk Berkepanjangan',
            icon: Icons.air_rounded,
            tint: kSoftRed,
            selected: _persistentCough,
            onToggle: () => setState(() => _persistentCough = !_persistentCough),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Demam / Menggigil',
            icon: Icons.thermostat_rounded,
            tint: kSoftAmber,
            selected: _feverOrChills,
            onToggle: () => setState(() => _feverOrChills = !_feverOrChills),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Keringat Malam',
            icon: Icons.nightlight_round,
            tint: kSoftBlue,
            selected: _nightSweats,
            onToggle: () => setState(() => _nightSweats = !_nightSweats),
          ),
          const SizedBox(height: 12),
          SymptomTile(
            label: 'Penurunan Berat Badan',
            icon: Icons.restaurant_rounded,
            tint: kSoftGreen,
            selected: _weightLoss,
            onToggle: () => setState(() => _weightLoss = !_weightLoss),
          ),
          const SizedBox(height: 20),
          _submitting
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                )
              : InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(14),
                  child: const PrimaryBannerButton(label: 'Kirim Checkup'),
                ),
          const SizedBox(height: 16),
          if (_resultRisk != null) _RiskResultCard(risk: _resultRisk!),
        ],
      ),
    );
  }
}

class _RiskResultCard extends StatelessWidget {
  const _RiskResultCard({required this.risk});

  final String risk;

  @override
  Widget build(BuildContext context) {
    final isHigh = risk.toLowerCase() == 'high' || risk.toLowerCase() == 'critical';
    final isModerate = risk.toLowerCase() == 'moderate' || risk.toLowerCase() == 'medium';

    final Color bg;
    final Color borderColor;
    final Color pillBg;
    final String label;
    final String message;

    if (isHigh) {
      bg = kSoftRed;
      borderColor = const Color(0xFFFCA5A5);
      pillBg = const Color(0xFFEF4444);
      label = 'Risiko Tinggi';
      message =
          'Segera hubungi dokter penanggung jawab. Tetap minum obat sesuai jadwal.';
    } else if (isModerate) {
      bg = kSoftAmber;
      borderColor = const Color(0xFFFDBA74);
      pillBg = const Color(0xFFF97316);
      label = 'Risiko Sedang';
      message =
          'Tetap minum obat dan laporkan demam yang berkepanjangan ke dokter.';
    } else {
      bg = kSoftGreen;
      borderColor = const Color(0xFFBBF7D0);
      pillBg = const Color(0xFF22C55E);
      label = 'Stabil';
      message =
          'Kondisi kamu terlihat baik. Tetap konsisten minum obat!';
    }

    return SectionCard(
      background: bg,
      borderColor: borderColor,
      title: 'Hasil Analisis',
      trailing: StatusPill(text: label, bg: pillBg, fg: Colors.white),
      child: Text(
        message,
        style: const TextStyle(fontSize: 10.5, color: kMuted),
      ),
    );
  }
}
