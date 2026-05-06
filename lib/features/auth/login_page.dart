import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_mode.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/ui_components.dart';

enum _DomainRole { patient, doctor, admin, invalid }

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openDashboard() async {
    final role = _resolveRole(_emailController.text);
    if (role == _DomainRole.invalid) {
      _showSnack('Gunakan akun @admin.com, @dokter.com, atau @pasien.com.');
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      _showSnack('Password wajib diisi.');
      return;
    }

    if (SupabaseService.isConfigured) {
      try {
        await SupabaseService.signIn(
          email: _emailController.text.trim(),
          password: password,
        );
      } on AuthException catch (error) {
        if (mounted) _showSnack('Login gagal: ${error.message}');
        return;
      } catch (error) {
        if (mounted) _showSnack('Login gagal: $error');
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AppShell(initialMode: _toAppMode(role)),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  _DomainRole _resolveRole(String email) {
    final value = email.trim().toLowerCase();
    if (value.endsWith('@admin.com')) return _DomainRole.admin;
    if (value.endsWith('@dokter.com')) return _DomainRole.doctor;
    if (value.endsWith('@pasien.com')) return _DomainRole.patient;
    return _DomainRole.invalid;
  }

  AppMode _toAppMode(_DomainRole role) {
    switch (role) {
      case _DomainRole.patient:
        return AppMode.patient;
      case _DomainRole.doctor:
        return AppMode.doctor;
      case _DomainRole.admin:
        return AppMode.admin;
      case _DomainRole.invalid:
        return AppMode.patient;
    }
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

  @override
  Widget build(BuildContext context) {
    final role = _resolveRole(_emailController.text);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  children: const [
                    _LoginAvatar(),
                    SizedBox(height: 20),
                    Text(
                      'Welcome!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sign in to manage your TBC.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AuthFieldLabel('Email Address'),
                    const SizedBox(height: 10),
                    AuthField(
                      hintText:
                          'nama@pasien.com / nama@dokter.com / nama@admin.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      fieldKey: const ValueKey('auth_email_field'),
                    ),
                    const SizedBox(height: 18),
                    const _AuthFieldLabel('Password'),
                    const SizedBox(height: 10),
                    AuthField(
                      hintText: '********',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      fieldKey: const ValueKey('auth_password_field'),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF9CA3AF),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Center(
                      child: Text(
                        'Belum punya akun? Minta admin/resepsionis membuat akun pasien atau dokter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF424752),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        role == _DomainRole.invalid
                            ? 'Format akun: @pasien.com, @dokter.com, atau @admin.com.'
                            : 'Akun terdeteksi sebagai ${_roleLabel(role)}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Admin membuat akun baru dari dashboard setelah login.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
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

class _LoginAvatar extends StatelessWidget {
  const _LoginAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Center(
        child: Text(
          'T',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}

class _AuthFieldLabel extends StatelessWidget {
  const _AuthFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }
}
