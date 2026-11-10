import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../widgets/auth_brand_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api, required this.onSignedIn});
  final ApiClient api;
  final Future<void> Function() onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _registering = false;
  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_registering) {
        await widget.api.register(_name.text, _email.text, _password.text);
      } else {
        await widget.api.login(_email.text, _password.text);
      }
      await widget.onSignedIn();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth >= 960;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Tech Background on the right (with Dot Grid, Aurora Glows & Radar Ripples)
          Positioned(
            left: wide ? screenWidth * 0.44 : 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: _AuthBackgroundDecor(wide: wide),
          ),

          // Fluid Organic Wave Brand Panel on the left
          if (wide)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: screenWidth * 0.48 + 35,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipPath(
                      clipper: const _OrganicWaveClipper(),
                      child: const AuthBrandPanel(),
                    ),
                  ),
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: _OrganicWaveBorderPainter(),
                    ),
                  ),
                ],
              ),
            ),

          SafeArea(
            child: Align(
              alignment: wide ? Alignment.centerRight : Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? screenWidth * 0.07 : 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.05),
                          blurRadius: 60,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand Logo Header
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0F62FE), Color(0xFF00D2FF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0F62FE).withValues(alpha: 0.28),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.water_drop_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'PONDORA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.3,
                                            fontSize: 19,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: const Text(
                                            'AI & IoT',
                                            style: TextStyle(
                                              color: Color(0xFF0284C7),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'SMART AQUACULTURE SYSTEM',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Switcher Tabs
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _authTabButton(
                                      label: 'Đăng nhập',
                                      active: !_registering,
                                      onTap: () => setState(() {
                                        _registering = false;
                                        _error = null;
                                      }),
                                    ),
                                  ),
                                  Expanded(
                                    child: _authTabButton(
                                      label: 'Đăng ký',
                                      active: _registering,
                                      onTap: () => setState(() {
                                        _registering = true;
                                        _error = null;
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            if (_registering) ...[
                              TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Tên hiển thị',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (v) =>
                                    _registering &&
                                        (v == null || v.trim().isEmpty)
                                    ? 'Vui lòng nhập tên hiển thị.'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                            ],

                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: (v) => v == null || !v.contains('@')
                                  ? 'Vui lòng nhập email hợp lệ.'
                                  : null,
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _password,
                              obscureText: _hidePassword,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Vui lòng nhập mật khẩu.'
                                  : (_registering && v.length < 8
                                        ? 'Mật khẩu cần ít nhất 8 ký tự.'
                                        : null),
                            ),

                            if (_registering) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                obscureText: _hideConfirm,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Xác nhận mật khẩu',
                                  prefixIcon: const Icon(Icons.verified_user_outlined),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _hideConfirm = !_hideConfirm,
                                    ),
                                    icon: Icon(
                                      _hideConfirm
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (v) => v != _password.text
                                    ? 'Mật khẩu xác nhận chưa khớp.'
                                    : null,
                              ),
                            ],

                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: Color(0xFFB91C1C),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                onPressed: _busy ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F62FE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _busy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _registering ? 'Tạo tài khoản' : 'Đăng nhập',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Center(
                              child: Text(
                                'Hệ thống bảo vệ dữ liệu với chuẩn mã hóa BCrypt',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authTabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) => Material(
    color: active ? Colors.white : Colors.transparent,
    borderRadius: BorderRadius.circular(11),
    elevation: active ? 1 : 0,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? const Color(0xFF0F62FE) : const Color(0xFF64748B),
          ),
        ),
      ),
    ),
  );
}

class _AuthBackgroundDecor extends StatelessWidget {
  const _AuthBackgroundDecor({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Tech Dot Grid Pattern
          const Positioned.fill(
            child: CustomPaint(
              painter: _TechDotGridPainter(),
            ),
          ),

          // 2. Ultrasonic Water Sensor Ripple Rings
          const Positioned.fill(
            child: CustomPaint(
              painter: _RadarRipplesPainter(),
            ),
          ),

          // 3. Radiant Aurora Glow Orbs
          // Top-right Cyan Orb
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.20),
                    const Color(0xFF00D2FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Center Sapphire Halo behind card
          Positioned(
            top: 140,
            left: 20,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F62FE).withValues(alpha: 0.12),
                    const Color(0xFF0F62FE).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-right Emerald Aqua Orb
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.10),
                    const Color(0xFF10B981).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Tech Badges (Wide screen highlights)
          if (wide) ...[
            // Top floating badge
            Positioned(
              top: 36,
              right: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.5,
                      height: 7.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.sensors_rounded, color: Color(0xFF0284C7), size: 15),
                    const SizedBox(width: 6),
                    const Text(
                      'Hệ thống cảm biến IoT sẵn sàng',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom floating badge
            Positioned(
              bottom: 28,
              right: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 15),
                    SizedBox(width: 7),
                    Text(
                      'Bảo mật mã hóa chuẩn BCrypt & JWT',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TechDotGridPainter extends CustomPainter {
  const _TechDotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarRipplesPainter extends CustomPainter {
  const _RadarRipplesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.65, size.height * 0.48);
    final paint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 180, paint);
    canvas.drawCircle(center, 320, paint);
    canvas.drawCircle(center, 480, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrganicWaveClipper extends CustomClipper<Path> {
  const _OrganicWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width - 25, 0);

    // Continuous, smooth water wave S-curve
    final cp1 = Offset(size.width + 15, size.height * 0.22);
    final mid = Offset(size.width - 25, size.height * 0.50);
    final cp2 = Offset(size.width - 55, size.height * 0.72);
    final end = Offset(size.width - 15, size.height);

    path.quadraticBezierTo(cp1.dx, cp1.dy, mid.dx, mid.dy);
    path.quadraticBezierTo(cp2.dx, cp2.dy, end.dx, end.dy);

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OrganicWaveBorderPainter extends CustomPainter {
  const _OrganicWaveBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width - 25, 0);

    final cp1 = Offset(size.width + 15, size.height * 0.22);
    final mid = Offset(size.width - 25, size.height * 0.50);
    final cp2 = Offset(size.width - 55, size.height * 0.72);
    final end = Offset(size.width - 15, size.height);

    path.quadraticBezierTo(cp1.dx, cp1.dy, mid.dx, mid.dy);
    path.quadraticBezierTo(cp2.dx, cp2.dy, end.dx, end.dy);

    // 1. Soft atmospheric blue shadow cast onto the right canvas
    final shadowPaint = Paint()
      ..color = const Color(0xFF072349).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(path, shadowPaint);

    // 2. Focused cyan water shimmer glow
    final cyanGlowPaint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, cyanGlowPaint);

    // 3. Crisp, delicate gradient waterline
    final linePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF38BDF8),
          Color(0xFF00D2FF),
          Color(0xFF34D399),
          Color(0xFF0F62FE),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


