import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/animations/smoke_page_route.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../profile/domain/entities/jugador_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/partido_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import '../widgets/partido_card.dart';
import 'match_detail_screen.dart';

class MyMatchesScreen extends StatelessWidget {
  const MyMatchesScreen({super.key});

  String _formatMonthDay(DateTime dt) => AppDateFormatter.mesDiaLateral(dt);

  @override
  Widget build(BuildContext context) {
    final directorioJugadores = context
        .watch<ProfileBloc>()
        .state
        .directorioJugadores;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            final ahora = DateTime.now();
            final misPartidos = state.partidos
                .where(
                  (p) =>
                      p.jugadoresUnidosIds.contains(
                        AppConstants.currentUserId,
                      ) ||
                      p.organizadorId == AppConstants.currentUserId,
                )
                .toList();

            final proximos = misPartidos
                .where((p) => p.fechaHora.isAfter(ahora))
                .toList();
            final pasados = misPartidos
                .where((p) => p.fechaHora.isBefore(ahora))
                .toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 38, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis partidos!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tenés ${proximos.length} próximo${proximos.length == 1 ? '' : 's'} partido${proximos.length == 1 ? '' : 's'}!',
                        style: const TextStyle(
                          color: Color(0xFF8E9A93),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sección Próximos
                  _buildSection(
                    context: context,
                    title: 'Próximos',
                    matches: proximos,
                    directorioJugadores: directorioJugadores,
                    emptyMessage: 'No tenés partidos programados próximamente.',
                  ),

                  const SizedBox(height: 28),

                  // Sección Pasados
                  _buildSection(
                    context: context,
                    title: 'Pasados',
                    matches: pasados,
                    directorioJugadores: directorioJugadores,
                    emptyMessage: 'Aún no registrás partidos jugados pasados.',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<PartidoEntity> matches,
    required Map<String, JugadorEntity> directorioJugadores,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (matches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF161E1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.09),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  title == 'Próximos'
                      ? Icons.event_available_rounded
                      : Icons.history_toggle_off_rounded,
                  size: 32,
                  color: title == 'Próximos'
                      ? AppTheme.accentLimeColor.withValues(alpha: 0.8)
                      : const Color(0xFF8E9A93),
                ),
                const SizedBox(height: 10),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB0BCB4),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final match = matches[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatMonthDay(match.fechaHora),
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
                  Expanded(
                    child: PartidoCard(
                      partido: match,
                      directorioJugadores: directorioJugadores,
                      onTap: () {
                        Navigator.of(context).push(
                          SmokePageRoute(
                            child: MatchDetailScreen(partidoId: match.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
