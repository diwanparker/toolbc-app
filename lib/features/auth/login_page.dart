import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../core/models/app_mode.dart';
import '../../core/services/supabase_service.dart';
import '../../core/widgets/app_shell.dart';

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

  void _openForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ForgotPasswordPage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 900;
            final ultraCompact = constraints.maxHeight < 760;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                ultraCompact ? 24 : 32,
                ultraCompact ? 8 : (compact ? 14 : 18),
                ultraCompact ? 24 : 32,
                ultraCompact ? 4 : (compact ? 8 : 12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LoginHeader(compact: compact, ultraCompact: ultraCompact),
                  SizedBox(height: ultraCompact ? 6 : (compact ? 10 : 14)),
                  _LoginFormCard(
                    compact: compact,
                    ultraCompact: ultraCompact,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    passwordVisible: _passwordVisible,
                    onEmailChanged: (_) => setState(() {}),
                    onTogglePassword: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    onLogin: _openDashboard,
                    onForgotPassword: _openForgotPassword,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FitToViewport extends StatelessWidget {
  const _FitToViewport({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth > padding.horizontal
            ? constraints.maxWidth - padding.horizontal
            : constraints.maxWidth;
        final availableHeight = constraints.maxHeight > padding.vertical
            ? constraints.maxHeight - padding.vertical
            : constraints.maxHeight;

        return Padding(
          padding: padding,
          child: SizedBox(
            width: availableWidth,
            height: availableHeight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(width: availableWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  static const String adminEmail = 'admin@kliniktbc.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: SafeArea(
        child: _FitToViewport(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 220,
                child: CustomPaint(painter: _ForgotPasswordHeroPainter()),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lupa Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF061347),
                ),
              ),
              const SizedBox(height: 22),
              const _MailBadge(),
              const SizedBox(height: 18),
              const Text(
                'Untuk keamanan akun,\nreset password hanya dapat\ndilakukan oleh admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF061347),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Silakan hubungi admin klinik melalui email\ndi bawah ini untuk meminta reset password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.38,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF657697),
                ),
              ),
              const SizedBox(height: 20),
              const _AdminEmailCard(email: adminEmail),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Pastikan email yang terdaftar adalah email\nklinik atau sesuai domain yang digunakan.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF657697),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _BackToLoginButton(onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MailBadge extends StatelessWidget {
  const _MailBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      height: 106,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 52,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB800),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.mail_outline_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _AdminEmailCard extends StatelessWidget {
  const _AdminEmailCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EEF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94BDF1).withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Container(
                width: 42,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF061347),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0065F8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackToLoginButton extends StatelessWidget {
  const _BackToLoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded, size: 28),
        label: const Text('Kembali ke Login'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0065F8),
          side: const BorderSide(color: Color(0xFFBFDBFE), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _ForgotPasswordHeroPainter extends CustomPainter {
  const _ForgotPasswordHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final softBlue = Paint()..color = const Color(0xFFEAF3FF);
    final paleBlue = Paint()
      ..color = const Color(0xFFDCEBFF).withValues(alpha: 0.58);
    final primary = Paint()..color = const Color(0xFF5D88F1);
    final deepBlue = Paint()..color = const Color(0xFF2F66DF);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.72,
        size.width * 0.76,
        size.height * 0.14,
      ),
      Paint()..color = const Color(0xFFDDEBFF).withValues(alpha: 0.46),
    );
    _drawDecorations(canvas, size);
    _drawLeaves(canvas, size);

    final envelopeRect = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.36,
      size.width * 0.50,
      size.height * 0.36,
    );
    final envelopeRRect = RRect.fromRectAndRadius(
      envelopeRect,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      envelopeRRect.shift(const Offset(0, 10)),
      Paint()..color = const Color(0xFF94BDF1).withValues(alpha: 0.18),
    );
    canvas.drawRRect(envelopeRRect, primary);

    final paperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.22,
        size.width * 0.32,
        size.height * 0.34,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      paperRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF8FBFF)],
        ).createShader(paperRect.outerRect),
    );

    final linePaint = Paint()
      ..color = const Color(0xFFBFD3F9)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.30 + i * 0.055);
      final start = size.width * 0.39;
      final end = size.width * (i.isEven ? 0.61 : 0.54);
      canvas.drawLine(Offset(start, y), Offset(end, y), linePaint);
    }

    final leftFlap = Path()
      ..moveTo(envelopeRect.left, envelopeRect.top + 4)
      ..lineTo(envelopeRect.center.dx, envelopeRect.center.dy + 26)
      ..lineTo(envelopeRect.left, envelopeRect.bottom)
      ..close();
    final rightFlap = Path()
      ..moveTo(envelopeRect.right, envelopeRect.top + 4)
      ..lineTo(envelopeRect.center.dx, envelopeRect.center.dy + 26)
      ..lineTo(envelopeRect.right, envelopeRect.bottom)
      ..close();
    final bottomFlap = Path()
      ..moveTo(envelopeRect.left, envelopeRect.bottom)
      ..lineTo(envelopeRect.center.dx, envelopeRect.center.dy + 18)
      ..lineTo(envelopeRect.right, envelopeRect.bottom)
      ..close();
    canvas.drawPath(leftFlap, Paint()..color = const Color(0xFF7FA6F5));
    canvas.drawPath(rightFlap, Paint()..color = const Color(0xFF6C97F2));
    canvas.drawPath(bottomFlap, deepBlue);

    final lockCenter = Offset(size.width * 0.72, size.height * 0.64);
    canvas.drawCircle(
      lockCenter,
      size.width * 0.105,
      Paint()..color = const Color(0xFF4E6FE5),
    );
    final lockPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: lockCenter.translate(0, -6),
        width: 36,
        height: 36,
      ),
      3.16,
      3.10,
      false,
      lockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: lockCenter.translate(0, 10),
          width: 36,
          height: 30,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      lockCenter.translate(0, 8),
      4,
      Paint()..color = const Color(0xFF4E6FE5),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: lockCenter.translate(0, 15),
        width: 4,
        height: 10,
      ),
      Paint()..color = const Color(0xFF4E6FE5),
    );

    _drawPaperPlane(canvas, size, paleBlue);
    _drawSmallCross(
      canvas,
      Offset(size.width * 0.23, size.height * 0.22),
      softBlue.color,
    );
    _drawSmallCross(
      canvas,
      Offset(size.width * 0.78, size.height * 0.28),
      softBlue.color,
    );
    _drawSmallCross(
      canvas,
      Offset(size.width * 0.14, size.height * 0.40),
      softBlue.color,
    );
  }

  void _drawDecorations(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFFD9E8FF);
    for (final point in [
      Offset(size.width * 0.42, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.50),
      Offset(size.width * 0.34, size.height * 0.31),
      Offset(size.width * 0.25, size.height * 0.54),
    ]) {
      canvas.drawCircle(point, 2, dotPaint);
    }
  }

  void _drawLeaves(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFFDDEBFF).withValues(alpha: 0.60);
    for (final item in [
      (Offset(size.width * 0.22, size.height * 0.70), -0.55),
      (Offset(size.width * 0.78, size.height * 0.70), 0.55),
      (Offset(size.width * 0.84, size.height * 0.62), 0.75),
      (Offset(size.width * 0.15, size.height * 0.64), -0.75),
    ]) {
      canvas.save();
      canvas.translate(item.$1.dx, item.$1.dy);
      canvas.rotate(item.$2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 24, height: 88),
        leafPaint,
      );
      canvas.restore();
    }
  }

  void _drawPaperPlane(Canvas canvas, Size size, Paint paint) {
    final plane = Path()
      ..moveTo(size.width * 0.70, size.height * 0.12)
      ..lineTo(size.width * 0.82, size.height * 0.05)
      ..lineTo(size.width * 0.77, size.height * 0.20)
      ..lineTo(size.width * 0.74, size.height * 0.13)
      ..lineTo(size.width * 0.70, size.height * 0.12);
    canvas.drawPath(plane, Paint()..color = const Color(0xFF8FB7FA));
    final dashPaint = Paint()
      ..color = const Color(0xFFB7D1FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.78, size.height * 0.20)
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.34,
        size.width * 0.62,
        size.height * 0.25,
        size.width * 0.66,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.54,
        size.width * 0.88,
        size.height * 0.42,
        size.width * 0.86,
        size.height * 0.56,
      );
    canvas.drawPath(path, dashPaint);
  }

  void _drawSmallCross(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center.translate(-6, 0), center.translate(6, 0), paint);
    canvas.drawLine(center.translate(0, -6), center.translate(0, 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.compact, required this.ultraCompact});

  final bool compact;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ultraCompact ? 160 : (compact ? 190 : 226),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF7FBFF), Color(0xFFEAF4FF)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: ultraCompact ? 12 : (compact ? 18 : 28),
            child: const _MiniShield(),
          ),
          Positioned(
            left: 22,
            top: ultraCompact ? 64 : (compact ? 78 : 110),
            child: Text(
              'Welcome\nback!',
              style: TextStyle(
                fontSize: ultraCompact ? 24 : (compact ? 28 : 36),
                height: 1.12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF14224A),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: ultraCompact ? 118 : (compact ? 144 : 198),
            child: Text(
              'Sign in to manage\nyour TBC.',
              style: TextStyle(
                fontSize: ultraCompact ? 12.5 : (compact ? 15 : 20),
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF657697),
              ),
            ),
          ),
          Positioned(
            right: ultraCompact ? -8 : (compact ? -12 : -8),
            top: ultraCompact ? 8 : (compact ? 18 : 30),
            child: SizedBox(
              width: ultraCompact ? 124 : (compact ? 152 : 212),
              height: ultraCompact ? 116 : (compact ? 142 : 194),
              child: const CustomPaint(painter: _MedicalHeroPainter()),
            ),
          ),
          Positioned(
            right: ultraCompact ? 92 : (compact ? 112 : 144),
            top: ultraCompact ? 6 : 12,
            child: _DotMatrix(tight: ultraCompact),
          ),
        ],
      ),
    );
  }
}

class _MiniShield extends StatelessWidget {
  const _MiniShield();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(46, 52),
      painter: _ShieldPainter(),
      child: const SizedBox(
        width: 46,
        height: 52,
        child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class _DotMatrix extends StatelessWidget {
  const _DotMatrix({this.tight = false});

  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tight ? 10 : 14,
      runSpacing: tight ? 10 : 14,
      children: List.generate(
        16,
        (_) => Container(
          width: tight ? 5 : 7,
          height: tight ? 5 : 7,
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.compact,
    required this.ultraCompact,
    required this.emailController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onEmailChanged,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  final bool compact;
  final bool ultraCompact;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        ultraCompact ? 18 : 24,
        ultraCompact ? 12 : (compact ? 18 : 24),
        ultraCompact ? 18 : 24,
        ultraCompact ? 16 : (compact ? 24 : 30),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94BDF1).withValues(alpha: 0.18),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AuthFieldLabel('Email Address'),
          SizedBox(height: ultraCompact ? 4 : (compact ? 6 : 11)),
          _ReferenceAuthField(
            height: ultraCompact ? 44 : (compact ? 50 : 62),
            hintText: 'nama@pasien.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: emailController,
            onChanged: onEmailChanged,
            fieldKey: const ValueKey('auth_email_field'),
          ),
          SizedBox(height: ultraCompact ? 10 : (compact ? 18 : 28)),
          const _AuthFieldLabel('Password'),
          SizedBox(height: ultraCompact ? 4 : (compact ? 6 : 11)),
          _ReferenceAuthField(
            height: ultraCompact ? 44 : (compact ? 50 : 62),
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: passwordController,
            obscureText: !passwordVisible,
            fieldKey: const ValueKey('auth_password_field'),
            suffixIcon: IconButton(
              tooltip: passwordVisible
                  ? 'Sembunyikan password'
                  : 'Lihat password',
              onPressed: onTogglePassword,
              icon: Icon(
                passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF75829B),
                size: 26,
              ),
            ),
          ),
          SizedBox(height: ultraCompact ? 4 : (compact ? 8 : 14)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF005FEA),
                padding: EdgeInsets.zero,
                minimumSize: Size(0, ultraCompact ? 24 : (compact ? 28 : 36)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa password?',
                style: TextStyle(
                  fontSize: ultraCompact ? 12 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: ultraCompact ? 10 : (compact ? 14 : 22)),
          SizedBox(
            width: double.infinity,
            height: ultraCompact ? 42 : (compact ? 48 : 62),
            child: ElevatedButton(
              key: const ValueKey('auth_login_button'),
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0065F8),
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: const Color(0xFF0065F8).withValues(alpha: 0.26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Login'),
            ),
          ),
          SizedBox(height: ultraCompact ? 12 : (compact ? 18 : 28)),
          _AccessHelpCard(compact: compact, ultraCompact: ultraCompact),
          if (!ultraCompact) ...[
            SizedBox(height: compact ? 18 : 24),
            const _DomainDivider(),
            SizedBox(height: compact ? 10 : 16),
            _DomainChips(compact: compact),
          ],
        ],
      ),
    );
  }
}

class _ReferenceAuthField extends StatelessWidget {
  const _ReferenceAuthField({
    this.height = 66,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.fieldKey,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
  });

  final double height;
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
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5DDEB), width: 1.2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: height - 12,
            height: height - 12,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(prefixIcon, color: const Color(0xFF0065F8), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF8C98AE),
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14224A),
              ),
            ),
          ),
          ?suffixIcon,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AccessHelpCard extends StatelessWidget {
  const _AccessHelpCard({required this.compact, required this.ultraCompact});

  final bool compact;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        ultraCompact ? 14 : 18,
        ultraCompact ? 8 : (compact ? 10 : 16),
        ultraCompact ? 12 : 16,
        ultraCompact ? 8 : (compact ? 10 : 16),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: ultraCompact ? 30 : (compact ? 34 : 42),
            height: ultraCompact ? 30 : (compact ? 34 : 42),
            decoration: BoxDecoration(
              color: kPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
              size: ultraCompact ? 18 : 24,
            ),
          ),
          SizedBox(width: ultraCompact ? 10 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum memiliki akun?',
                  style: TextStyle(
                    fontSize: ultraCompact ? 11.5 : (compact ? 13 : 16),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF14224A),
                  ),
                ),
                SizedBox(height: ultraCompact ? 2 : 4),
                Text(
                  'Silakan hubungi admin untuk\nmendapatkan akses.',
                  style: TextStyle(
                    fontSize: ultraCompact ? 10 : (compact ? 11.5 : 14),
                    height: ultraCompact ? 1.25 : 1.4,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF657697),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: ultraCompact ? 34 : (compact ? 44 : 62),
            height: ultraCompact ? 34 : (compact ? 44 : 62),
            child: const CustomPaint(painter: _SupportAgentPainter()),
          ),
        ],
      ),
    );
  }
}

class _DomainDivider extends StatelessWidget {
  const _DomainDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFDCE4F0), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Format email yang valid',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF657697),
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFDCE4F0), thickness: 1)),
      ],
    );
  }
}

class _DomainChips extends StatelessWidget {
  const _DomainChips({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DomainChip('@pasien.com', compact: compact),
        const SizedBox(width: 10),
        _DomainChip('@dokter.com', compact: compact),
        const SizedBox(width: 10),
        _DomainChip('@admin.com', compact: compact),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip(this.text, {required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 26 : 34),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 13,
          vertical: compact ? 5 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10.5 : 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF657697),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3F7DF1), Color(0xFF0065F8)],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.50, size.height * 0.02)
      ..lineTo(size.width * 0.90, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.94,
        size.height * 0.18,
        size.width * 0.94,
        size.height * 0.25,
      )
      ..lineTo(size.width * 0.90, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.78,
        size.width * 0.50,
        size.height * 0.96,
      )
      ..quadraticBezierTo(
        size.width * 0.14,
        size.height * 0.78,
        size.width * 0.10,
        size.height * 0.58,
      )
      ..lineTo(size.width * 0.06, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.06,
        size.height * 0.18,
        size.width * 0.10,
        size.height * 0.16,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MedicalHeroPainter extends CustomPainter {
  const _MedicalHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFDCEBFF).withValues(alpha: 0.72);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.18,
        size.width * 0.62,
        size.height * 0.72,
      ),
      bgPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.02,
        size.height * 0.68,
        size.width * 0.88,
        size.height * 0.20,
      ),
      Paint()..color = const Color(0xFFD4E6FF).withValues(alpha: 0.55),
    );

    _drawClipboard(canvas, size);
    _drawLungs(canvas, size);
    _drawBottle(canvas, size);
    _drawLeaves(canvas, size);
    _drawPills(canvas, size);
  }

  void _drawClipboard(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.55,
        size.height * 0.26,
        size.width * 0.30,
        size.height * 0.52,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      rect.shift(const Offset(3, 5)),
      Paint()..color = const Color(0xFF94BDF1).withValues(alpha: 0.25),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF196BEA),
    );

    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.62,
        size.height * 0.20,
        size.width * 0.17,
        size.height * 0.09,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(clipRect, Paint()..color = const Color(0xFF1467DF));
    canvas.drawCircle(
      Offset(size.width * 0.705, size.height * 0.205),
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF1467DF),
    );

    final plus = Paint()
      ..color = const Color(0xFF3D82F4)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width * 0.70, size.height * 0.42);
    canvas.drawLine(center.translate(-10, 0), center.translate(10, 0), plus);
    canvas.drawLine(center.translate(0, -10), center.translate(0, 10), plus);

    final checkPaint = Paint()
      ..color = const Color(0xFF1265DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..color = const Color(0xFFB7CAE4)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.53 + i * 0.11);
      final path = Path()
        ..moveTo(size.width * 0.60, y)
        ..lineTo(size.width * 0.63, y + 7)
        ..lineTo(size.width * 0.67, y - 8);
      canvas.drawPath(path, checkPaint);
      canvas.drawLine(
        Offset(size.width * 0.70, y),
        Offset(size.width * 0.80, y),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.70, y + 9),
        Offset(size.width * 0.76, y + 9),
        linePaint,
      );
    }
  }

  void _drawLungs(Canvas canvas, Size size) {
    final lungPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF69A9FF), Color(0xFF0065F8)],
          ).createShader(
            Rect.fromLTWH(
              size.width * 0.20,
              size.height * 0.34,
              size.width * 0.38,
              size.height * 0.45,
            ),
          );
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final left = Path()
      ..moveTo(size.width * 0.38, size.height * 0.37)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.36,
        size.width * 0.20,
        size.height * 0.60,
        size.width * 0.24,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.76,
        size.width * 0.42,
        size.height * 0.64,
        size.width * 0.40,
        size.height * 0.48,
      )
      ..close();
    final right = Path()
      ..moveTo(size.width * 0.43, size.height * 0.37)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.36,
        size.width * 0.58,
        size.height * 0.60,
        size.width * 0.54,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.75,
        size.width * 0.39,
        size.height * 0.64,
        size.width * 0.41,
        size.height * 0.48,
      )
      ..close();
    canvas.drawPath(left, lungPaint);
    canvas.drawPath(right, lungPaint);

    final trachea = Paint()
      ..color = const Color(0xFFEAF3FF)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.405, size.height * 0.20),
      Offset(size.width * 0.405, size.height * 0.43),
      trachea,
    );
    canvas.drawLine(
      Offset(size.width * 0.405, size.height * 0.43),
      Offset(size.width * 0.33, size.height * 0.55),
      trachea,
    );
    canvas.drawLine(
      Offset(size.width * 0.405, size.height * 0.43),
      Offset(size.width * 0.49, size.height * 0.55),
      trachea,
    );
    canvas.drawLine(
      Offset(size.width * 0.31, size.height * 0.58),
      Offset(size.width * 0.24, size.height * 0.66),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.59),
      Offset(size.width * 0.29, size.height * 0.72),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.49, size.height * 0.58),
      Offset(size.width * 0.55, size.height * 0.67),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.59),
      Offset(size.width * 0.51, size.height * 0.72),
      stroke,
    );
  }

  void _drawBottle(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.80,
        size.height * 0.60,
        size.width * 0.16,
        size.height * 0.25,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF3D82F4));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.83,
        size.height * 0.54,
        size.width * 0.10,
        size.height * 0.07,
      ),
      Paint()..color = const Color(0xFFEAF3FF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.80,
          size.height * 0.51,
          size.width * 0.16,
          size.height * 0.05,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white,
    );
    final plus = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width * 0.88, size.height * 0.72);
    canvas.drawLine(center.translate(-8, 0), center.translate(8, 0), plus);
    canvas.drawLine(center.translate(0, -8), center.translate(0, 8), plus);
  }

  void _drawLeaves(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF69C995);
    canvas.save();
    canvas.translate(size.width * 0.92, size.height * 0.52);
    canvas.rotate(-0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 54),
      paint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(size.width * 0.97, size.height * 0.62);
    canvas.rotate(0.8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 48),
      paint,
    );
    canvas.restore();
  }

  void _drawPills(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D82F4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.63,
          size.height * 0.78,
          size.width * 0.15,
          size.height * 0.06,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.82),
      8,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SupportAgentPainter extends CustomPainter {
  const _SupportAgentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF6EA5FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0xFFE7F1FF);

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.38),
      size.width * 0.22,
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.38),
      size.width * 0.22,
      stroke,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.18,
        size.width * 0.64,
        size.height * 0.50,
      ),
      3.35,
      2.75,
      false,
      stroke,
    );
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.46), 6, fill);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.46), 6, fill);
    canvas.drawCircle(Offset(size.width * 0.43, size.height * 0.38), 2, stroke);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 0.38), 2, stroke);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.42,
        size.width * 0.16,
        size.height * 0.10,
      ),
      0.1,
      2.8,
      false,
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.60),
      Offset(size.width * 0.50, size.height * 0.74),
      stroke,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.20,
        size.height * 0.64,
        size.width * 0.60,
        size.height * 0.56,
      ),
      3.25,
      3.1,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
