import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/partido_entity.dart';
import 'match_detail_sheet.dart';
import 'partido_card.dart';

// MODAL QUE SUBE CUANDO TOCÁS UN CLUSTER CON VARIOS PARTIDOS
class ClusterListBottomSheet extends StatelessWidget {
  final List<PartidoEntity> partidos;
  final double userLat;
  final double userLng;

  const ClusterListBottomSheet({
    super.key,
    required this.partidos,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final directorioJugadores = context
        .watch<ProfileBloc>()
        .state
        .directorioJugadores;

    return Container(
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  const Icon(
                    Icons.sports_tennis,
                    color: AppTheme.accentLimeColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${partidos.length} Partidos en esta zona',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (partidos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.location_off_rounded,
                          size: 38,
                          color: Color(0xFF8E9A93),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No hay partidos disponibles en este punto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Probá explorando otras zonas de la ciudad en el mapa.',
                          style: TextStyle(
                            color: Color(0xFF8E9A93),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: partidos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final partido = partidos[index];
                      return PartidoCard(
                        partido: partido,
                        directorioJugadores: directorioJugadores,
                        onTap: () {
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => MatchDetailSheet(
                              partido: partido,
                              userLat: userLat,
                              userLng: userLng,
                            ),
                          );
                        },
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
