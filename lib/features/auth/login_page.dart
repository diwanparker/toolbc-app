import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/ui_components.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _emailController = TextEditingController(text: 'davina@pasien.com');
  final _passwordController = TextEditingController(text: 'Pasien123!');

  bool _passwordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'Pasien';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'Pasien') {
        _emailController.text = 'davina@pasien.com';
        _passwordController.text = 'Pasien123!';
      } else if (role == 'Dokter') {
        _emailController.text = 'dr.budi@rsud.com';
        _passwordController.text = 'Dokter123!';
      } else if (role == 'Admin') {
        _emailController.text = 'admin@toolbc.id';
        _passwordController.text = 'Admin123!';
      }
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnack('Email wajib diisi.');
      return;
    }
    if (password.isEmpty) {
      _showSnack('Password wajib diisi.');
      return;
    }

    if (!AuthService.isConfigured) {
      _showSnack('Server belum terhubung. Periksa konfigurasi API.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = await AuthService.signIn(email, password);
      if (profile == null) {
        await AuthService.signOut();
        if (mounted) _showSnack('Profil akun belum dibuat di database.');
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AppShell(initialMode: profile.role.appMode),
        ),
      );
    } on StateError catch (error) {
      if (mounted) _showSnack('Login gagal: ${error.message}');
    } catch (error) {
      if (mounted) _showSnack('Login gagal: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showForgotPasswordModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(26).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lupa Password Akun?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: kMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Untuk keamanan rekam medis dan data klinis pasien, reset password akun dilakukan langsung oleh Administrator faskes / RSUD.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: kTextSecondary),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPastelCyan,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.support_agent_rounded, color: kPrimary, size: 22),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Helpdesk Admin Faskes', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: kPrimaryDark)),
                        SizedBox(height: 2),
                        Text('admin@toolbc.id • (021) 555-0199', style: TextStyle(fontSize: 12, color: kTextSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Mengerti', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Illustration Canvas (Screen 1 Reference)
                      const _TopHeroIllustrationCanvas(),
                      const SizedBox(height: 22),

                      // 2. Bold Headline & Subtitle
                      const Text(
                        'Monitoring Pengobatan TBC Lebih Teratur & Tuntas',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.22,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pantau kepatuhan OAT harian, checkup gejala mandiri, dan terhubung langsung dengan dokter penanggung jawab Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: kMuted,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Quick Role Selection Chips
                      Row(
                        children: [
                          _RoleSelectChip(
                            label: 'Pasien',
                            icon: Icons.person_outline_rounded,
                            selected: _selectedRole == 'Pasien',
                            selectedBg: kPastelCyan,
                            selectedFg: kPrimaryDark,
                            onTap: () => _selectRole('Pasien'),
                          ),
                          const SizedBox(width: 8),
                          _RoleSelectChip(
                            label: 'Dokter',
                            icon: Icons.medical_services_outlined,
                            selected: _selectedRole == 'Dokter',
                            selectedBg: kPastelGreen,
                            selectedFg: kSuccess,
                            onTap: () => _selectRole('Dokter'),
                          ),
                          const SizedBox(width: 8),
                          _RoleSelectChip(
                            label: 'Admin',
                            icon: Icons.admin_panel_settings_outlined,
                            selected: _selectedRole == 'Admin',
                            selectedBg: kPastelAmber,
                            selectedFg: kPastelAmberFg,
                            onTap: () => _selectRole('Admin'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 4. Clean Input Fields
                      _NeoCleanField(
                        controller: _emailController,
                        hint: 'Email Akun',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        fieldKey: const ValueKey('auth_email_field'),
                      ),
                      const SizedBox(height: 10),
                      _NeoCleanField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: !_passwordVisible,
                        fieldKey: const ValueKey('auth_password_field'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Bottom Navigation & Action Bar (Screen 1 Layout)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left side: 3-dot indicator + Forgot password
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: kPrimary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 14),
                              InkWell(
                                onTap: _showForgotPasswordModal,
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Right side: Cyan Next / Masuk CTA Button
                          _isLoading
                              ? const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(strokeWidth: 2.8, color: kPrimary),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kPrimary.withValues(alpha: 0.28),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    key: const ValueKey('auth_login_button'),
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Top Hero Canvas with modern illustration
class _TopHeroIllustrationCanvas extends StatelessWidget {
  const _TopHeroIllustrationCanvas();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6F0FA)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background shapes
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 10,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Central Floating Healthcare & Pill Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFEDF2F7)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kPastelCyan,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.health_and_safety_rounded, color: kPrimary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ToolBC Care',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                          ),
                          Text(
                            'DOTS Therapy & Smart AI',
                            style: TextStyle(fontSize: 11, color: kMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusPill(
                        text: 'Fase HRZE',
                        bg: kPastelCyan,
                        fg: kPrimaryDark,
                        icon: Icons.medication_rounded,
                      ),
                      SizedBox(width: 8),
                      StatusPill(
                        text: 'Kepatuhan 98%',
                        bg: kPastelGreen,
                        fg: kSuccess,
                        icon: Icons.verified_rounded,
                      ),
                    ],
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

/// Minimalist Role Selector Chip
class _RoleSelectChip extends StatelessWidget {
  const _RoleSelectChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? selectedBg : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? selectedFg : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? selectedFg : kMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? selectedFg : kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean Minimalist Input Field
class _NeoCleanField extends StatelessWidget {
  const _NeoCleanField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: kMuted, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: kText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          ?suffixIcon,
        ],
      ),
    );
  }
}
