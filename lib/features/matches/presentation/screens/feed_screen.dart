import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/animations/smoke_page_route.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import '../widgets/match_filters_bottom_sheet.dart';
import '../widgets/partido_card.dart';
import 'map_feed_screen.dart';
import 'match_detail_screen.dart';

/// Pantalla de Feed principal con alternancia fluida entre vista de lista y mapa.
class FeedScreen extends StatefulWidget {
  final Function(bool isMapOpen)? onMapToggle;

  const FeedScreen({super.key, this.onMapToggle});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isMapOpen = false;
  late AnimationController _exitAnimController;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _exitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0)).animate(
          CurvedAnimation(parent: _exitAnimController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _exitAnimController.dispose();
    super.dispose();
  }

  void _toggleMap() {
    setState(() {
      _isMapOpen = !_isMapOpen;
    });

    if (_isMapOpen) {
      _exitAnimController.forward();
    } else {
      _exitAnimController.reverse();
    }

    widget.onMapToggle?.call(_isMapOpen);
  }

  Widget _buildHeader(
    String nombre,
    int totalPartidos,
    int totalFiltrosActivos,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, $nombre!',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$totalPartidos partidos cerca de ti',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E9A93),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => MatchFiltersBottomSheet.show(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF161E1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: totalFiltrosActivos > 0
                    ? AppTheme.accentLimeColor
                    : Colors.white.withValues(alpha: 0.14),
                width: totalFiltrosActivos > 0 ? 1.6 : 1.2,
              ),
              boxShadow: [
                if (totalFiltrosActivos > 0)
                  BoxShadow(
                    color: AppTheme.accentLimeColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: SvgPicture.asset(
                    'assets/images/icons/filter.svg',
                    colorFilter: const ColorFilter.mode(
                      AppTheme.accentLimeColor,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                if (totalFiltrosActivos > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.accentLimeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0E1311),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$totalFiltrosActivos',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0E1311),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Píldora de navegación Lista | Mapa
  Widget _buildFloatingPillBody() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090D0B), // Carril oscuro empotrado de hardware
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isMapOpen
                ? Alignment.centerRight
                : Alignment.centerLeft,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentLimeColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentLimeColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_isMapOpen) _toggleMap();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      style: TextStyle(
                        color: !_isMapOpen
                            ? const Color(0xFF0E1311)
                            : const Color(0xFF728078),
                        fontSize: 13,
                        fontWeight: !_isMapOpen
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      child: const Text('Lista'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!_isMapOpen) _toggleMap();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      style: TextStyle(
                        color: _isMapOpen
                            ? const Color(0xFF0E1311)
                            : const Color(0xFF728078),
                        fontSize: 13,
                        fontWeight: _isMapOpen
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      child: const Text('Mapa'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final s = label.toLowerCase();
    final bool esSuperficie =
        s.contains('polvo') ||
        s.contains('cemento') ||
        s.contains('césped') ||
        s.contains('cesped');
    final Color activeColor = esSuperficie
        ? AppTheme.getColorForSurface(label)
        : AppTheme.accentLimeColor;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.14)
              : const Color(0xFF111714),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 13, color: activeColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF8E9A93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Título de Sección con divisor y contador
  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        const Text(
          'PARTIDOS DISPONIBLES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: Color(0xFF728078),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accentLimeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.accentLimeColor.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentLimeColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.01),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    final profileState = context.watch<ProfileBloc>().state;
    final nombreUsuario =
        profileState.miPerfil?.nombre.split(' ').first ?? 'Tobías';
    final nivelUsuario = profileState.miPerfil?.nivel ?? 'Intermedio';

    const double headerHeight = 52.0;
    final double listTop = topPadding + 34 + headerHeight + 14;
    const double listLeft = 24.0;
    final double listWidth = screenWidth - 48.0;

    final double mapTop = topPadding + 28.0;
    const double mapWidth = 200.0;
    final double mapLeft = (screenWidth - mapWidth) / 2;

    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        // FILTRO DE NEGOCIO: No mostrar en el feed los partidos donde ya estoy unido
        final partidosDisponibles = state.partidos
            .where(
              (p) => !p.jugadoresUnidosIds.contains(AppConstants.currentUserId),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 34, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideTransition(
                        position: _headerSlideAnimation,
                        child: _buildHeader(
                          nombreUsuario,
                          partidosDisponibles.length,
                          state.totalFiltrosActivos,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SizedBox(height: 38),
                      const SizedBox(height: 14),
                      SlideTransition(
                        position: _headerSlideAnimation,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              _buildDarkFilterChip(
                                label: 'Todos',
                                isSelected:
                                    state.modalidadesFiltro.isEmpty &&
                                    state.superficiesFiltro.isEmpty &&
                                    state.nivelesFiltro.isEmpty,
                                onSelected: () {
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro: const [],
                                      superficiesFiltro: const [],
                                      nivelesFiltro: const [],
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildDarkFilterChip(
                                label: 'Singles',
                                isSelected: state.modalidadesFiltro.contains(
                                  'Singles',
                                ),
                                onSelected: () {
                                  final activo = state.modalidadesFiltro
                                      .contains('Singles');
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro: activo
                                          ? const []
                                          : const ['Singles'],
                                      superficiesFiltro:
                                          state.superficiesFiltro,
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildDarkFilterChip(
                                label: 'Dobles',
                                isSelected: state.modalidadesFiltro.contains(
                                  'Dobles',
                                ),
                                onSelected: () {
                                  final activo = state.modalidadesFiltro
                                      .contains('Dobles');
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro: activo
                                          ? const []
                                          : const ['Dobles'],
                                      superficiesFiltro:
                                          state.superficiesFiltro,
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildDarkFilterChip(
                                label: 'Polvo de ladrillo',
                                isSelected: state.superficiesFiltro.contains(
                                  'Polvo de ladrillo',
                                ),
                                onSelected: () {
                                  final activo = state.superficiesFiltro
                                      .contains('Polvo de ladrillo');
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro:
                                          state.modalidadesFiltro,
                                      superficiesFiltro: activo
                                          ? const []
                                          : const ['Polvo de ladrillo'],
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildDarkFilterChip(
                                label: 'Cemento',
                                isSelected: state.superficiesFiltro.contains(
                                  'Cemento',
                                ),
                                onSelected: () {
                                  final activo = state.superficiesFiltro
                                      .contains('Cemento');
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro:
                                          state.modalidadesFiltro,
                                      superficiesFiltro: activo
                                          ? const []
                                          : const ['Cemento'],
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildDarkFilterChip(
                                label: 'Césped',
                                isSelected: state.superficiesFiltro.contains(
                                  'Césped',
                                ),
                                onSelected: () {
                                  final activo = state.superficiesFiltro
                                      .contains('Césped');
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro:
                                          state.modalidadesFiltro,
                                      superficiesFiltro: activo
                                          ? const []
                                          : const ['Césped'],
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _headerSlideAnimation,
                        child: _buildSectionHeader(partidosDisponibles.length),
                      ),
                      const SizedBox(height: 12),
                      // Lista de Partidos con Pull to Refresh
                      Expanded(
                        child: state.isLoadingFeed
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.accentLimeColor,
                                ),
                              )
                            : RefreshIndicator(
                                color: AppTheme.accentLimeColor,
                                backgroundColor: const Color(0xFF161E1A),
                                onRefresh: () async {
                                  context.read<MatchesBloc>().add(
                                    LoadMatchesAction(
                                      modalidadesFiltro:
                                          state.modalidadesFiltro,
                                      superficiesFiltro:
                                          state.superficiesFiltro,
                                      nivelesFiltro: state.nivelesFiltro,
                                      nivelUsuario: nivelUsuario,
                                    ),
                                  );
                                },
                                child: partidosDisponibles.isEmpty
                                    ? ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(
                                          top: 40,
                                          bottom: 120,
                                        ),
                                        children: [
                                          Center(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 32,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF161E1A),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme
                                                          .accentLimeColor
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      state.totalFiltrosActivos >
                                                              0
                                                          ? Icons
                                                                .filter_alt_off_rounded
                                                          : Icons
                                                                .sports_tennis_rounded,
                                                      size: 38,
                                                      color: AppTheme
                                                          .accentLimeColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    state.totalFiltrosActivos >
                                                            0
                                                        ? 'No hay partidos con estos filtros'
                                                        : 'No hay partidos disponibles',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    state.totalFiltrosActivos >
                                                            0
                                                        ? 'No encontramos partidos disponibles con esos filtros. Probá cambiando los filtros o limpiando la selección.'
                                                        : 'Tus partidos confirmados están en "Mis Partidos".\nPodés armar una nueva cancha con el botón (+).',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color(0xFF8E9A93),
                                                      fontSize: 13,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  if (state
                                                          .totalFiltrosActivos >
                                                      0)
                                                    OutlinedButton.icon(
                                                      onPressed: () {
                                                        context
                                                            .read<MatchesBloc>()
                                                            .add(
                                                              const LoadMatchesAction(),
                                                            );
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        backgroundColor:
                                                            AppTheme
                                                                .accentLimeColor
                                                                .withValues(
                                                                  alpha: 0.12,
                                                                ),
                                                        side: const BorderSide(
                                                          color: AppTheme
                                                              .accentLimeColor,
                                                          width: 1.2,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      icon: const Icon(
                                                        Icons.refresh_rounded,
                                                        size: 16,
                                                        color: AppTheme
                                                            .accentLimeColor,
                                                      ),
                                                      label: const Text(
                                                        'Limpiar filtros',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .accentLimeColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : ListView.separated(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(
                                          bottom: 120,
                                        ),
                                        itemCount: partidosDisponibles.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(height: 14),
                                        itemBuilder: (context, index) {
                                          final partido =
                                              partidosDisponibles[index];
                                          return PartidoCard(
                                            partido: partido,
                                            directorioJugadores: profileState
                                                .directorioJugadores,
                                            onTap: () {
                                              Navigator.of(context).push(
                                                SmokePageRoute(
                                                  child: MatchDetailScreen(
                                                    partidoId: partido.id,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _exitAnimController,
                  builder: (context, child) {
                    return Offstage(
                      offstage: _exitAnimController.value == 0.0,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _exitAnimController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                  child: MapFeedScreen(onToggle: (val) => _toggleMap()),
                ),
              ),

              // Píldora flotante interpolada (Lista | Mapa)
              AnimatedBuilder(
                animation: _exitAnimController,
                builder: (context, child) {
                  final double t = _exitAnimController.value;
                  final double curTop = listTop + (mapTop - listTop) * t;
                  final double curLeft = listLeft + (mapLeft - listLeft) * t;
                  final double curWidth =
                      listWidth + (mapWidth - listWidth) * t;

                  return Positioned(
                    top: curTop,
                    left: curLeft,
                    width: curWidth,
                    height: 38,
                    child: _buildFloatingPillBody(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
