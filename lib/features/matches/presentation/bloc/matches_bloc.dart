import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/partido_entity.dart';
import '../../domain/errors/match_error.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../domain/usecases/calcular_relevancia_partido.dart';
import 'matches_actions.dart';
import 'matches_state.dart';

// Central BLoC managing match discovery, multi-criteria filtering, and organizer actions.
// Handles feed sorting by relevance, search radius clamping, slot reservation, and match updates/cancellation.
class MatchesBloc extends Bloc<MatchesAction, MatchesState> {
  final MatchesRepository repo;
  final CalcularRelevanciaPartido calcularRelevancia;

  MatchesBloc({
    required this.repo,
    CalcularRelevanciaPartido? calcularRelevancia,
  }) : calcularRelevancia = calcularRelevancia ?? CalcularRelevanciaPartido(),
       super(const MatchesState()) {
    on<LoadMatchesAction>(_onLoadMatches);
    on<UpdateRadiusAction>(_onUpdateRadius);
    on<JoinMatchAction>(_onJoinMatch);
    on<LeaveMatchAction>(_onLeaveMatch);
    on<CreateMatchAction>(_onCreateMatch);
    on<UpdateMatchAction>(_onUpdateMatch);
    on<DeleteMatchAction>(_onDeleteMatch);
  }

  void _onUpdateRadius(UpdateRadiusAction event, Emitter<MatchesState> emit) {
    final radioClamped = event.radioKm.clamp(1.0, 20.0);
    emit(state.copyWith(radioKm: radioClamped));
  }

  Future<void> _onLoadMatches(
    LoadMatchesAction event,
    Emitter<MatchesState> emit,
  ) async {
    final radioEfectivo = event.radioFiltroKm ?? state.radioKm;

    emit(
      state.copyWith(
        isLoadingFeed: true,
        modalidadesFiltro: event.modalidadesFiltro,
        superficiesFiltro: event.superficiesFiltro,
        nivelesFiltro: event.nivelesFiltro,
        radioKm: radioEfectivo,
        usuarioLat: event.usuarioLat,
        usuarioLng: event.usuarioLng,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      final lista = await repo.traerPartidos(
        modalidad: event.modalidadFiltro,
        superficie: event.superficieFiltro,
        nivel: event.nivelFiltro,
        modalidades: event.modalidadesFiltro,
        superficies: event.superficiesFiltro,
        niveles: event.nivelesFiltro,
      );

      final listaFiltradaRadio = lista.where((p) {
        final d = p.distanciaDesdeKm(event.usuarioLat, event.usuarioLng);
        return d <= radioEfectivo;
      }).toList();

      final listaOrdenada = _ordenarPorRelevancia(
        lista: listaFiltradaRadio,
        nivelUsuario: event.nivelUsuario,
        usuarioLat: event.usuarioLat,
        usuarioLng: event.usuarioLng,
      );

      emit(state.copyWith(partidos: listaOrdenada, isLoadingFeed: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFeed: false,
          matchError: () =>
              const MatchErrorGeneral('No pudimos cargar los partidos.'),
        ),
      );
    }
  }

  Future<void> _onJoinMatch(
    JoinMatchAction event,
    Emitter<MatchesState> emit,
  ) async {
    emit(
      state.copyWith(
        procesandoPartidoId: () => event.partidoId,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      await repo.unirseAPartido(event.partidoId, event.usuarioId);
      final listaActualizada = await repo.traerPartidos(
        modalidades: state.modalidadesFiltro,
        superficies: state.superficiesFiltro,
        niveles: state.nivelesFiltro,
      );

      emit(
        state.copyWith(
          partidos: _ordenarPorRelevancia(
            lista: listaActualizada,
            usuarioLat: state.usuarioLat,
            usuarioLng: state.usuarioLng,
          ),
          procesandoPartidoId: () => null,
          mensajeExito: () =>
              '¡Te anotaste a la cancha! Nos vemos en el partido.',
        ),
      );
    } on MatchError catch (errorTipado) {
      emit(
        state.copyWith(
          procesandoPartidoId: () => null,
          matchError: () => errorTipado,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          procesandoPartidoId: () => null,
          matchError: () =>
              const MatchErrorGeneral('No se pudo completar la inscripción.'),
        ),
      );
    }
  }

  Future<void> _onLeaveMatch(
    LeaveMatchAction event,
    Emitter<MatchesState> emit,
  ) async {
    emit(
      state.copyWith(
        procesandoPartidoId: () => event.partidoId,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      await repo.salirDePartido(event.partidoId, event.usuarioId);
      final listaActualizada = await repo.traerPartidos(
        modalidades: state.modalidadesFiltro,
        superficies: state.superficiesFiltro,
        niveles: state.nivelesFiltro,
      );

      emit(
        state.copyWith(
          partidos: _ordenarPorRelevancia(
            lista: listaActualizada,
            usuarioLat: state.usuarioLat,
            usuarioLng: state.usuarioLng,
          ),
          procesandoPartidoId: () => null,
          mensajeExito: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          procesandoPartidoId: () => null,
          matchError: () =>
              const MatchErrorGeneral('No se pudo salir del partido.'),
        ),
      );
    }
  }

  Future<void> _onCreateMatch(
    CreateMatchAction event,
    Emitter<MatchesState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingFeed: true,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      await repo.crearPartido(event.partidoNuevo);
      final listaActualizada = await repo.traerPartidos(
        modalidades: state.modalidadesFiltro,
        superficies: state.superficiesFiltro,
        niveles: state.nivelesFiltro,
      );

      emit(
        state.copyWith(
          partidos: _ordenarPorRelevancia(
            lista: listaActualizada,
            usuarioLat: state.usuarioLat,
            usuarioLng: state.usuarioLng,
          ),
          isLoadingFeed: false,
          mensajeExito: () => '¡Partido publicado en el Feed!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFeed: false,
          matchError: () =>
              const MatchErrorGeneral('No se pudo publicar el partido.'),
        ),
      );
    }
  }

  Future<void> _onUpdateMatch(
    UpdateMatchAction event,
    Emitter<MatchesState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingFeed: true,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      await repo.actualizarPartido(event.partidoActualizado);
      final listaActualizada = await repo.traerPartidos(
        modalidades: state.modalidadesFiltro,
        superficies: state.superficiesFiltro,
        niveles: state.nivelesFiltro,
      );

      emit(
        state.copyWith(
          partidos: _ordenarPorRelevancia(
            lista: listaActualizada,
            usuarioLat: state.usuarioLat,
            usuarioLng: state.usuarioLng,
          ),
          isLoadingFeed: false,
          mensajeExito: () => 'Partido actualizado con éxito.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFeed: false,
          matchError: () =>
              const MatchErrorGeneral('No se pudo actualizar el partido.'),
        ),
      );
    }
  }

  Future<void> _onDeleteMatch(
    DeleteMatchAction event,
    Emitter<MatchesState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingFeed: true,
        matchError: () => null,
        mensajeExito: () => null,
      ),
    );

    try {
      await repo.cancelarPartido(event.partidoId);
      final listaActualizada = await repo.traerPartidos(
        modalidades: state.modalidadesFiltro,
        superficies: state.superficiesFiltro,
        niveles: state.nivelesFiltro,
      );

      final listaFiltradaRadio = listaActualizada.where((p) {
        final d = p.distanciaDesdeKm(state.usuarioLat, state.usuarioLng);
        return d <= state.radioKm;
      }).toList();

      emit(
        state.copyWith(
          partidos: _ordenarPorRelevancia(
            lista: listaFiltradaRadio,
            usuarioLat: state.usuarioLat,
            usuarioLng: state.usuarioLng,
          ),
          isLoadingFeed: false,
          mensajeExito: () => 'Partido cancelado y eliminado correctamente.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFeed: false,
          matchError: () =>
              const MatchErrorGeneral('No se pudo eliminar el partido.'),
        ),
      );
    }
  }

  List<PartidoEntity> _ordenarPorRelevancia({
    required List<PartidoEntity> lista,
    String nivelUsuario = 'Intermedio',
    double usuarioLat = -34.6037,
    double usuarioLng = -58.3816,
  }) {
    final copia = List<PartidoEntity>.from(lista);
    copia.sort((a, b) {
      final scoreA = calcularRelevancia.calcular(
        partido: a,
        nivelUsuario: nivelUsuario,
        usuarioLat: usuarioLat,
        usuarioLng: usuarioLng,
      );
      final scoreB = calcularRelevancia.calcular(
        partido: b,
        nivelUsuario: nivelUsuario,
        usuarioLat: usuarioLat,
        usuarioLng: usuarioLng,
      );
      return scoreB.compareTo(scoreA);
    });
    return copia;
  }
}
