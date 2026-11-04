import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/theme/app_theme.dart';

/// Modelo de datos con la cancha y ubicación seleccionada por el usuario
class CanchaUbicacionSeleccionada {
  final String clubNombre;
  final String direccion;
  final String barrio;
  final double latitud;
  final double longitud;
  final String superficieSugerida;

  const CanchaUbicacionSeleccionada({
    required this.clubNombre,
    required this.direccion,
    required this.barrio,
    required this.latitud,
    required this.longitud,
    required this.superficieSugerida,
  });
}

/// Clubes semilla emblemáticos de CABA
const List<CanchaUbicacionSeleccionada> kClubesTenisCABA = [
  CanchaUbicacionSeleccionada(
    clubNombre: 'El Abierto Tenis Club',
    direccion: 'Galván 3920, Saavedra',
    barrio: 'Saavedra, CABA',
    latitud: -34.5518,
    longitud: -58.4912,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Palermo Tenis Club',
    direccion: 'Av. Figueroa Alcorta 5575',
    barrio: 'Palermo, CABA',
    latitud: -34.5685,
    longitud: -58.4230,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Club Comercio Tenis',
    direccion: 'Av. del Libertador 7501',
    barrio: 'Núñez, CABA',
    latitud: -34.5452,
    longitud: -58.4610,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Downtown Tenis Club',
    direccion: 'San Martín 650',
    barrio: 'San Nicolás, CABA',
    latitud: -34.6010,
    longitud: -58.3750,
    superficieSugerida: 'Cemento',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Recoleta Tenis Center',
    direccion: 'Vicente López 2050',
    barrio: 'Recoleta, CABA',
    latitud: -34.5880,
    longitud: -58.3930,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Ferro Tenis Caballito',
    direccion: 'Federico García Lorca 350',
    barrio: 'Caballito, CABA',
    latitud: -34.6190,
    longitud: -58.4480,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Racket Club Palermo',
    direccion: 'Valentín Alsina 1450',
    barrio: 'Palermo, CABA',
    latitud: -34.5630,
    longitud: -58.4310,
    superficieSugerida: 'Cemento',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Buenos Aires Lawn Tennis Club',
    direccion: 'Olleros 1510',
    barrio: 'Palermo, CABA',
    latitud: -34.5615,
    longitud: -58.4405,
    superficieSugerida: 'Polvo de ladrillo',
  ),
  CanchaUbicacionSeleccionada(
    clubNombre: 'Belgrano Tenis Canchas',
    direccion: 'Monroe 1850',
    barrio: 'Belgrano, CABA',
    latitud: -34.5550,
    longitud: -58.4550,
    superficieSugerida: 'Cemento',
  ),
];

/// Pantalla interactiva para seleccionar la ubicación de la cancha en el mapa de CABA.
class LocationPickerMapScreen extends StatefulWidget {
  final CanchaUbicacionSeleccionada? initialSelection;

  const LocationPickerMapScreen({super.key, this.initialSelection});

  @override
  State<LocationPickerMapScreen> createState() =>
      _LocationPickerMapScreenState();
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  late CanchaUbicacionSeleccionada _selectedClub;
  late LatLng _mapCenter;
  bool _mostrarSugerencias = false;
  List<CanchaUbicacionSeleccionada> _sugerencias = [];

  @override
  void initState() {
    super.initState();
    _selectedClub = widget.initialSelection ?? kClubesTenisCABA.first;
    _mapCenter = LatLng(_selectedClub.latitud, _selectedClub.longitud);
    _sugerencias = kClubesTenisCABA;

    _searchCtrl.addListener(() {
      final query = _searchCtrl.text.toLowerCase().trim();
      setState(() {
        if (query.isEmpty) {
          _sugerencias = kClubesTenisCABA;
        } else {
          _sugerencias = kClubesTenisCABA.where((c) {
            return c.clubNombre.toLowerCase().contains(query) ||
                c.direccion.toLowerCase().contains(query) ||
                c.barrio.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _seleccionarClub(CanchaUbicacionSeleccionada club) {
    setState(() {
      _selectedClub = club;
      _mapCenter = LatLng(club.latitud, club.longitud);
      _mostrarSugerencias = false;
      _searchCtrl.text = club.clubNombre;
    });
    _animatedMapMove(_mapCenter, 15.5);
  }

  void _confirmar() {
    Navigator.of(context).pop(_selectedClub);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _mapCenter = camera.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.googleMapsTileUrl,
                subdomains: MapConfig.googleMapsSubdomains,
                userAgentPackageName: 'com.setpoint.tenisapp',
                tileProvider: CancellableNetworkTileProvider(),
              ),

              // Marcadores de todos los clubes de CABA
              MarkerLayer(
                markers: kClubesTenisCABA.map((club) {
                  final bool esSeleccionado =
                      _selectedClub.clubNombre == club.clubNombre;
                  return Marker(
                    point: LatLng(club.latitud, club.longitud),
                    width: esSeleccionado ? 48 : 40,
                    height: esSeleccionado ? 48 : 40,
                    child: GestureDetector(
                      onTap: () => _seleccionarClub(club),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: esSeleccionado
                              ? AppTheme.accentLimeColor
                              : const Color(0xFF141C18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: esSeleccionado
                                ? const Color(0xFF0E1311)
                                : AppTheme.accentLimeColor,
                            width: esSeleccionado ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentLimeColor.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.sports_tennis_rounded,
                          size: esSeleccionado ? 24 : 18,
                          color: esSeleccionado
                              ? const Color(0xFF0E1311)
                              : AppTheme.accentLimeColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppTheme.buildGlassBackButton(context),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141C18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppTheme.accentLimeColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onTap: () => setState(
                                    () => _mostrarSugerencias = true,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Buscar club o cancha...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF8E9A93),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF8E9A93),
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // LISTA DE SUGERENCIAS DE CLUBES (Si el buscador está activo)
                  if (_mostrarSugerencias)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141C18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _sugerencias.length,
                        separatorBuilder: (_, _) => Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final club = _sugerencias[index];
                          return ListTile(
                            dense: true,
                            leading: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFF1B2721),
                              child: Icon(
                                Icons.sports_tennis_rounded,
                                color: AppTheme.accentLimeColor,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              club.clubNombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${club.direccion} • ${club.barrio}',
                              style: const TextStyle(
                                color: Color(0xFF8E9A93),
                                fontSize: 11.5,
                              ),
                            ),
                            onTap: () => _seleccionarClub(club),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121A15),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.accentLimeColor.withValues(alpha: 0.4),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLimeColor.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentLimeColor,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.sports_tennis_rounded,
                          color: AppTheme.accentLimeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedClub.clubNombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_selectedClub.direccion} • ${_selectedClub.barrio}',
                              style: const TextStyle(
                                color: Color(0xFF8E9A93),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // BOTÓN CONFIRMAR UBICACIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentLimeColor,
                        foregroundColor: const Color(0xFF0E1311),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.accentLimeColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      onPressed: _confirmar,
                      child: const Text(
                        'Confirmar esta Cancha',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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
      ),
    );
  }
}
