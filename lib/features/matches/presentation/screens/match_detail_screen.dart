import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../chat/presentation/screens/chat_partido_screen.dart';
import '../../../profile/domain/entities/jugador_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/perfil_jugador_screen.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import '../../domain/entities/partido_entity.dart';
import '../widgets/player_slot_widget.dart';
import 'create_match_screen.dart';

/// Pantalla de Detalle de Partido con diseño Glassmorphism Deportivo & Smoke Reveal.
/// Inspirado en la interfaz de reserva de canchas: fondo inmersivo de pista
/// (polvo de ladrillo / cemento), header flotante con botón volver glass y compartir lima neón,
/// panel inferior frosted glass con formación táctica de equipos (O | O o O O | O O)
/// y botón CTA de acento neón.
class MatchDetailScreen extends StatefulWidget {
  final String partidoId;

  const MatchDetailScreen({super.key, required this.partidoId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _smokeController;
  late final Animation<Offset> _panelSlideAnimation;
  late final Animation<double> _smokeFadeAnimation;
  late final Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _panelSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(parent: _smokeController, curve: Curves.easeOutCubic),
        );

    _smokeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _smokeController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );

    _blurAnimation = Tween<double>(begin: 25.0, end: 18.0).animate(
      CurvedAnimation(parent: _smokeController, curve: Curves.easeOutCubic),
    );

    // Iniciar el efecto humo difuminado al abrirse
    _smokeController.forward();
  }

  @override
  void dispose() {
    _smokeController.dispose();
    super.dispose();
  }

  String _getCourtAsset(String superficie) {
    final s = superficie.toLowerCase();
    if (s.contains('cemento') ||
        s.contains('rapida') ||
        s.contains('rápida') ||
        s.contains('dura')) {
      return 'assets/images/stock/tennis_1.png';
    }
    if (s.contains('cesped') ||
        s.contains('césped') ||
        s.contains('pasto') ||
        s.contains('grass')) {
      return 'assets/images/stock/tennis_2.png';
    }
    // Por defecto polvo de ladrillo (arcilla roja clásica)
    return 'assets/images/stock/tennis_4.jpg';
  }

  String _getCourtNetworkFallback(String superficie) =>
      AppTheme.getCourtImageUrl(superficie);

  void _compartirPartido(BuildContext context, String titulo, String club) {
    AppTheme.showSnackBar(
      context,
      'Enlace copiado: "¡Sumate a $titulo en $club en SetPoint!"',
    );
  }

  void _abrirPerfil(BuildContext context, JugadorEntity jugador) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PerfilJugadorScreen(jugador: jugador)),
    );
  }

  void _confirmarAbandonar(BuildContext context, PartidoEntity partido) {
    AppTheme.showDarkDialog(
      context: context,
      title: 'Abandonar partido',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFEF4444),
      content:
          '¿Estás seguro de que querés salir de este partido? Tu cupo quedará libre para otro jugador.',
      cancelText: 'Cancelar',
      confirmText: 'Salir',
      confirmTextColor: const Color(0xFFEF4444),
      onConfirm: () {
        context.read<MatchesBloc>().add(
          LeaveMatchAction(
            partidoId: partido.id,
            usuarioId: AppConstants.currentUserId,
          ),
        );
        AppTheme.showSnackBar(context, 'Has abandonado el partido.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final directorioJugadores = context
        .watch<ProfileBloc>()
        .state
        .directorioJugadores;

    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        final partido = state.partidos
            .where((p) => p.id == widget.partidoId)
            .firstOrNull;

        if (partido == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF111111),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlassBackButton(context),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Partido no encontrado.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final yaEstoyUnido = partido.jugadoresUnidosIds.contains(
          AppConstants.currentUserId,
        );
        final estaProcesando = state.procesandoPartidoId == partido.id;
        final cuposLibres =
            partido.cuposTotales - partido.jugadoresUnidosIds.length;
        final hayLugar = cuposLibres > 0;
        final esCreador = partido.organizadorId == AppConstants.currentUserId;

        // Formación táctica: El creador del partido SIEMPRE va en el equipo de la izquierda (Equipo 1, primer slot)
        final List<String> orderedIds = List<String>.from(
          partido.jugadoresUnidosIds,
        );
        if (orderedIds.contains(partido.organizadorId)) {
          orderedIds.remove(partido.organizadorId);
          orderedIds.insert(0, partido.organizadorId);
        } else if (partido.organizadorId.isNotEmpty) {
          orderedIds.insert(0, partido.organizadorId);
        }

        // Mapeo de jugadores unidos a entidades respetando el slot 1 para el creador
        final jugadores = orderedIds
            .map(
              (id) =>
                  directorioJugadores[id] ??
                  _generarJugadorFallback(id, partido),
            )
            .toList();

        final esSingles =
            partido.modalidad.toLowerCase().contains('single') ||
            partido.cuposTotales <= 2;

        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _getCourtAsset(partido.superficie),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.network(
                    _getCourtNetworkFallback(partido.superficie),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.40),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.28, 0.60, 1.0],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGlassBackButton(context),
                          Row(
                            children: [
                              if (esCreador) ...[
                                _buildAdminEditButton(context, partido),
                                const SizedBox(width: 10),
                              ],
                              _buildNeonShareButton(context, partido),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // B. TÍTULO HERO Y FECHA/HORA CENTRADOS SOBRE LA CANCHA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            partido.titulo.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Colors.black87,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppDateFormatter.fechaDetalle(partido.fechaHora)} - ${partido.superficie}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black87,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // C. PANEL INFERIOR GLASSMORPHISM CON SMOKE REVEAL (De mitad de pantalla hacia abajo)
                    SlideTransition(
                      position: _panelSlideAnimation,
                      child: FadeTransition(
                        opacity: _smokeFadeAnimation,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedBuilder(
                              animation: _blurAnimation,
                              builder: (context, child) {
                                return ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(32),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: _blurAnimation.value,
                                      sigmaY: _blurAnimation.value,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        22,
                                        24,
                                        22,
                                        28,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(32),
                                            ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, -6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildTeamsSection(
                                            context,
                                            esSingles: esSingles,
                                            jugadores: jugadores,
                                            cuposTotales: partido.cuposTotales,
                                          ),

                                          const SizedBox(height: 18),
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                          ),
                                          const SizedBox(height: 18),

                                          _buildRemainingInfo(partido),

                                          const SizedBox(height: 22),

                                          _buildActionButton(
                                            context,
                                            partido: partido,
                                            yaEstoyUnido: yaEstoyUnido,
                                            hayLugar: hayLugar,
                                            estaProcesando: estaProcesando,
                                            esCreador: esCreador,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Botón de Chat Flotante ubicado encima a la derecha del panel
                            Positioned(
                              top: -24,
                              right: 22,
                              child: GestureDetector(
                                onTap: () {
                                  if (!yaEstoyUnido) {
                                    AppTheme.showSnackBar(
                                      context,
                                      'Debés unirte al partido para acceder al chat de los jugadores.',
                                      icon: Icons.lock_outline_rounded,
                                    );
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatPartidoScreen(
                                        partidoId: partido.id,
                                        tituloPartido: partido.titulo,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: yaEstoyUnido
                                        ? AppTheme.accentLimeColor
                                        : const Color(0xFF1E2822),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: yaEstoyUnido
                                          ? const Color(0xFF161E1A)
                                          : Colors.white.withValues(
                                              alpha: 0.18,
                                            ),
                                      width: 2.2,
                                    ),
                                    boxShadow: yaEstoyUnido
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.accentLimeColor
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: yaEstoyUnido
                                            ? const Color(0xFF0E1311)
                                            : const Color(0xFF8E9A93),
                                        size: 22,
                                      ),
                                      if (!yaEstoyUnido)
                                        Positioned(
                                          right: 6,
                                          bottom: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(2.5),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0E1311),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lock_rounded,
                                              size: 9,
                                              color: AppTheme.accentLimeColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildGlassBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminEditButton(BuildContext context, PartidoEntity partido) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateMatchScreen.editar(partido: partido),
          ),
        );
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: AppTheme.accentLimeColor.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.edit_rounded,
              color: AppTheme.accentLimeColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonShareButton(BuildContext context, PartidoEntity partido) {
    return GestureDetector(
      onTap: () =>
          _compartirPartido(context, partido.titulo, partido.clubNombre),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFC8E652), // Verde Lima Neón exacto de la foto
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC8E652).withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.share_rounded,
          color: Color(0xFF111111),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTeamsSection(
    BuildContext context, {
    required bool esSingles,
    required List<JugadorEntity> jugadores,
    required int cuposTotales,
  }) {
    if (esSingles) {
      // FORMACIÓN SINGLES: ( O | O )
      final j1 = jugadores.isNotEmpty ? jugadores[0] : null;
      final j2 = jugadores.length > 1 ? jugadores[1] : null;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Center(
              child: PlayerSlotWidget(
                jugador: j1,
                placeholderNombre: 'Cupo libre',
                onTap: j1 != null ? () => _abrirPerfil(context, j1) : null,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 52,
            color: Colors.white.withValues(alpha: 0.22),
          ),
          Expanded(
            child: Center(
              child: PlayerSlotWidget(
                jugador: j2,
                placeholderNombre: 'Cupo libre',
                onTap: j2 != null ? () => _abrirPerfil(context, j2) : null,
              ),
            ),
          ),
        ],
      );
    }

    // FORMACIÓN DOBLES: ( O O | O O )
    final j1 = jugadores.isNotEmpty ? jugadores[0] : null;
    final j2 = jugadores.length > 1 ? jugadores[1] : null;
    final j3 = jugadores.length > 2 ? jugadores[2] : null;
    final j4 = jugadores.length > 3 ? jugadores[3] : null;

    return Row(
      children: [
        // Equipo 1: Dos jugadores
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerSlotWidget(
                jugador: j1,
                placeholderNombre: 'Libre',
                onTap: j1 != null ? () => _abrirPerfil(context, j1) : null,
              ),
              PlayerSlotWidget(
                jugador: j2,
                placeholderNombre: 'Libre',
                onTap: j2 != null ? () => _abrirPerfil(context, j2) : null,
              ),
            ],
          ),
        ),

        // Separador vertical central
        Container(
          width: 1,
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: Colors.white.withValues(alpha: 0.22),
        ),

        // Equipo 2: Dos jugadores
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerSlotWidget(
                jugador: j3,
                placeholderNombre: 'Libre',
                onTap: j3 != null ? () => _abrirPerfil(context, j3) : null,
              ),
              PlayerSlotWidget(
                jugador: j4,
                placeholderNombre: 'Libre',
                onTap: j4 != null ? () => _abrirPerfil(context, j4) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingInfo(PartidoEntity partido) {
    final levelColor = AppTheme.getColorForLevel(partido.nivel);

    return Row(
      children: [
        // Nivel
        Expanded(
          child: _buildInfoItem(
            icon: Icons.star_rounded,
            iconColor: levelColor,
            title: partido.nivel,
            subtitle: 'Nivel',
          ),
        ),
        const SizedBox(width: 8),

        // Duración estimada
        Expanded(
          child: _buildInfoItem(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFFC8E652),
            title: '90 min',
            subtitle: 'Duración',
          ),
        ),
        const SizedBox(width: 8),

        // Dirección / Club
        Expanded(
          child: _buildInfoItem(
            icon: Icons.location_on_outlined,
            iconColor: Colors.white70,
            title: partido.clubNombre,
            subtitle: 'Cancha',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
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
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required PartidoEntity partido,
    required bool yaEstoyUnido,
    required bool hayLugar,
    required bool estaProcesando,
    required bool esCreador,
  }) {
    if (estaProcesando) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Color(0xFFC8E652),
          strokeWidth: 2.5,
        ),
      );
    }

    if (esCreador) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateMatchScreen.editar(partido: partido),
              ),
            );
          },
          icon: const Icon(
            Icons.edit_rounded,
            color: Color(0xFF0E1311),
            size: 19,
          ),
          label: const Text(
            'Administrar / Editar Partido',
            style: TextStyle(
              color: Color(0xFF0E1311),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentLimeColor,
            elevation: 4,
            shadowColor: AppTheme.accentLimeColor.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ),
      );
    }

    if (yaEstoyUnido) {
      // Usuario unido -> Abandonar partido
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () => _confirmarAbandonar(context, partido),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Colors.red.withValues(alpha: 0.5),
              width: 1.4,
            ),
            backgroundColor: Colors.red.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: const Text(
            'Abandonar Partido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }

    if (!hayLugar) {
      // Sin cupos
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Cancha Completa',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // Disponible -> Botón Verde Lima Neón tipo "Book now"
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          context.read<MatchesBloc>().add(
            JoinMatchAction(
              partidoId: partido.id,
              usuarioId: AppConstants.currentUserId,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8E652),
          foregroundColor: const Color(0xFF111111),
          elevation: 6,
          shadowColor: const Color(0xFFC8E652).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          'Unirme al Partido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Color(0xFF111111),
          ),
        ),
      ),
    );
  }

  JugadorEntity _generarJugadorFallback(String id, PartidoEntity partido) {
    return JugadorEntity(
      id: id,
      nombre: id == partido.organizadorId
          ? partido.organizadorNombre
          : 'Jugador',
      avatarUrl: 'https://i.pravatar.cc/150?u=$id',
      bio: '',
      nivel: partido.nivel,
      manoHabil: 'Diestro',
      tipoReves: 'Dos manos',
      superficieFavorita: partido.superficie,
      barrio: partido.clubNombre,
      radioBusquedaKm: 10,
      historialPartidos: const [],
    );
  }
}
