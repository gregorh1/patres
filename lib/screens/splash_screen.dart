import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patres/blocs/library_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Style status bar to match splash
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF5E6D3),
    ));

    // Load library data then navigate
    context.read<LibraryBloc>().add(LibraryLoadRequested());
    _waitAndNavigate();
  }

  Future<void> _waitAndNavigate() async {
    // Minimum splash display of 1.5s for branding
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1A1512) : const Color(0xFFF5E6D3);
    final iconColor =
        isDark ? const Color(0xFFD4A0A0) : const Color(0xFF6D4C2A);
    final textColor =
        isDark ? const Color(0xFFE8DDD4) : const Color(0xFF3E2C1C);
    final spinnerColor =
        isDark ? const Color(0xFF8C7B6E) : const Color(0xFF6D4C2A);

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: bgColor,
        ),
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cross + book icon
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _SplashIconPainter(
                        primaryColor: iconColor,
                        accentColor: isDark
                            ? const Color(0xFFB88E3A)
                            : const Color(0xFFB88E3A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App name
                  Text(
                    'Patres',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 6,
                      color: textColor,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ojcowie Kościoła',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                      color: textColor.withValues(alpha: 0.6),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(spinnerColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashIconPainter extends CustomPainter {
  _SplashIconPainter({required this.primaryColor, required this.accentColor});

  final Color primaryColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final brownPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Cross - vertical beam
    final verticalOuter = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 18, height: 70),
      const Radius.circular(2),
    );
    canvas.drawRRect(verticalOuter, brownPaint);

    final verticalInner = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 12, height: 64),
      const Radius.circular(1),
    );
    canvas.drawRRect(verticalInner, goldPaint);

    // Cross - horizontal beam
    final horizontalOuter = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 22), width: 52, height: 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(horizontalOuter, brownPaint);

    final horizontalInner = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 22), width: 46, height: 12),
      const Radius.circular(1),
    );
    canvas.drawRRect(horizontalInner, goldPaint);

    // Book base - left page
    final leftPage = Path()
      ..moveTo(cx - 28, cy + 26)
      ..lineTo(cx - 2, cy + 26)
      ..lineTo(cx - 2, cy + 55)
      ..lineTo(cx - 28, cy + 52)
      ..close();
    canvas.drawPath(leftPage, Paint()..color = accentColor.withValues(alpha: 0.5));

    // Book base - right page
    final rightPage = Path()
      ..moveTo(cx + 2, cy + 26)
      ..lineTo(cx + 28, cy + 26)
      ..lineTo(cx + 28, cy + 52)
      ..lineTo(cx + 2, cy + 55)
      ..close();
    canvas.drawPath(rightPage, Paint()..color = accentColor.withValues(alpha: 0.5));

    // Book spine
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 40), width: 4, height: 30),
      brownPaint,
    );

    // Page lines on left
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.8;
    for (var i = 0; i < 3; i++) {
      final y = cy + 33 + i * 6.0;
      canvas.drawLine(Offset(cx - 22, y), Offset(cx - 6, y), linePaint);
    }
    // Page lines on right
    for (var i = 0; i < 3; i++) {
      final y = cy + 33 + i * 6.0;
      canvas.drawLine(Offset(cx + 6, y), Offset(cx + 22, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
