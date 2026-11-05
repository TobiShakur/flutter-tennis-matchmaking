import '../../domain/entities/partido_entity.dart';
import '../../domain/errors/match_error.dart';
import '../../domain/repositories/matches_repository.dart';
import '../models/partido_dto.dart';

/// Implementación en memoria del repositorio de partidos para desarrollo y testing.
class LocalMatchesRepository implements MatchesRepository {
  final List<Map<String, dynamic>> _baseDeDatosCruda = _crearSemillaInicial();

  @override
  Future<List<PartidoEntity>> traerPartidos({
    String? modalidad,
    String? superficie,
    String? nivel,
    List<String>? modalidades,
    List<String>? superficies,
    List<String>? niveles,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final modFiltro =
        modalidades ??
        (modalidad != null && modalidad.isNotEmpty ? [modalidad] : null);
    final supFiltro =
        superficies ??
        (superficie != null && superficie.isNotEmpty ? [superficie] : null);
    final nivFiltro =
        niveles ?? (nivel != null && nivel.isNotEmpty ? [nivel] : null);

    final listaLimpia = _baseDeDatosCruda
        .map((mapaSucio) => PartidoDto.transformarDesdeBDD(mapaSucio))
        .where((partido) {
          if (modFiltro != null &&
              modFiltro.isNotEmpty &&
              !modFiltro.contains(partido.modalidad)) {
            return false;
          }
          if (supFiltro != null &&
              supFiltro.isNotEmpty &&
              !supFiltro.contains(partido.superficie)) {
            return false;
          }
          if (nivFiltro != null &&
              nivFiltro.isNotEmpty &&
              !nivFiltro.contains(partido.nivel)) {
            return false;
          }
          return partido.estado != EstadoPartido.cancelado;
        })
        .toList();

    return listaLimpia;
  }

  @override
  Future<void> crearPartido(PartidoEntity partidoNuevo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final mapaNuevo = PartidoDto.aMapaBDD(partidoNuevo);
    final List<String> jugadores = List<String>.from(
      mapaNuevo['joinedPlayerIds'] ?? [],
    );
    if (jugadores.isEmpty && partidoNuevo.organizadorId.isNotEmpty) {
      jugadores.add(partidoNuevo.organizadorId);
    } else if (partidoNuevo.organizadorId.isNotEmpty &&
        !jugadores.contains(partidoNuevo.organizadorId)) {
      jugadores.insert(0, partidoNuevo.organizadorId);
    }
    mapaNuevo['joinedPlayerIds'] = jugadores;
    _baseDeDatosCruda.insert(0, mapaNuevo);
  }

  @override
  Future<void> actualizarPartido(PartidoEntity partidoActualizado) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _baseDeDatosCruda.indexWhere(
      (m) => m['id'] == partidoActualizado.id,
    );
    if (index != -1) {
      final mapaExistente = _baseDeDatosCruda[index];
      final mapaActualizado = PartidoDto.aMapaBDD(partidoActualizado);
      // Preservar los jugadores ya unidos en la cancha
      mapaActualizado['joinedPlayerIds'] =
          mapaExistente['joinedPlayerIds'] ??
          [partidoActualizado.organizadorId];
      _baseDeDatosCruda[index] = mapaActualizado;
    }
  }

  @override
  Future<void> unirseAPartido(String partidoId, String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _baseDeDatosCruda.indexWhere((m) => m['id'] == partidoId);
    if (index == -1) {
      throw const MatchErrorGeneral(
        'El partido ya no se encuentra disponible.',
      );
    }

    final partidoActual = PartidoDto.transformarDesdeBDD(
      _baseDeDatosCruda[index],
    );

    if (partidoActual.jugadoresUnidosIds.contains(usuarioId)) {
      throw const MatchErrorYaAnotado();
    }

    if (partidoActual.estaLleno) {
      throw const MatchErrorCanchaCompleta();
    }

    final nuevosJugadores = [...partidoActual.jugadoresUnidosIds, usuarioId];
    final nuevoStatus = nuevosJugadores.length >= partidoActual.cuposTotales
        ? 'completed'
        : 'missingPlayer';

    _baseDeDatosCruda[index] = {
      ..._baseDeDatosCruda[index],
      'joinedPlayerIds': nuevosJugadores,
      'status': nuevoStatus,
    };
  }

  @override
  Future<void> salirDePartido(String partidoId, String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final index = _baseDeDatosCruda.indexWhere((m) => m['id'] == partidoId);
    if (index == -1) return;

    final List<String> jugadores = List<String>.from(
      _baseDeDatosCruda[index]['joinedPlayerIds'] ?? [],
    )..remove(usuarioId);

    _baseDeDatosCruda[index] = {
      ..._baseDeDatosCruda[index],
      'joinedPlayerIds': jugadores,
      'status': 'missingPlayer',
    };
  }

  @override
  Future<void> cancelarPartido(String partidoId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _baseDeDatosCruda.removeWhere((m) => m['id'] == partidoId);
  }

  static List<Map<String, dynamic>> _crearSemillaInicial() {
    final ahora = DateTime.now();
    return [
      {
        'id': 'match_01',
        'title': 'Singles Vespertino en Microcentro',
        'modalidad': 'Singles',
        'superficie': 'Cemento',
        'level': 'Intermedio',
        'organizerId': 'user_martin_02',
        'organizerName': 'Martín Gómez',
        'imageUrl':
            'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800',
        'dateTime': ahora.add(const Duration(hours: 3)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 3)).toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_martin_02'],
        'clubName': 'Downtown Tenis Club',
        'direccion': 'Tucumán 850',
        'barrio': 'San Nicolás',
        'lat': -34.6005,
        'lng': -58.3780,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_02',
        'title': 'Dobles Clásico en Recoleta',
        'modalidad': 'Dobles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Intermedio',
        'organizerId': 'user_nico_05',
        'organizerName': 'Nicolás P.',
        'imageUrl':
            'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
        'dateTime': ahora.add(const Duration(hours: 5)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 4)).toIso8601String(),
        'capacity': 4,
        'joinedPlayerIds': ['user_nico_05', 'user_lucas_03', 'user_santi_04'],
        'clubName': 'Recoleta Tenis Center',
        'direccion': 'Av. Callao 1850',
        'barrio': 'Recoleta',
        'lat': -34.5875,
        'lng': -58.3930,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_03',
        'title': 'Desafío Cancha 1 — Palermo Chico',
        'modalidad': 'Singles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Avanzado',
        'organizerId': 'user_santi_04',
        'organizerName': 'Santiago Vega',
        'imageUrl':
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
        'dateTime': ahora.add(const Duration(hours: 6)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 6)).toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_santi_04'],
        'clubName': 'Palermo Tenis Club (Cancha 1)',
        'direccion': 'Av. Figueroa Alcorta 3300',
        'barrio': 'Palermo Chico',
        'lat': -34.5765,
        'lng': -58.4120,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_04',
        'title': 'Dobles Cancha 4 — Palermo Chico',
        'modalidad': 'Dobles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Intermedio',
        'organizerId': 'user_martin_02',
        'organizerName': 'Martín Gómez',
        'imageUrl':
            'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=800',
        'dateTime': ahora.add(const Duration(hours: 7)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 8)).toIso8601String(),
        'capacity': 4,
        'joinedPlayerIds': ['user_martin_02', 'user_tobias_01'],
        'clubName': 'Palermo Tenis Club (Cancha 4)',
        'direccion': 'Av. Figueroa Alcorta 3350',
        'barrio': 'Palermo Chico',
        'lat': -34.5769,
        'lng': -58.4125,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_05',
        'title': 'Dobles Amistoso en Caballito',
        'modalidad': 'Dobles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Básico',
        'organizerId': 'user_lucas_03',
        'organizerName': 'Lucas Rodríguez',
        'imageUrl':
            'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
        'dateTime': ahora.add(const Duration(hours: 24)).toIso8601String(),
        'createdAt': ahora
            .subtract(const Duration(hours: 12))
            .toIso8601String(),
        'capacity': 4,
        'joinedPlayerIds': ['user_lucas_03', 'user_tobias_01'],
        'clubName': 'Ferro Tenis',
        'direccion': 'Av. Avellaneda 1240',
        'barrio': 'Caballito',
        'lat': -34.6186,
        'lng': -58.4475,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_06',
        'title': 'Singles Rápido a 3 Sets',
        'modalidad': 'Singles',
        'superficie': 'Cemento',
        'level': 'Avanzado',
        'organizerId': 'user_nico_05',
        'organizerName': 'Nicolás P.',
        'imageUrl':
            'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=800',
        'dateTime': ahora.add(const Duration(hours: 10)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 5)).toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_nico_05'],
        'clubName': 'Belgrano Tenis Canchas',
        'direccion': 'Juramento 1450',
        'barrio': 'Belgrano',
        'lat': -34.5588,
        'lng': -58.4491,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_07',
        'title': 'Entrenamiento Matutino en Núñez',
        'modalidad': 'Singles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Intermedio',
        'organizerId': 'user_tobias_01',
        'organizerName': 'Tobías (Vos)',
        'imageUrl':
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
        'dateTime': ahora.add(const Duration(hours: 14)).toIso8601String(),
        'createdAt': ahora
            .subtract(const Duration(hours: 10))
            .toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_tobias_01'],
        'clubName': 'Club Comercio Tenis',
        'direccion': 'Av. del Libertador 7199',
        'barrio': 'Núñez',
        'lat': -34.5441,
        'lng': -58.4582,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_08',
        'title': 'Desafío en Césped Natural',
        'modalidad': 'Singles',
        'superficie': 'Césped',
        'level': 'Intermedio',
        'organizerId': 'user_santi_04',
        'organizerName': 'Santiago Vega',
        'imageUrl':
            'https://images.unsplash.com/photo-1530915536846-99071597d344?w=800',
        'dateTime': ahora.add(const Duration(hours: 8)).toIso8601String(),
        'createdAt': ahora.subtract(const Duration(hours: 2)).toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_santi_04'],
        'clubName': 'Hurlingham Club Tenis',
        'direccion': 'Av. Roca 1411',
        'barrio': 'Hurlingham',
        'lat': -34.5900,
        'lng': -58.6300,
        'status': 'missingPlayer',
      },
      {
        'id': 'match_09',
        'title': 'Singles Nocturno en Palermo',
        'modalidad': 'Singles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Intermedio',
        'organizerId': 'user_martin_02',
        'organizerName': 'Martín Gómez',
        'imageUrl':
            'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
        'dateTime': ahora
            .subtract(const Duration(days: 3, hours: 2))
            .toIso8601String(),
        'createdAt': ahora.subtract(const Duration(days: 4)).toIso8601String(),
        'capacity': 2,
        'joinedPlayerIds': ['user_martin_02', 'user_tobias_01'],
        'clubName': 'Palermo Tenis Club',
        'direccion': 'Av. Figueroa Alcorta 3300',
        'barrio': 'Palermo Chico',
        'lat': -34.5765,
        'lng': -58.4120,
        'status': 'finished',
      },
      {
        'id': 'match_10',
        'title': 'Dobles Clásico de Fin de Semana',
        'modalidad': 'Dobles',
        'superficie': 'Polvo de ladrillo',
        'level': 'Intermedio',
        'organizerId': 'user_lucas_03',
        'organizerName': 'Lucas Rodríguez',
        'imageUrl':
            'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
        'dateTime': ahora
            .subtract(const Duration(days: 7, hours: 3))
            .toIso8601String(),
        'createdAt': ahora.subtract(const Duration(days: 8)).toIso8601String(),
        'capacity': 4,
        'joinedPlayerIds': [
          'user_lucas_03',
          'user_tobias_01',
          'user_nico_05',
          'user_santi_04',
        ],
        'clubName': 'Recoleta Tenis Center',
        'direccion': 'Av. Callao 1850',
        'barrio': 'Recoleta',
        'lat': -34.5875,
        'lng': -58.3930,
        'status': 'finished',
      },
    ];
  }
}
