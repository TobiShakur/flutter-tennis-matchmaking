import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../profile/domain/entities/jugador_entity.dart';
import '../../domain/entities/partido_entity.dart';

// TARJETA DE PARTIDO CON DISEÑO DARK GLASSMORPHISM Y LIMA NEÓN
class PartidoCard extends StatelessWidget {
  final PartidoEntity partido;
  final Map<String, JugadorEntity> directorioJugadores;
  final VoidCallback onTap;

  const PartidoCard({
    super.key,
    required this.partido,
    required this.directorioJugadores,
    required this.onTap,
  });

  String _formatFecha(DateTime fecha) => AppDateFormatter.fechaRelativa(fecha);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF161F1B), Color(0xFF0F1512)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.11),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              color: Colors.black.withValues(alpha: 0.50),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila Superior: Foto 50x50 + Título + Organizador + OpenTab
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        partido.imagenUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: AppTheme.accentLimeColor.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(
                            Icons.sports_tennis,
                            size: 24,
                            color: AppTheme.accentLimeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partido.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Org: ${partido.organizadorNombre} • ${partido.modalidad} (${partido.superficie})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8E9A93),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Ícono OpenTab en Lima Neón
                  SvgPicture.asset(
                    'assets/images/icons/openTab.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.accentLimeColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Fila Inferior: Horario + Ubicación + Chip de Estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/clock.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.accentLimeColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatFecha(partido.fechaHora),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/icons/location.svg',
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF8E9A93),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${partido.clubNombre}, ${partido.barrio}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8E9A93),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chip de estado Neón / Esmeralda (Falta X, Completo o Completado)
                  Builder(
                    builder: (context) {
                      final bool isFinalizado =
                          partido.estado == EstadoPartido.finalizado;
                      final bool isCompleto = partido.estaLleno;

                      final String badgeText;
                      final Color badgeColor;

                      if (isFinalizado) {
                        badgeText = 'Completado';
                        badgeColor = AppTheme.primaryColor;
                      } else if (isCompleto) {
                        badgeText = 'Completo';
                        badgeColor = AppTheme.primaryColor;
                      } else {
                        badgeText = 'Falta ${partido.cuposLibres}';
                        badgeColor = AppTheme.accentLimeColor;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor, width: 1.2),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
