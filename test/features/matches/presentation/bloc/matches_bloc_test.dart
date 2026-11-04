import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tenis_app/features/matches/domain/entities/partido_entity.dart';
import 'package:tenis_app/features/matches/domain/errors/match_error.dart';
import 'package:tenis_app/features/matches/domain/repositories/matches_repository.dart';
import 'package:tenis_app/features/matches/presentation/bloc/matches_actions.dart';
import 'package:tenis_app/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:tenis_app/features/matches/presentation/bloc/matches_state.dart';

class MockMatchesRepository extends Mock implements MatchesRepository {}

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

  group('MatchesBloc Tests', () {
    late MockMatchesRepository mockRepo;
    late MatchesBloc bloc;

    setUp(() {
      mockRepo = MockMatchesRepository();
      bloc = MatchesBloc(repo: mockRepo);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<MatchesBloc, MatchesState>(
      'Emite isLoadingFeed true y luego la lista de partidos ordenada al cargar',
      build: () {
        when(
          () => mockRepo.traerPartidos(
            modalidad: any(named: 'modalidad'),
            superficie: any(named: 'superficie'),
            nivel: any(named: 'nivel'),
            modalidades: any(named: 'modalidades'),
            superficies: any(named: 'superficies'),
            niveles: any(named: 'niveles'),
          ),
        ).thenAnswer((_) async => [partidoCercano]);
        return bloc;
      },
      act: (b) => b.add(const LoadMatchesAction()),
      expect: () => [
        const MatchesState(isLoadingFeed: true),
        MatchesState(partidos: [partidoCercano], isLoadingFeed: false),
      ],
    );

    blocTest<MatchesBloc, MatchesState>(
      'Emite MatchErrorCanchaCompleta cuando se intenta unir a un partido sin cupo',
      build: () {
        when(
          () => mockRepo.unirseAPartido('match_lleno', 'user_tobias_01'),
        ).thenThrow(const MatchErrorCanchaCompleta());
        return bloc;
      },
      act: (b) => b.add(
        const JoinMatchAction(
          partidoId: 'match_lleno',
          usuarioId: 'user_tobias_01',
        ),
      ),
      expect: () => [
        const MatchesState(procesandoPartidoId: 'match_lleno'),
        const MatchesState(
          procesandoPartidoId: null,
          matchError: MatchErrorCanchaCompleta(),
        ),
      ],
    );

    blocTest<MatchesBloc, MatchesState>(
      'UpdateMatchAction actualiza el partido en el repo y emite mensajeExito',
      build: () {
        when(
          () => mockRepo.actualizarPartido(partidoCercano),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.traerPartidos(
            modalidad: any(named: 'modalidad'),
            superficie: any(named: 'superficie'),
            nivel: any(named: 'nivel'),
            modalidades: any(named: 'modalidades'),
            superficies: any(named: 'superficies'),
            niveles: any(named: 'niveles'),
          ),
        ).thenAnswer((_) async => [partidoCercano]);
        return bloc;
      },
      act: (b) => b.add(UpdateMatchAction(partidoActualizado: partidoCercano)),
      expect: () => [
        const MatchesState(isLoadingFeed: true),
        MatchesState(
          partidos: [partidoCercano],
          isLoadingFeed: false,
          mensajeExito: 'Partido actualizado con éxito.',
        ),
      ],
    );

    blocTest<MatchesBloc, MatchesState>(
      'DeleteMatchAction cancela el partido en el repo y emite mensajeExito',
      build: () {
        when(
          () => mockRepo.cancelarPartido('match_cercano'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.traerPartidos(
            modalidad: any(named: 'modalidad'),
            superficie: any(named: 'superficie'),
            nivel: any(named: 'nivel'),
            modalidades: any(named: 'modalidades'),
            superficies: any(named: 'superficies'),
            niveles: any(named: 'niveles'),
          ),
        ).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const DeleteMatchAction(partidoId: 'match_cercano')),
      expect: () => [
        const MatchesState(isLoadingFeed: true),
        const MatchesState(
          partidos: [],
          isLoadingFeed: false,
          mensajeExito: 'Partido cancelado y eliminado correctamente.',
        ),
      ],
    );
  });
}
