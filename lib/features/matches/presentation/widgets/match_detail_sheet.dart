import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/smoke_page_route.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/partido_entity.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import '../screens/match_detail_screen.dart';

// MODAL QUE SUBE AL TOCAR UN MARCADOR EN EL MAPA
class MatchDetailSheet extends StatelessWidget {
  final PartidoEntity partido;
  final double userLat;
  final double userLng;

  const MatchDetailSheet({
    super.key,
    required this.partido,
    required this.userLat,
    required this.userLng,
  });

  String _formatDistance() {
    final distKm = partido.distanciaDesdeKm(userLat, userLng);
    if (distKm < 1.0) {
      return '${(distKm * 1000).toStringAsFixed(0)} m de ti';
    }
    return '${distKm.toStringAsFixed(1)} km de ti';
  }

  @override
  Widget build(BuildContext context) {
    final directorioJugadores = context
        .watch<ProfileBloc>()
        .state
        .directorioJugadores;

    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        // Obtenemos el partido fresco del estado
        final partidoActual =
            state.partidos.where((p) => p.id == partido.id).firstOrNull ??
            partido;

        final yaEstoyUnido = partidoActual.jugadoresUnidosIds.contains(
          AppConstants.currentUserId,
        );
        final estaProcesando = state.procesandoPartidoId == partidoActual.id;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF141A17),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.2,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tirador superior del modal
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(
                            partidoActual.imagenUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 64,
                                  height: 64,
                                  color: AppTheme.accentLimeColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: const Icon(
                                    Icons.sports_tennis,
                                    color: AppTheme.accentLimeColor,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partidoActual.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${partidoActual.clubNombre} • ${partidoActual.direccion}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E9A93),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLimeColor.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.accentLimeColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _formatDistance(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentLimeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${partidoActual.modalidad} • ${partidoActual.superficie}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E9A93),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Avatares de jugadores y cupos
                  Row(
                    children: [
                      SizedBox(
                        height: 30,
                        width:
                            (partidoActual.jugadoresUnidosIds.length * 20.0) +
                            12,
                        child: Stack(
                          children: List.generate(
                            partidoActual.jugadoresUnidosIds.length,
                            (index) {
                              final uid =
                                  partidoActual.jugadoresUnidosIds[index];
                              final jug = directorioJugadores[uid];
                              return Positioned(
                                left: index * 18.0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFF141A17),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(
                                      jug?.avatarUrl ??
                                          'https://i.pravatar.cc/300?img=12',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${partidoActual.cuposOcupados}/${partidoActual.cuposTotales} jugadores confirmados',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E9A93),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yaEstoyUnido
                                  ? const Color(0xFFEF4444)
                                  : AppTheme.accentLimeColor,
                              foregroundColor: yaEstoyUnido
                                  ? Colors.white
                                  : const Color(0xFF0E1311),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: estaProcesando
                                ? null
                                : () {
                                    if (yaEstoyUnido) {
                                      context.read<MatchesBloc>().add(
                                        LeaveMatchAction(
                                          partidoId: partidoActual.id,
                                          usuarioId: AppConstants.currentUserId,
                                        ),
                                      );
                                    } else {
                                      context.read<MatchesBloc>().add(
                                        JoinMatchAction(
                                          partidoId: partidoActual.id,
                                          usuarioId: AppConstants.currentUserId,
                                        ),
                                      );
                                    }
                                  },
                            child: estaProcesando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0E1311),
                                    ),
                                  )
                                : Text(
                                    yaEstoyUnido
                                        ? 'Salir del Partido'
                                        : 'Unirme al Partido',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF161E1A),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.16),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                SmokePageRoute(
                                  child: MatchDetailScreen(
                                    partidoId: partidoActual.id,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Ver Detalle',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
