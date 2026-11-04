import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Contenedor de exhibición para navegadores de escritorio (Desktop / Web).
/// Muestra un panel lateral de presentación profesional con los datos de Tobías
/// y el stack técnico, acompañado del dispositivo móvil interactivo centrado.
class DesktopShowcaseWrapper extends StatelessWidget {
  final Widget child;

  const DesktopShowcaseWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (!isDesktop) {
          // Vista Móvil / Tablet estándar a pantalla completa
          return Container(
            color: const Color(0xFF131A17),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: child,
              ),
            ),
          );
        }

        // Vista Desktop Showcase (Tarjeta de Portfolio a la izquierda + Celular interactivo a la derecha)
        final double phoneHeight = (constraints.maxHeight - 48).clamp(
          650.0,
          880.0,
        );

        return Container(
          color: const Color(0xFF0C100E),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Columna izquierda: Información del proyecto y perfil de Tobías
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildShowcaseSidebar(context),
                  ),

                  const SizedBox(width: 52),

                  // Columna derecha: Mockup interactivo del dispositivo móvil
                  Container(
                    width: 410,
                    height: phoneHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(38),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentLimeColor.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.70),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowcaseSidebar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag / Badge superior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentLimeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentLimeColor.withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎾', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Mobile Engineering Showcase',
                style: TextStyle(
                  color: AppTheme.accentLimeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'SetPoint',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Mobile Tennis Matchmaking Platform',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // Perfil del Desarrollador
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141B18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentLimeColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppTheme.accentLimeColor.withValues(alpha: 0.5),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'TG',
                    style: TextStyle(
                      color: AppTheme.accentLimeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tobías Gutiérrez',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mobile Software Engineer',
                      style: TextStyle(
                        color: AppTheme.accentLimeColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Computer Science & Engineering — FIUBA',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Stack & Architecture',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTechChip('Clean Architecture'),
            _buildTechChip('BLoC 8.1 Pattern'),
            _buildTechChip('Dart 3 Strict Typing'),
            _buildTechChip('24 Unit & BLoC Tests'),
            _buildTechChip('OpenStreetMap + Clustering'),
            _buildTechChip('Dark Glassmorphism UI'),
            _buildTechChip('100% Offline Resilient'),
          ],
        ),

        const SizedBox(height: 24),

        // Hint interactivo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentLimeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.accentLimeColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Interactive Live Demo: The phone device on the right is fully functional. Browse matches, toggle list/map views, apply multi-criteria filters, and create or manage matches.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Enlace al repositorio
        Row(
          children: [
            Icon(
              Icons.code_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'github.com/TobiShakur/flutter-tennis-matchmaking',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF161E1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
