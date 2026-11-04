import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/jugador_entity.dart';

/// Tarjeta de perfil de jugador que sigue 1:1 el sistema de diseño de SetPoint
/// (estética armonizada con PartidoCard: franja lateral de acento de 4px,
/// micro-iconos consistentes, botón de acción en esquina y pods de métricas).
class PlayerProfileCard extends StatelessWidget {
  final JugadorEntity jugador;
  final VoidCallback? onEditTap;

  const PlayerProfileCard({super.key, required this.jugador, this.onEditTap});

  String get _surfaceShortLabel {
    final s = jugador.superficieFavorita.trim().toLowerCase();
    if (s.contains('polvo')) return 'Polvo';
    if (s.contains('cemento')) return 'Cemento';
    if (s.contains('cesped') || s.contains('césped')) return 'Césped';
    if (s.contains('sintet') || s.contains('sintét')) return 'Sintética';
    return jugador.superficieFavorita;
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.getColorForLevel(jugador.nivel);
    final surfaceColor = AppTheme.getColorForSurface(
      jugador.superficieFavorita,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161E1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circular sin borde duro y medalla de estrella de nivel
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        jugador.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: levelColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person_rounded,
                            size: 34,
                            color: levelColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: levelColor,
                        border: Border.all(
                          color: const Color(0xFF161E1A),
                          width: 2,
                        ),
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
              const SizedBox(width: 14),

              // Nombre y Ubicación / Mano Hábil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jugador.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF8E9A93),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            jugador.barrio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E9A93),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF555B58),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.sports_tennis_rounded,
                          size: 13,
                          color: Color(0xFF8E9A93),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          jugador.manoHabil,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E9A93),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Acción superior derecha (Botón Editar Neón o Badge de Jugador)
              if (onEditTap != null)
                InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLimeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentLimeColor,
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppTheme.accentLimeColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Editar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentLimeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: levelColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_tennis, size: 12, color: levelColor),
                      const SizedBox(width: 4),
                      Text(
                        'Jugador',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: levelColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Nivel con su color específico
              Expanded(
                child: _MetricBadge(
                  icon: Icons.star_rounded,
                  color: levelColor,
                  title: jugador.nivel,
                  subtitle: 'Nivel',
                ),
              ),
              const SizedBox(width: 8),

              // Superficie (Naranja Polvo / Azul Cemento)
              Expanded(
                child: _MetricBadge(
                  icon: Icons.layers_outlined,
                  color: surfaceColor,
                  title: _surfaceShortLabel,
                  subtitle: 'Superficie',
                ),
              ),
              const SizedBox(width: 8),

              // Partidos Jugados
              Expanded(
                child: _MetricBadge(
                  icon: Icons.sports_tennis_rounded,
                  color: AppTheme.accentLimeColor,
                  title: '${jugador.totalJugados}',
                  subtitle: 'Partidos',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini-badge estructurado con estética de tarjeta de partido (Dark Glass Pod)
class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _MetricBadge({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF101513),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E9A93),
            ),
          ),
        ],
      ),
    );
  }
}
