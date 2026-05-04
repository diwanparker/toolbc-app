part of flutter_tbc;

enum _DomainRole { patient, doctor, admin, invalid }

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  _DomainRole _resolveRole(String email) {
    final value = email.trim().toLowerCase();
    if (value.endsWith('@admin.com')) return _DomainRole.admin;
    if (value.endsWith('@dokter.com')) return _DomainRole.doctor;
    if (value.endsWith('@pasien.com')) return _DomainRole.patient;
    return _DomainRole.invalid;
  }

  String _roleLabel(_DomainRole role) {
    switch (role) {
      case _DomainRole.admin:
        return 'admin';
      case _DomainRole.doctor:
        return 'dokter';
      case _DomainRole.patient:
        return 'pasien';
      case _DomainRole.invalid:
        return 'tidak valid';
    }
  }

  Future<void> _openDashboard() async {
    final role = _resolveRole(_emailController.text);
    if (role == _DomainRole.invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gunakan akun @admin.com, @dokter.com, atau @pasien.com.')),
      );
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password wajib diisi.')),
      );
      return;
    }

    if (SupabaseService.isConfigured) {
      try {
        await SupabaseService.signIn(
          email: _emailController.text.trim(),
          password: password,
        );
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${e.message}')),
        );
        return;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
        return;
      }
    }

    final initialMode = switch (role) {
      _DomainRole.patient => AppMode.patient,
      _DomainRole.doctor => AppMode.doctor,
      _DomainRole.admin => AppMode.admin,
      _DomainRole.invalid => AppMode.patient,
    };
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => AppShell(initialMode: initialMode)),
    );
  }

  void _openRegister() {
    if (_resolveRole(_emailController.text) != _DomainRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register hanya tersedia untuk akun @admin.com.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AuthRegisterPage()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = _resolveRole(_emailController.text);
    final isAdmin = role == _DomainRole.admin;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(999)),
                      child: const Center(
                        child: Text('T', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Welcome!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    const SizedBox(height: 10),
                    const Text('Sign in to manage your TBC.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.2, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const SizedBox(height: 10),
                    _AuthField(
                      hintText: 'nama@pasien.com / nama@dokter.com / nama@admin.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      fieldKey: const ValueKey('auth_email_field'),
                    ),
                    const SizedBox(height: 18),
                    const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const SizedBox(height: 10),
                    _AuthField(
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_passwordVisible,
                      controller: _passwordController,
                      fieldKey: const ValueKey('auth_password_field'),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        key: const ValueKey('auth_login_button'),
                        onPressed: _openDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B57D0),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          const Text('Don\'t have an account?', style: TextStyle(fontSize: 14, color: Color(0xFF424752))),
                          TextButton(
                            onPressed: isAdmin ? _openRegister : null,
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B57D0), padding: EdgeInsets.zero),
                            child: const Text('Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        role == _DomainRole.invalid
                            ? 'Format akun: @pasien.com, @dokter.com, atau @admin.com.'
                            : 'Akun terdeteksi sebagai ${_roleLabel(role)}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ),
                    if (isAdmin)
                      const Center(
                        child: Text('Admin dapat membuat akun baru dari halaman register.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.fieldKey,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
  });

  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final Key? fieldKey;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
