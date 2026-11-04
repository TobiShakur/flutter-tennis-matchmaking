import '../../domain/entities/jugador_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/jugador_dto.dart';

// REPOSITORIO LOCAL DE JUGADORES E HISTORIALES
class LocalProfileRepository implements ProfileRepository {
  final Map<String, Map<String, dynamic>> _usuariosCrudos =
      _crearJugadoresSemilla();
  final List<String> _usuariosBloqueados = [];

  @override
  Future<JugadorEntity> traerPerfilJugador(String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final datos =
        _usuariosCrudos[usuarioId] ?? _usuariosCrudos['user_tobias_01']!;
    return JugadorDto.transformarDesdeBDD(datos);
  }

  @override
  Future<Map<String, JugadorEntity>> traerTodosLosJugadores() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final Map<String, JugadorEntity> resultado = {};
    for (final entry in _usuariosCrudos.entries) {
      resultado[entry.key] = JugadorDto.transformarDesdeBDD(entry.value);
    }
    return resultado;
  }

  @override
  Future<JugadorEntity> actualizarMiPerfil({
    required String usuarioId,
    String? nuevoNombre,
    String? nuevoNivel,
    String? nuevoBarrio,
    String? nuevaSuperficie,
    String? nuevaManoHabil,
    int? nuevoRadioKm,
    String? nuevoAvatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final actual = _usuariosCrudos[usuarioId];
    if (actual != null) {
      final mapaActualizado = Map<String, dynamic>.from(actual);
      if (nuevoNombre != null) {
        mapaActualizado['nombre'] = nuevoNombre;
      }
      if (nuevoNivel != null) {
        mapaActualizado['nivel'] = nuevoNivel;
      }
      if (nuevoBarrio != null) {
        mapaActualizado['barrio'] = nuevoBarrio;
      }
      if (nuevaSuperficie != null) {
        mapaActualizado['superficieFavorita'] = nuevaSuperficie;
      }
      if (nuevaManoHabil != null) {
        mapaActualizado['manoHabil'] = nuevaManoHabil;
      }
      if (nuevoRadioKm != null) {
        mapaActualizado['radioBusquedaKm'] = nuevoRadioKm;
      }
      if (nuevoAvatarUrl != null) {
        mapaActualizado['avatarUrl'] = nuevoAvatarUrl;
      }
      _usuariosCrudos[usuarioId] = mapaActualizado;
    }
    return JugadorDto.transformarDesdeBDD(_usuariosCrudos[usuarioId]!);
  }

  @override
  Future<List<String>> traerUsuariosBloqueados() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List<String>.from(_usuariosBloqueados);
  }

  @override
  Future<void> bloquearUsuario(String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_usuariosBloqueados.contains(usuarioId)) {
      _usuariosBloqueados.add(usuarioId);
    }
  }

  @override
  Future<void> desbloquearUsuario(String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _usuariosBloqueados.remove(usuarioId);
  }

  static Map<String, Map<String, dynamic>> _crearJugadoresSemilla() {
    final ahora = DateTime.now();
    return {
      'user_tobias_01': {
        'id': 'user_tobias_01',
        'nombre': 'Tobías Shakur',
        'avatarUrl': 'https://i.pravatar.cc/300?img=12',
        'bio':
            'Juego en polvo de ladrillo por Palermo y Núñez. Busco partidos intensos de Singles o Dobles.',
        'nivel': 'Intermedio',
        'manoHabil': 'Diestro',
        'tipoReves': 'Revés a dos manos',
        'superficieFavorita': 'Polvo de ladrillo',
        'barrio': 'Palermo, CABA',
        'radioBusquedaKm': 12,
        'historial': [
          {
            'id': 'hist_01',
            'titulo': 'Singles Nocturno vs Martín',
            'clubNombre': 'Club Comercio Tenis',
            'modalidad': 'Singles',
            'superficie': 'Polvo de ladrillo',
            'resultado': '6-4 / 7-5',
            'fecha': ahora.subtract(const Duration(days: 3)).toIso8601String(),
            'victoria': true,
          },
          {
            'id': 'hist_02',
            'titulo': 'Dobles de Sábado',
            'clubNombre': 'El Abierto Tenis Club',
            'modalidad': 'Dobles',
            'superficie': 'Polvo de ladrillo',
            'resultado': '6-3 / 4-6 / 10-7',
            'fecha': ahora.subtract(const Duration(days: 9)).toIso8601String(),
            'victoria': true,
          },
          {
            'id': 'hist_03',
            'titulo': 'Singles Cancha Rápida',
            'clubNombre': 'Belgrano Tenis Canchas',
            'modalidad': 'Singles',
            'superficie': 'Cemento',
            'resultado': '4-6 / 5-7',
            'fecha': ahora.subtract(const Duration(days: 15)).toIso8601String(),
            'victoria': false,
          },
        ],
      },
      'user_martin_02': {
        'id': 'user_martin_02',
        'nombre': 'Martín Gómez',
        'avatarUrl': 'https://i.pravatar.cc/300?img=33',
        'bio': 'Saque y red. Siempre llevo pelotas nuevas a la cancha.',
        'nivel': 'Intermedio',
        'manoHabil': 'Diestro',
        'tipoReves': 'Revés a una mano',
        'superficieFavorita': 'Polvo de ladrillo',
        'barrio': 'Colegiales, CABA',
        'radioBusquedaKm': 10,
        'historial': [
          {
            'id': 'hist_m1',
            'titulo': 'Dobles en El Abierto',
            'clubNombre': 'El Abierto Tenis Club',
            'modalidad': 'Dobles',
            'superficie': 'Polvo de ladrillo',
            'resultado': '6-2 / 6-4',
            'fecha': ahora.subtract(const Duration(days: 2)).toIso8601String(),
            'victoria': true,
          },
          {
            'id': 'hist_m2',
            'titulo': 'Singles Nocturno vs Tobías',
            'clubNombre': 'Club Comercio Tenis',
            'modalidad': 'Singles',
            'superficie': 'Polvo de ladrillo',
            'resultado': '4-6 / 5-7',
            'fecha': ahora.subtract(const Duration(days: 3)).toIso8601String(),
            'victoria': false,
          },
        ],
      },
      'user_lucas_03': {
        'id': 'user_lucas_03',
        'nombre': 'Lucas Rodríguez',
        'avatarUrl': 'https://i.pravatar.cc/300?img=53',
        'bio': 'Jugador de fondo de cancha, me gusta pelotear largo.',
        'nivel': 'Básico',
        'manoHabil': 'Zurdo',
        'tipoReves': 'Revés a dos manos',
        'superficieFavorita': 'Polvo de ladrillo',
        'barrio': 'Caballito, CABA',
        'radioBusquedaKm': 8,
        'historial': [
          {
            'id': 'hist_l1',
            'titulo': 'Dobles en Ferro',
            'clubNombre': 'Ferro Tenis Caballito',
            'modalidad': 'Dobles',
            'superficie': 'Polvo de ladrillo',
            'resultado': '6-4 / 6-4',
            'fecha': ahora.subtract(const Duration(days: 5)).toIso8601String(),
            'victoria': true,
          },
        ],
      },
      'user_santi_04': {
        'id': 'user_santi_04',
        'nombre': 'Santiago Vega',
        'avatarUrl': 'https://i.pravatar.cc/300?img=60',
        'bio': 'Ex jugador de interclubes. Busco Singles a 3 sets.',
        'nivel': 'Experto',
        'manoHabil': 'Diestro',
        'tipoReves': 'Revés a dos manos',
        'superficieFavorita': 'Cemento',
        'barrio': 'Belgrano, CABA',
        'radioBusquedaKm': 15,
        'historial': [
          {
            'id': 'hist_s1',
            'titulo': 'Entrenamiento Interclubes',
            'clubNombre': 'Racket Club Palermo',
            'modalidad': 'Singles',
            'superficie': 'Cemento',
            'resultado': '6-1 / 6-2',
            'fecha': ahora.subtract(const Duration(days: 1)).toIso8601String(),
            'victoria': true,
          },
        ],
      },
      'user_nico_05': {
        'id': 'user_nico_05',
        'nombre': 'Nicolás P.',
        'avatarUrl': 'https://i.pravatar.cc/300?img=68',
        'bio': 'Fanático de las canchas rápidas de cemento.',
        'nivel': 'Avanzado',
        'manoHabil': 'Diestro',
        'tipoReves': 'Revés a una mano',
        'superficieFavorita': 'Cemento',
        'barrio': 'Belgrano, CABA',
        'radioBusquedaKm': 10,
        'historial': [
          {
            'id': 'hist_n1',
            'titulo': 'Singles Cancha Rápida',
            'clubNombre': 'Belgrano Tenis Canchas',
            'modalidad': 'Singles',
            'superficie': 'Cemento',
            'resultado': '7-6 / 6-4',
            'fecha': ahora.subtract(const Duration(days: 4)).toIso8601String(),
            'victoria': true,
          },
        ],
      },
    };
  }
}
