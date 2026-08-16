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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
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
              style: TextStyle(fontSize: 13, height: 1.45, color: kTextSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPastelCyan,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.contact_support_rounded, color: kPrimaryDark, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hubungi Admin Faskes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimaryDark)),
                        SizedBox(height: 2),
                        Text('admin@toolbc.id • (021) 555-0199', style: TextStyle(fontSize: 11.5, color: kTextSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w700)),
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // Top Illustration Canvas (Reference Screen 1)
                const _OnboardingHeroIllustration(),
                const SizedBox(height: 24),

                // Bold Headline & Description (Reference Screen 1)
                const Text(
                  'Monitoring Pengobatan TBC Lebih Teratur & Tuntas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.25,
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

                // Quick Demo Account Switcher
                const Text(
                  'Pilih Peran Akun Masuk:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RoleChip(
                      label: 'Pasien',
                      icon: Icons.person_rounded,
                      selected: _selectedRole == 'Pasien',
                      color: kPastelCyan,
                      fg: kPrimaryDark,
                      onTap: () => _selectRole('Pasien'),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label: 'Dokter',
                      icon: Icons.medical_services_rounded,
                      selected: _selectedRole == 'Dokter',
                      color: kPastelGreen,
                      fg: kSuccess,
                      onTap: () => _selectRole('Dokter'),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label: 'Admin',
                      icon: Icons.admin_panel_settings_rounded,
                      selected: _selectedRole == 'Admin',
                      color: kPastelAmber,
                      fg: kWarning,
                      onTap: () => _selectRole('Admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Clean Minimalist Form Fields
                _CleanInputField(
                  controller: _emailController,
                  hint: 'Email Address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  fieldKey: const ValueKey('auth_email_field'),
                ),
                const SizedBox(height: 12),
                _CleanInputField(
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
                const SizedBox(height: 28),

                // Bottom Controls (Dots Indicator, Lupa Password & Next Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 3 Dots Indicator (from Screen 1 reference)
                        Container(
                          width: 18,
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
                    _isLoading
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2.6, color: kPrimary),
                          )
                        : ElevatedButton(
                            key: const ValueKey('auth_login_button'),
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadowColor: kPrimary.withValues(alpha: 0.3),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeroIllustration extends StatelessWidget {
  const _OnboardingHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circles
          Positioned(
            left: 30,
            top: 20,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 15,
            child: Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Central Medical Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kFloatingShadow,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kPastelCyan,
                      child: Icon(Icons.health_and_safety_rounded, color: kPrimary, size: 20),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ToolBC Care', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: kText)),
                        Text('DOTS & AI Companion', style: TextStyle(fontSize: 10.5, color: kMuted)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusPill(text: 'HRZE Intensif', bg: kPastelCyan, fg: kPrimaryDark, icon: Icons.medication_rounded),
                    SizedBox(width: 8),
                    StatusPill(text: '98% Teratur', bg: kPastelGreen, fg: kSuccess, icon: Icons.verified_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : kSearchBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? fg : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? fg : kMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? fg : kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CleanInputField extends StatelessWidget {
  const _CleanInputField({
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
      height: 50,
      decoration: BoxDecoration(
        color: kSearchBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: kMuted, size: 18),
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
