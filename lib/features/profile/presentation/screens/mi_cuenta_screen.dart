import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../widgets/player_profile_card.dart';
import 'edit_profile_screen.dart';

class MiCuentaScreen extends StatefulWidget {
  const MiCuentaScreen({super.key});

  @override
  State<MiCuentaScreen> createState() => _MiCuentaScreenState();
}

class _MiCuentaScreenState extends State<MiCuentaScreen> {
  bool _notificationsEnabled = true;

  void _showTerminosDialog(BuildContext context) {
    AppTheme.showDarkDialog(
      context: context,
      title: 'Términos y Condiciones',
      icon: Icons.description_outlined,
      iconColor: AppTheme.accentLimeColor,
      content:
          '1. SetPoint es una comunidad para conectar jugadores de tenis en CABA.\n\n'
          '2. Los turnos de cancha y los partidos organizados deben ser respetados por los jugadores confirmados.\n\n'
          '3. Promovemos el juego limpio y el respeto dentro y fuera de la cancha.\n\n'
          '4. Tus datos se encuentran protegidos y solo se comparten con fines de coordinación deportiva.',
      confirmText: 'Cerrar',
    );
  }

  void _showContactoDialog(BuildContext context) {
    AppTheme.showDarkDialog(
      context: context,
      title: 'Contacto y Soporte',
      icon: Icons.help_outline_rounded,
      iconColor: AppTheme.accentLimeColor,
      content:
          '¿Tenés alguna consulta o necesitás ayuda con tus partidos?\n\n'
          'Escribinos a: soporte@setpoint.app\n'
          'WhatsApp: +54 9 11 4455-8899\n\n'
          '¡Te responderemos a la brevedad!',
      confirmText: 'Aceptar',
    );
  }

  void _showCerrarSesionDialog(BuildContext context) {
    AppTheme.showDarkDialog(
      context: context,
      title: 'Cerrar sesión',
      icon: Icons.logout_rounded,
      iconColor: const Color(0xFFEF4444),
      content: '¿Estás seguro de que querés salir de tu cuenta?',
      cancelText: 'Cancelar',
      confirmText: 'Salir',
      confirmTextColor: const Color(0xFFEF4444),
      onConfirm: () {
        Navigator.of(context).pop();
        AppTheme.showSnackBar(context, 'Sesión cerrada correctamente.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final jugador = state.miPerfil;
            if (jugador == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 38, 20, 36),
              children: [
                const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Configurá tu nivel de juego y preferencias de cancha',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E9A93)),
                ),
                const SizedBox(height: 16),

                PlayerProfileCard(
                  jugador: jugador,
                  onEditTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E1A),
                    borderRadius: BorderRadius.circular(18),
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
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Opción 1: Perfil (Navega a EditProfileScreen)
                      _MenuListItem(
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        title: 'Perfil',
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF8E9A93),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 16,
                      ),

                      // Opción 2: Notificaciones (Switch interactivo Neón)
                      _MenuListItem(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        title: 'Notificaciones',
                        trailing: SizedBox(
                          width: 44,
                          height: 24,
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch.adaptive(
                              value: _notificationsEnabled,
                              onChanged: (val) {
                                setState(() => _notificationsEnabled = val);
                                AppTheme.showSnackBar(
                                  context,
                                  val
                                      ? 'Notificaciones activadas'
                                      : 'Notificaciones silenciadas',
                                );
                              },
                              activeTrackColor: AppTheme.accentLimeColor,
                              activeThumbColor: const Color(0xFF0E1311),
                              inactiveTrackColor: const Color(0xFF28342D),
                              inactiveThumbColor: const Color(0xFF8E9A93),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 16,
                      ),

                      // Opción 3: Términos y Condiciones
                      _MenuListItem(
                        icon: const Icon(
                          Icons.description_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                        title: 'Términos y Condiciones',
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF8E9A93),
                        ),
                        onTap: () => _showTerminosDialog(context),
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 16,
                      ),

                      // Opción 4: Contacto
                      _MenuListItem(
                        icon: const Icon(
                          Icons.help_outline_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        title: 'Contacto',
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF8E9A93),
                        ),
                        onTap: () => _showContactoDialog(context),
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 16,
                      ),

                      // Opción 5: Cerrar sesión (en rojo)
                      _MenuListItem(
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 22,
                          color: Color(0xFFEF4444),
                        ),
                        title: 'Cerrar sesión',
                        textColor: const Color(0xFFEF4444),
                        trailing: const SizedBox.shrink(),
                        onTap: () => _showCerrarSesionDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Widget _MenuListItem: Dark Glass SetPoint
class _MenuListItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget trailing;
  final Color? textColor;
  final VoidCallback? onTap;

  const _MenuListItem({
    required this.icon,
    required this.title,
    required this.trailing,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
