import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

// Centralizador de tokens visuales y tema oficial SetPoint (Dark Glassmorphism + Lima Neón)
class AppTheme {
  static const String appName = AppConstants.appName;

  // Paleta oficial de SetPoint Dark-Glass Deportivo
  static const Color primaryColor = Color(
    0xFF229C80,
  ); // Verde esmeralda deportivo
  static const Color accentLimeColor = Color(
    0xFFC8E652,
  ); // Verde lima neón deportivo
  static const Color accentClayColor = Color(
    0xFFD95D39,
  ); // Naranja Polvo de Ladrillo
  static const Color accentHardCourtColor = Color(0xFF2563EB); // Azul Cemento
  static const Color accentGrassColor = Color(
    0xFF38A169,
  ); // Verde Césped / Pasto natural
  static const Color backgroundColor = Color(
    0xFF0E1311,
  ); // Carbón deportivo profundo
  static const Color cardColor = Color(0xFF161E1A); // Superficie dark glass
  static const Color borderColor = Color(
    0x22FFFFFF,
  ); // Borde satinado blanco 14%
  static const Color textPrimary = Colors.white; // Blanco puro
  static const Color textSecondary = Color(
    0xFF8E9A93,
  ); // Gris frío deportivo para metadatos

  // Botón circular oficial frosted glass para volver atrás (44x44, circular con blur)
  static Widget buildGlassBackButton(
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Botón circular oficial SetPoint Neón para compartir (44x44, circular, Lima Neón)
  static Widget buildGlassShareButton({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accentLimeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: accentLimeColor.withValues(alpha: 0.45),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.share_rounded,
          size: 20,
          color: Color(0xFF0E1311),
        ),
      ),
    );
  }

  // Decorador de tarjetas estilo Dark Glassmorphism SetPoint
  static BoxDecoration cardDecoration({
    Color? borderColor,
    Color backgroundColor = const Color(0xFF161E1A),
    double radius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.12),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          color: Colors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Paleta cromática por categoría de juego de tenis
  static Color getColorForLevel(String level) {
    switch (level.toLowerCase().trim()) {
      case 'principiante':
        return const Color(0xFF3B82F6); // Azul
      case 'básico':
      case 'basico':
        return const Color(0xFF84CC16); // Lima
      case 'intermedio':
        return const Color(0xFFF59E0B); // Naranja / Ámbar
      case 'avanzado':
        return const Color(0xFFEF4444); // Rojo
      case 'experto':
        return const Color(0xFF6B0EEE); // Violeta
      default:
        return primaryColor;
    }
  }

  // Color de superficie: Naranja para polvo de ladrillo, Azul para cemento, Verde para césped
  static Color getColorForSurface(String surface) {
    final s = surface.toLowerCase().trim();
    if (s.contains('cemento') ||
        s.contains('rápida') ||
        s.contains('rapida') ||
        s.contains('dura')) {
      return accentHardCourtColor; // Azul Cemento
    }
    if (s.contains('césped') ||
        s.contains('cesped') ||
        s.contains('pasto') ||
        s.contains('grass')) {
      return accentGrassColor; // Verde Césped / Pasto
    }
    return accentClayColor; // Naranja Polvo de Ladrillo
  }

  // Fotografía de cancha oficial por tipo de superficie deportiva
  static String getCourtImageUrl(String surface) {
    final s = surface.toLowerCase().trim();
    if (s.contains('cemento') ||
        s.contains('rápida') ||
        s.contains('rapida') ||
        s.contains('dura')) {
      return 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80';
    }
    if (s.contains('césped') ||
        s.contains('cesped') ||
        s.contains('pasto') ||
        s.contains('grass')) {
      return 'https://images.unsplash.com/photo-1530915536846-99071597d344?auto=format&fit=crop&w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=800&q=80';
  }

  static OverlayEntry? _activeToastEntry;

  // Snack bar / Toast oficial SetPoint con animación slide desde abajo,
  // tiempo de lectura cómodo y animación de salida deslizándose hacia abajo.
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData icon = Icons.check_circle_rounded,
    Color? iconColor,
    double bottomMargin = 96.0,
  }) {
    final effectiveIconColor = iconColor ?? accentLimeColor;
    final effectiveDuration =
        duration ??
        (message.length > 40
            ? const Duration(milliseconds: 3600)
            : const Duration(milliseconds: 3000));

    // Desmontar toast anterior si existía para evitar solapamientos
    _activeToastEntry?.remove();
    _activeToastEntry = null;

    final overlay =
        Overlay.maybeOf(context) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null) return;

    late final OverlayEntry newEntry;
    newEntry = OverlayEntry(
      builder: (ctx) => _SlideAnimatedToast(
        message: message,
        icon: icon,
        iconColor: effectiveIconColor,
        displayDuration: effectiveDuration,
        bottomMargin: bottomMargin,
        onDismissed: () {
          if (_activeToastEntry == newEntry) {
            newEntry.remove();
            _activeToastEntry = null;
          }
        },
      ),
    );

    _activeToastEntry = newEntry;
    overlay.insert(newEntry);
  }

  // Diálogo oficial SetPoint (Dark Glass #161E1A + Borde satinado + Texto blanco/gris)
  static Future<T?> showDarkDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
    String confirmText = 'Entendido',
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    Color? confirmTextColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161E1A),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? accentLimeColor, size: 22),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8E9A93),
            height: 1.4,
          ),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onCancel?.call();
              },
              child: Text(
                cancelText,
                style: const TextStyle(
                  color: Color(0xFF8E9A93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (confirmTextColor == const Color(0xFFEF4444))
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmTextColor ?? accentLimeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: accentLimeColor,
        secondary: primaryColor,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF161E1A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.2,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF8E9A93),
          fontSize: 13,
          height: 1.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accentLimeColor,
        contentTextStyle: const TextStyle(
          color: Color(0xFF0E1311),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}

class _SlideAnimatedToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Duration displayDuration;
  final double bottomMargin;
  final VoidCallback onDismissed;

  const _SlideAnimatedToast({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.displayDuration,
    required this.bottomMargin,
    required this.onDismissed,
  });

  @override
  State<_SlideAnimatedToast> createState() => _SlideAnimatedToastState();
}

class _SlideAnimatedToastState extends State<_SlideAnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _hideTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 280),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward().then((_) {
      if (!mounted) return;
      _hideTimer = Timer(widget.displayDuration, () {
        _dismiss();
      });
    });
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _hideTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomMargin,
      left: 18,
      right: 18,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 0) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF101713),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.iconColor, width: 1.6),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 20, color: widget.iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          height: 1.25,
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
    );
  }
}
