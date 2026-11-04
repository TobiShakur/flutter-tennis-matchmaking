import 'dart:math';
import '../entities/partido_entity.dart';

// ALGORITMO DE RELEVANCIA PARA EL FEED DE TENIS (100% Dart Puro)
// Fórmula ponderada:
// Relevancia = 35% Distancia + 25% Nivel + 20% Urgencia + 10% Cupos + 10% Antigüedad
class CalcularRelevanciaPartido {
  double calcular({
    required PartidoEntity partido,
    required String nivelUsuario,
    required double usuarioLat,
    required double usuarioLng,
    DateTime? fechaActual,
  }) {
    final ahora = fechaActual ?? DateTime.now();

    final double scoreCupos = obtenerScoreCupos(partido);
    if (scoreCupos == 0) {
      return 0;
    }

    final double scoreDistancia = obtenerScoreDistancia(
      partido: partido,
      usuarioLat: usuarioLat,
      usuarioLng: usuarioLng,
    );
    final double scoreNivel = obtenerScoreNivel(
      nivelPartido: partido.nivel,
      nivelUsuario: nivelUsuario,
    );
    final double scoreUrgencia = obtenerScoreUrgencia(
      fechaPartido: partido.fechaHora,
      ahora: ahora,
    );
    final double scoreAntiguedad = obtenerScoreAntiguedad(
      fechaCreacion: partido.fechaCreacion,
      ahora: ahora,
    );

    return (0.35 * scoreDistancia) +
        (0.25 * scoreNivel) +
        (0.20 * scoreUrgencia) +
        (0.10 * scoreCupos) +
        (0.10 * scoreAntiguedad);
  }

  double obtenerScoreDistancia({
    required PartidoEntity partido,
    required double usuarioLat,
    required double usuarioLng,
  }) {
    final double distanciaKm = _calcularDistanciaKm(
      usuarioLat,
      usuarioLng,
      partido.latitud,
      partido.longitud,
    );
    return max(0, 1 - (distanciaKm / 20));
  }

  double obtenerScoreCupos(PartidoEntity partido) {
    if (partido.cuposTotales <= 0 || partido.cuposLibres <= 0) {
      return 0;
    }
    return 1 - (partido.cuposLibres / partido.cuposTotales);
  }

  double obtenerScoreUrgencia({
    required DateTime fechaPartido,
    required DateTime ahora,
  }) {
    final double horasHastaInicio =
        fechaPartido.difference(ahora).inMinutes / 60.0;
    if (horasHastaInicio < 0) {
      return 0;
    }
    return 1 / (1 + (horasHastaInicio / 48));
  }

  double obtenerScoreNivel({
    required String nivelPartido,
    required String nivelUsuario,
  }) {
    const Map<String, int> mapaNiveles = {
      'Principiante': 1,
      'Básico': 2,
      'Intermedio': 3,
      'Avanzado': 4,
      'Experto': 5,
    };

    final int valorUsuario = mapaNiveles[nivelUsuario] ?? 3;
    final int valorPartido = mapaNiveles[nivelPartido] ?? 3;

    return 1 - ((valorUsuario - valorPartido).abs() / 4);
  }

  double obtenerScoreAntiguedad({
    required DateTime fechaCreacion,
    required DateTime ahora,
  }) {
    final double horasPublicado =
        ahora.difference(fechaCreacion).inMinutes / 60.0;
    if (horasPublicado < 0) {
      return 0;
    }
    return min(1, horasPublicado / 128);
  }

  double _calcularDistanciaKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double radioTierraKm = 6371.0;
    final double dLat = _gradosARadianes(lat2 - lat1);
    final double dLon = _gradosARadianes(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradosARadianes(lat1)) *
            cos(_gradosARadianes(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierraKm * c;
  }

  double _gradosARadianes(double grados) => grados * (pi / 180.0);
}
