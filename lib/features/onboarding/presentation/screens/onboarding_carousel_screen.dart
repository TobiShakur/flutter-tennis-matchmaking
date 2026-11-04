import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// PANTALLA 2: CAROUSEL DE ONBOARDING (ESTILO DARK GLASSMORPHISM + LIMA NEÓN)
class OnboardingCarouselScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingCarouselScreen({super.key, required this.onFinish});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  final List<Map<String, dynamic>> _slides = const [
    {
      'icono': Icons.radar_rounded,
      'titulo': 'Partidos ordenados para vos',
      'descripcion':
          'Nuestro algoritmo prioriza las canchas más cercanas, tu categoría de juego y los partidos que están por empezar.',
    },
    {
      'icono': Icons.map_outlined,
      'titulo': 'Explorá clubes en el mapa',
      'descripcion':
          'Filtrá por Polvo de ladrillo, Cemento o Césped, mirá qué clubes tienen partidos abiertos hoy y sumate en un toque.',
    },
    {
      'icono': Icons.forum_outlined,
      'titulo': 'Coordiná con los jugadores',
      'descripcion':
          'Entrá al chat del partido para definir quién lleva pelotas, revisá el historial de tus rivales y salí a jugar.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _siguientePaso() {
    if (_paginaActual < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esUltimaPagina = _paginaActual == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Canvas oscuro #0E1311
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onFinish();
            },
            child: const Text(
              'Saltar',
              style: TextStyle(
                color: Color(0xFF8E9A93),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _paginaActual = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Contenedor circular Dark Glass con halo de Lima Neón
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1B2721), Color(0xFF121B16)],
                            ),
                            border: Border.all(
                              color: AppTheme.accentLimeColor.withValues(
                                alpha: 0.35,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentLimeColor.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            slide['icono'] as IconData,
                            size: 54,
                            color: AppTheme.accentLimeColor,
                          ),
                        ),
                        const SizedBox(height: 38),
                        Text(
                          slide['titulo'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            slide['descripcion'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF8E9A93),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicadores de páginas (Dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _paginaActual == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _paginaActual == index
                          ? AppTheme.accentLimeColor
                          : Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _paginaActual == index
                          ? [
                              BoxShadow(
                                color: AppTheme.accentLimeColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón de acción principal en Lima Neón
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    foregroundColor: const Color(0xFF0E1311),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                    shadowColor: AppTheme.accentLimeColor.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  onPressed: _siguientePaso,
                  child: Text(
                    esUltimaPagina ? 'Empezar a jugar' : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Color(0xFF0E1311),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
