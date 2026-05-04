part of flutter_tbc;

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi.')),
      );
      return;
    }
    if (!(email.endsWith('@pasien.com') || email.endsWith('@dokter.com') || email.endsWith('@admin.com'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email akun baru harus @pasien.com, @dokter.com, atau @admin.com.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sama.')),
      );
      return;
    }

    if (!SupabaseService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase belum dikonfigurasi. Isi SUPABASE_URL dan SUPABASE_ANON_KEY dulu.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await SupabaseService.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat.')),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat akun: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat akun: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            const SizedBox(height: 12),
            const Text('Change your password', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, height: 1.3, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: Color(0xFF1D4ED8))),
            const SizedBox(height: 10),
            const Text('Create a new account for patient, doctor, or admin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF424752))),
            const SizedBox(height: 24),
            _AuthField(hintText: 'Full Name', prefixIcon: Icons.person_outline_rounded, controller: _fullNameController),
            const SizedBox(height: 14),
            _AuthField(hintText: 'Email Address', prefixIcon: Icons.mail_outline_rounded, controller: _emailController),
            const SizedBox(height: 14),
            _AuthField(hintText: 'Password', prefixIcon: Icons.lock_outline_rounded, controller: _passwordController, obscureText: true),
            const SizedBox(height: 14),
            _AuthField(hintText: 'Confirm Password', prefixIcon: Icons.lock_outline_rounded, controller: _confirmPasswordController, obscureText: true),
            const SizedBox(height: 14),
            const Text('Email akun baru wajib berakhiran @pasien.com, @dokter.com, atau @admin.com.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B57D0),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_submitting ? 'Creating...' : 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text('Already have an account?', style: TextStyle(fontSize: 14, color: Color(0xFF424752))),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B57D0), padding: EdgeInsets.zero),
                    child: const Text('Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Only admin can create new accounts for patients and doctors.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}
