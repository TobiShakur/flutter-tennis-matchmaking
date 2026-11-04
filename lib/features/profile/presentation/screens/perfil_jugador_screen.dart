import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/jugador_entity.dart';
import '../bloc/profile_actions.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../widgets/player_profile_card.dart';
import 'historial_jugador_screen.dart';

class PerfilJugadorScreen extends StatelessWidget {
  final JugadorEntity jugador;

  const PerfilJugadorScreen({super.key, required this.jugador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildGlassBackButton(context),
              const SizedBox(height: 20),
              PlayerProfileCard(jugador: jugador),

              const SizedBox(height: 24),
              Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
              const SizedBox(height: 20),

              // BOTÓN DARK GLASS: Historial de partidos >
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161E1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            HistorialJugadorScreen(jugador: jugador),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Historial de partidos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF8E9A93),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // BOTÓN BLOQUEAR / DESBLOQUEAR JUGADOR (UGC Safety)
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final estaBloqueado = state.usuariosBloqueadosIds.contains(
                    jugador.id,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: estaBloqueado
                            ? AppTheme.accentLimeColor.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: InkWell(
                      onTap: () {
                        if (estaBloqueado) {
                          context.read<ProfileBloc>().add(
                            UnblockUserAction(usuarioId: jugador.id),
                          );
                          AppTheme.showSnackBar(
                            context,
                            'Desbloqueaste a ${jugador.nombre}.',
                          );
                        } else {
                          AppTheme.showDarkDialog(
                            context: context,
                            title: '¿Bloquear a ${jugador.nombre}?',
                            icon: Icons.lock_person_outlined,
                            iconColor: const Color(0xFFEF4444),
                            content:
                                'Ya no verás sus mensajes en los chats ni podrá interactuar con vos en SetPoint.',
                            cancelText: 'Cancelar',
                            confirmText: 'Aceptar y Bloquear',
                            confirmTextColor: const Color(0xFFEF4444),
                            onConfirm: () {
                              context.read<ProfileBloc>().add(
                                BlockUserAction(usuarioId: jugador.id),
                              );
                              AppTheme.showSnackBar(
                                context,
                                'Bloqueaste a ${jugador.nombre}. Podés gestionarlo en tu perfil.',
                                icon: Icons.lock_person_outlined,
                              );
                            },
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              estaBloqueado
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_person_outlined,
                              size: 22,
                              color: estaBloqueado
                                  ? AppTheme.accentLimeColor
                                  : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                estaBloqueado
                                    ? 'Desbloquear jugador'
                                    : 'Bloquear jugador',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: estaBloqueado
                                      ? AppTheme.accentLimeColor
                                      : const Color(0xFFEF4444),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
