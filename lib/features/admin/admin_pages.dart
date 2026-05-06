import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/ui_components.dart';

enum AdminAccountTarget { patient, doctor }

class AdminCreateAccountPage extends StatefulWidget {
  const AdminCreateAccountPage({super.key, required this.target});

  final AdminAccountTarget target;

  @override
  State<AdminCreateAccountPage> createState() => _AdminCreateAccountPageState();
}

class _AdminCreateAccountPageState extends State<AdminCreateAccountPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _noteController = TextEditingController();

  bool _submitting = false;
  String? _resultMessage;

  bool get _isPatient => widget.target == AdminAccountTarget.patient;
  String get _roleLabel => _isPatient ? 'pasien/user' : 'dokter';
  String get _emailSuffix => _isPatient ? '@pasien.com' : '@dokter.com';
  String get _noteHint => _isPatient
      ? 'Dokter peminta / dokter penanggung jawab'
      : 'Spesialisasi / poli';
  String get _noteKey => _isPatient ? 'assigned_doctor' : 'specialty';

  @override
  void didUpdateWidget(covariant AdminCreateAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _clearFields();
      _resultMessage = null;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final note = _noteController.text.trim();

    final validationError = _validate(
      fullName: fullName,
      email: email,
      password: password,
      confirm: confirm,
    );
    if (validationError != null) {
      _showSnack(validationError);
      return;
    }

    setState(() => _submitting = true);
    try {
      if (SupabaseService.isConfigured) {
        await SupabaseService.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'role': widget.target.name,
            if (note.isNotEmpty) _noteKey: note,
            'created_by': 'admin',
          },
        );
      }

      if (!mounted) return;
      setState(() {
        _resultMessage = SupabaseService.isConfigured
            ? 'Akun $_roleLabel berhasil dibuat dan dikirim ke Supabase.'
            : 'Mode demo: data akun $_roleLabel sudah divalidasi. Sambungkan Supabase untuk menyimpan akun sungguhan.';
        _clearFields();
      });
    } on AuthException catch (e) {
      if (mounted) _showSnack('Gagal membuat akun: ${e.message}');
    } catch (e) {
      if (mounted) _showSnack('Gagal membuat akun: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _validate({
    required String fullName,
    required String email,
    required String password,
    required String confirm,
  }) {
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      return 'Semua field wajib diisi.';
    }
    if (!email.endsWith(_emailSuffix)) {
      return 'Email $_roleLabel harus berakhiran $_emailSuffix.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (password != confirm) return 'Konfirmasi password tidak sama.';
    return null;
  }

  void _clearFields() {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _noteController.clear();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        PageHeader(
          title: 'Tambah Akun ${_isPatient ? 'Pasien/User' : 'Dokter'}',
          subtitle: _isPatient
              ? 'Admin/resepsionis membuat akun pasien berdasarkan pengajuan dokter.'
              : 'Admin/resepsionis membuat akun dokter untuk akses monitoring pasien.',
        ),
        const SizedBox(height: 16),
        _RoleInfoCard(isPatient: _isPatient, emailSuffix: _emailSuffix),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Account Form',
          child: Column(
            children: [
              AuthField(
                hintText: 'Nama lengkap',
                prefixIcon: Icons.person_outline_rounded,
                controller: _fullNameController,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: 'email$_emailSuffix',
                prefixIcon: Icons.mail_outline_rounded,
                controller: _emailController,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: _noteHint,
                prefixIcon: _isPatient
                    ? Icons.medical_information_outlined
                    : Icons.badge_outlined,
                controller: _noteController,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: 'Konfirmasi password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded, size: 19),
                  label: Text(
                    _submitting
                        ? 'Membuat akun...'
                        : 'Buat Akun ${_isPatient ? 'Pasien' : 'Dokter'}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_resultMessage != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            background: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            title: 'Sukses',
            trailing: const StatusPill(
              text: 'Done',
              bg: Color(0xFF22C55E),
              fg: Colors.white,
            ),
            child: Text(
              _resultMessage!,
              style: const TextStyle(fontSize: 10.5, color: kMuted),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleInfoCard extends StatelessWidget {
  const _RoleInfoCard({required this.isPatient, required this.emailSuffix});

  final bool isPatient;
  final String emailSuffix;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      background: isPatient ? kSoftBlue : const Color(0xFFF0FDF4),
      borderColor: isPatient
          ? const Color(0xFFBFDBFE)
          : const Color(0xFFBBF7D0),
      title: 'Role ${isPatient ? 'Pasien/User' : 'Dokter'}',
      trailing: StatusPill(
        text: emailSuffix,
        bg: isPatient ? kPrimary : const Color(0xFF22C55E),
        fg: Colors.white,
      ),
      child: const Text(
        'Tidak ada register publik. Akun dibuat dari halaman admin setelah login.',
        style: TextStyle(fontSize: 10.5, color: kMuted),
      ),
    );
  }
}
