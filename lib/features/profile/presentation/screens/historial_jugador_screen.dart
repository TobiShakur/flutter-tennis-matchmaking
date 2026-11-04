import 'package:flutter/material.dart';
import '../../../../core/animations/smoke_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../matches/domain/entities/partido_entity.dart';
import '../../../matches/presentation/screens/match_detail_screen.dart';
import '../../../matches/presentation/widgets/partido_card.dart';
import '../../domain/entities/jugador_entity.dart';

// PANTALLA HISTORIAL DE PARTIDOS (ARMONIZADO CON MIS PARTIDOS Y PARTIDO_CARD)
class HistorialJugadorScreen extends StatelessWidget {
  final JugadorEntity jugador;

  const HistorialJugadorScreen({super.key, required this.jugador});

  PartidoEntity _toPartidoEntity(HistorialPartidoItem item) {
    final bool esCemento =
        item.superficie.toLowerCase().contains('cemento') ||
        item.superficie.toLowerCase().contains('rápida') ||
        item.superficie.toLowerCase().contains('dura');
    final String defaultImg = esCemento
        ? 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=400&q=80'
        : 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=400&q=80';
    final int cupos = item.modalidad.toLowerCase().contains('dobles') ? 4 : 2;

    return PartidoEntity(
      id: item.id,
      titulo: item.titulo,
      modalidad: item.modalidad,
      superficie: item.superficie,
      nivel: jugador.nivel,
      organizadorId: jugador.id,
      organizadorNombre: jugador.nombre,
      imagenUrl: defaultImg,
      fechaHora: item.fecha,
      fechaCreacion: item.fecha,
      cuposTotales: cupos,
      jugadoresUnidosIds: List.generate(
        cupos,
        (i) => i == 0 ? jugador.id : 'player_$i',
      ),
      clubNombre: item.clubNombre,
      direccion: item.clubNombre,
      barrio: jugador.barrio,
      latitud: -34.5800,
      longitud: -58.4200,
      estado: EstadoPartido.finalizado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildGlassBackButton(context),

              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    jugador.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Historial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8E9A93),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: jugador.historialPartidos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 56,
                              color: Color(0xFF8E9A93),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aún no hay partidos para mostrar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Los partidos completados aparecerán aquí.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E9A93),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: jugador.historialPartidos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = jugador.historialPartidos[index];
                          final dateString = AppDateFormatter.mesDiaLateral(
                            item.fecha,
                          );
                          final partidoEntity = _toPartidoEntity(item);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Fecha lateral en Verde Lima Neón
                              SizedBox(
                                width: 50,
                                child: Text(
                                  dateString,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: AppTheme.accentLimeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tarjeta oficial PartidoCard
                              Expanded(
                                child: PartidoCard(
                                  partido: partidoEntity,
                                  directorioJugadores: {jugador.id: jugador},
                                  onTap: () {
                                    Navigator.of(context).push(
                                      SmokePageRoute(
                                        child: MatchDetailScreen(
                                          partidoId: partidoEntity.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
