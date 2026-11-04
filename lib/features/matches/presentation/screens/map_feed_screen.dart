import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/partido_entity.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import '../widgets/cluster_list_bottom_sheet.dart';
import '../widgets/match_detail_sheet.dart';

/// Pantalla de mapa interactivo con clustering geográfico y visualización de partidos.
class MapFeedScreen extends StatefulWidget {
  final ValueChanged<bool>? onToggle;

  const MapFeedScreen({super.key, this.onToggle});

  @override
  State<MapFeedScreen> createState() => _MapFeedScreenState();
}

class _MapFeedScreenState extends State<MapFeedScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late double _currentZoom;
  bool _useGoogleMaps = true; // Por defecto: Google Maps (1:1 oficial)

  @override
  void initState() {
    super.initState();
    final radio = context.read<MatchesBloc>().state.radioKm;
    _currentZoom = _getZoomLevel(radio);
  }

  double _getZoomLevel(double radiusKm) {
    if (radiusKm <= 0) return 14.0;
    final calculated = 14.5 - (log(radiusKm) / log(2));
    return calculated.clamp(10.5, 17.5);
  }

  Future<void> _animatedMapMove(LatLng destLocation, double destZoom) async {
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    await controller.forward();
  }

  void _animarACentro(LatLng target, double zoom) {
    _animatedMapMove(target, zoom);
    setState(() => _currentZoom = zoom);
  }

  List<List<PartidoEntity>> _clusterizarPartidos(
    List<PartidoEntity> partidos,
    double zoom,
  ) {
    final List<List<PartidoEntity>> clusters = [];
    final double umbralGrados = 0.05 / pow(2, (zoom - 11).clamp(0, 7));

    for (final partido in partidos) {
      bool asignado = false;
      for (final cluster in clusters) {
        final centro = cluster.first;
        final dLat = (centro.latitud - partido.latitud).abs();
        final dLng = (centro.longitud - partido.longitud).abs();
        if (dLat < umbralGrados && dLng < umbralGrados) {
          cluster.add(partido);
          asignado = true;
          break;
        }
      }
      if (!asignado) {
        clusters.add([partido]);
      }
    }
    return clusters;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchesBloc, MatchesState>(
      listenWhen: (prev, curr) => prev.radioKm != curr.radioKm,
      listener: (context, state) {
        final newZoom = _getZoomLevel(state.radioKm);
        _animarACentro(LatLng(state.usuarioLat, state.usuarioLng), newZoom);
      },
      builder: (context, state) {
        final userLatLng = LatLng(state.usuarioLat, state.usuarioLng);
        final partidosDisponibles = state.partidos
            .where(
              (p) => !p.jugadoresUnidosIds.contains(AppConstants.currentUserId),
            )
            .toList();
        final clusters = _clusterizarPartidos(
          partidosDisponibles,
          _currentZoom,
        );
        final partidosRadioDisponibles = state.partidosDentroDelRadio
            .where(
              (p) => !p.jugadoresUnidosIds.contains(AppConstants.currentUserId),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLatLng,
                  initialZoom: _getZoomLevel(state.radioKm),
                  minZoom: 9.5,
                  maxZoom: 18.0,
                  onPositionChanged: (camera, hasGesture) {
                    if ((camera.zoom - _currentZoom).abs() > 0.08) {
                      setState(() => _currentZoom = camera.zoom);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: _useGoogleMaps
                        ? MapConfig.googleMapsTileUrl
                        : MapConfig.cartoVoyagerTileUrl,
                    subdomains: _useGoogleMaps
                        ? MapConfig.googleMapsSubdomains
                        : MapConfig.cartoSubdomains,
                    userAgentPackageName: 'com.setpoint.tenisapp',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),

                  // Círculo sombreado del radio en metros (Estilo Deportivo Lima Neón)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: userLatLng,
                        radius: state.radioKm * 1000,
                        useRadiusInMeter: true,
                        color: AppTheme.accentLimeColor.withValues(alpha: 0.10),
                        borderColor: AppTheme.accentLimeColor.withValues(
                          alpha: 0.6,
                        ),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),

                  // Marcadores de canchas y clusters
                  MarkerLayer(
                    markers: [
                      // Marcador del usuario actual (Punto azul con halo)
                      Marker(
                        point: userLatLng,
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2563EB),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Marcadores de partidos
                      ...clusters.map((cluster) {
                        final esClusterMultiple = cluster.length > 1;
                        final partidoPrincipal = cluster.first;
                        final double avgLat =
                            cluster
                                .map((p) => p.latitud)
                                .reduce((a, b) => a + b) /
                            cluster.length;
                        final double avgLng =
                            cluster
                                .map((p) => p.longitud)
                                .reduce((a, b) => a + b) /
                            cluster.length;
                        final pos = LatLng(avgLat, avgLng);

                        return Marker(
                          point: pos,
                          width: esClusterMultiple ? 46 : 42,
                          height: esClusterMultiple ? 46 : 42,
                          child: GestureDetector(
                            onTap: () async {
                              final previousCenter =
                                  _mapController.camera.center;
                              final previousZoom = _mapController.camera.zoom;

                              await _animatedMapMove(pos, 15.6);
                              if (!context.mounted) return;

                              if (esClusterMultiple) {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => ClusterListBottomSheet(
                                    partidos: cluster,
                                    userLat: state.usuarioLat,
                                    userLng: state.usuarioLng,
                                  ),
                                );
                              } else {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => MatchDetailSheet(
                                    partido: partidoPrincipal,
                                    userLat: state.usuarioLat,
                                    userLng: state.usuarioLng,
                                  ),
                                );
                              }

                              if (context.mounted) {
                                await _animatedMapMove(
                                  previousCenter,
                                  previousZoom,
                                );
                              }
                            },
                            child: esClusterMultiple
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentLimeColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0E1311),
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                        BoxShadow(
                                          color: AppTheme.accentLimeColor
                                              .withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${cluster.length}',
                                      style: const TextStyle(
                                        color: Color(0xFF0E1311),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141A17),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.accentLimeColor,
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                        BoxShadow(
                                          color: AppTheme.accentLimeColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.sports_tennis_rounded,
                                      color: AppTheme.accentLimeColor,
                                      size: 19,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Barra de navegación superior
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppTheme.buildGlassBackButton(
                              context,
                              onTap: () => widget.onToggle?.call(false),
                            ),
                            const SizedBox(width: 200, height: 40),
                            GestureDetector(
                              onTap: () {
                                _animarACentro(
                                  userLatLng,
                                  _getZoomLevel(state.radioKm),
                                );
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF161E1A,
                                  ).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.my_location,
                                  size: 20,
                                  color: AppTheme.accentLimeColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Píldora flotante de Radio: [ -  10 km  + ] (Dark Glass)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF141A17,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (state.radioKm > 1) {
                                    context.read<MatchesBloc>().add(
                                      UpdateRadiusAction(state.radioKm - 1),
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: AppTheme.accentLimeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${state.radioKm.toInt()} km',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  if (state.radioKm < 50) {
                                    context.read<MatchesBloc>().add(
                                      UpdateRadiusAction(state.radioKm + 1),
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppTheme.accentLimeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 130,
                right: 20,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _useGoogleMaps = !_useGoogleMaps);
                      AppTheme.showSnackBar(
                        context,
                        _useGoogleMaps
                            ? 'Estilo: Google Maps Oficial'
                            : 'Estilo: CartoDB Voyager (@2x)',
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E1A).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _useGoogleMaps
                            ? Icons.map_rounded
                            : Icons.layers_rounded,
                        size: 20,
                        color: AppTheme.accentLimeColor,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A17).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Ubicación actual:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8E9A93),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.direccionUsuario,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLimeColor.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentLimeColor,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '${partidosRadioDisponibles.length} Partidos cerca',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.accentLimeColor,
                              fontWeight: FontWeight.w800,
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
        );
      },
    );
  }
}
