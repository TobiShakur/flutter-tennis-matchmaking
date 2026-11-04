import 'package:flutter_test/flutter_test.dart';
import 'package:tenis_app/features/matches/domain/entities/partido_entity.dart';
import 'package:tenis_app/features/matches/domain/usecases/calcular_relevancia_partido.dart';

void main() {
  final fechaBase = DateTime(2026, 11, 3, 18, 0);

  final partidoCercano = PartidoEntity(
    id: 'match_cercano',
    titulo: 'Dobles en Palermo',
    modalidad: 'Dobles',
    superficie: 'Polvo de ladrillo',
    nivel: 'Intermedio',
    organizadorId: 'user_martin_02',
    organizadorNombre: 'Martín',
    imagenUrl: 'https://example.com/cancha.jpg',
    fechaHora: fechaBase.add(const Duration(hours: 2)),
    fechaCreacion: fechaBase.subtract(const Duration(hours: 4)),
    cuposTotales: 4,
    jugadoresUnidosIds: const ['u1', 'u2', 'u3'],
    clubNombre: 'El Abierto',
    direccion: 'Palermo',
    latitud: -34.5781,
    longitud: -58.4260,
  );

  final partidoLleno = PartidoEntity(
    id: 'match_lleno',
    titulo: 'Singles Completo',
    modalidad: 'Singles',
    superficie: 'Cemento',
    nivel: 'Intermedio',
    organizadorId: 'user_nico_05',
    organizadorNombre: 'Nico',
    imagenUrl: 'https://example.com/cancha2.jpg',
    fechaHora: fechaBase.add(const Duration(hours: 2)),
    fechaCreacion: fechaBase.subtract(const Duration(hours: 4)),
    cuposTotales: 2,
    jugadoresUnidosIds: const ['u1', 'u2'],
    clubNombre: 'Belgrano Tenis',
    direccion: 'Belgrano',
    latitud: -34.5781,
    longitud: -58.4260,
    estado: EstadoPartido.canchaCompleta,
  );

  group('CalcularRelevanciaPartido (Domain UseCase)', () {
    final useCase = CalcularRelevanciaPartido();

    test('Devuelve 0 si la cancha ya no tiene lugares libres', () {
      final score = useCase.calcular(
        partido: partidoLleno,
        nivelUsuario: 'Intermedio',
        usuarioLat: -34.5781,
        usuarioLng: -58.4260,
        fechaActual: fechaBase,
      );
      expect(score, 0.0);
    });

    test('Prioriza un partido de igual nivel y cercano', () {
      final scoreMismoNivel = useCase.calcular(
        partido: partidoCercano,
        nivelUsuario: 'Intermedio',
        usuarioLat: -34.5781,
        usuarioLng: -58.4260,
        fechaActual: fechaBase,
      );
      final scoreDistintoNivel = useCase.calcular(
        partido: partidoCercano,
        nivelUsuario: 'Experto',
        usuarioLat: -34.5781,
        usuarioLng: -58.4260,
        fechaActual: fechaBase,
      );
      expect(scoreMismoNivel, greaterThan(scoreDistintoNivel));
    });
  });
}
