import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import 'onboarding_carousel_screen.dart';

// PANTALLA 1: BIENVENIDA INICIAL (ESTILO SETPOINT TENNIS)
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onFinishOnboarding;

  const WelcomeScreen({super.key, required this.onFinishOnboarding});

  void _irAlCarousel(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingCarouselScreen(onFinish: onFinishOnboarding),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2419), // Verde profundo deportivo
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F3625),
                    Color(0xFF0B241A),
                    Color(0xFF081811),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(220, 220),
                painter: _TennisOrganicShapePainter(),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // TÍTULO "Welcome to"
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // MARCA "SetPoint"
                  Row(
                    children: [
                      Text(
                        'SetPoint',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentLimeColor,
                          letterSpacing: -1.2,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: AppTheme.accentLimeColor.withValues(
                                alpha: 0.45,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppTheme.accentLimeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentLimeColor.withValues(
                                alpha: 0.8,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // SUBTÍTULO
                  const Text(
                    '¿Sos nuevo acá? / Crear Cuenta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // BOTÓN 1: LOGIN WITH APPLE
                  _buildSocialAuthButton(
                    context: context,
                    icon: FontAwesomeIcons.apple,
                    text: 'Continuar con Apple',
                    onTap: () => _irAlCarousel(context),
                  ),

                  const SizedBox(height: 14),

                  // BOTÓN 2: LOGIN WITH GOOGLE
                  _buildSocialAuthButton(
                    context: context,
                    icon: FontAwesomeIcons.google,
                    text: 'Continuar con Google',
                    onTap: () => _irAlCarousel(context),
                  ),

                  const SizedBox(height: 24),

                  // BOTÓN 3: CONTINUAR COMO INVITADO
                  Center(
                    child: GestureDetector(
                      onTap: () => _irAlCarousel(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continuar como invitado',
                              style: TextStyle(
                                color: AppTheme.accentLimeColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppTheme.accentLimeColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAuthButton({
    required BuildContext context,
    required FaIconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0E1311),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 20, color: const Color(0xFF0E1311)),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: Color(0xFF0E1311),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter para recrear la curva dinámica superior del diseño de tenis de referencia
class _TennisOrganicShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8E652).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.4, 0)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.3,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = const Color(0xFFC8E652).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final loopPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.4)
      ..cubicTo(
        size.width * 0.6,
        size.height * 0.3,
        size.width * 0.75,
        size.height * 0.35,
        size.width * 0.7,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.55,
        size.width * 0.85,
        size.height * 0.45,
        size.width * 0.95,
        size.height * 0.55,
      );

    canvas.drawPath(loopPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
