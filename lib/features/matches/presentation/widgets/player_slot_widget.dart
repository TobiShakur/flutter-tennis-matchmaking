import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/domain/entities/jugador_entity.dart';

/// Componente táctico de jugador para formación de canchas (Singles / Dobles):
/// Avatar circular con borde blanco sólido y medalla superior derecha
/// (fondo tenue del nivel + estrella plena en el color del nivel).
class PlayerSlotWidget extends StatelessWidget {
  final JugadorEntity? jugador;
  final String? placeholderNombre;
  final VoidCallback? onTap;

  const PlayerSlotWidget({
    super.key,
    this.jugador,
    this.placeholderNombre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (jugador == null) {
      // Cupo libre / Slot disponible
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.8,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              placeholderNombre ?? 'Libre',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    final levelColor = AppTheme.getColorForLevel(jugador!.nivel);

    // Formatear nombre: "Tobías S." o primer nombre
    final partes = jugador!.nombre.trim().split(' ');
    final nombreDisplay = partes.length > 1
        ? '${partes.first} ${partes[1][0]}.'
        : partes.first;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    jugador!.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: levelColor.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: levelColor,
                    border: Border.all(
                      color: const Color(0xFF161E1A),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.star_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Nombre del jugador
          SizedBox(
            width: 70,
            child: Text(
              nombreDisplay,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black54,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
