import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_actions.dart';
import 'profile_state.dart';

// Manages active player session state, user directories, and moderation settings.
// Handles player profile editing (skill tier, dominant hand, court preference) and blocked user synchronization.
class ProfileBloc extends Bloc<ProfileAction, ProfileState> {
  final ProfileRepository repo;

  ProfileBloc({required this.repo}) : super(const ProfileState()) {
    on<LoadProfilesAction>(_onLoadProfiles);
    on<UpdateMyProfileAction>(_onUpdateMyProfile);
    on<BlockUserAction>(_onBlockUser);
    on<UnblockUserAction>(_onUnblockUser);
  }

  Future<void> _onLoadProfiles(
    LoadProfilesAction event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, mensajeExito: () => null));

    final todos = await repo.traerTodosLosJugadores();
    final miUsuario = todos[event.currentUserId];
    final bloqueados = await repo.traerUsuariosBloqueados();

    emit(
      state.copyWith(
        miPerfil: miUsuario,
        directorioJugadores: todos,
        usuariosBloqueadosIds: bloqueados,
        isLoading: false,
      ),
    );
  }

  Future<void> _onBlockUser(
    BlockUserAction event,
    Emitter<ProfileState> emit,
  ) async {
    await repo.bloquearUsuario(event.usuarioId);
    final nuevosBloqueados = await repo.traerUsuariosBloqueados();

    emit(
      state.copyWith(
        usuariosBloqueadosIds: nuevosBloqueados,
        mensajeExito: () => 'Jugador bloqueado correctamente.',
      ),
    );
  }

  Future<void> _onUnblockUser(
    UnblockUserAction event,
    Emitter<ProfileState> emit,
  ) async {
    await repo.desbloquearUsuario(event.usuarioId);
    final nuevosBloqueados = await repo.traerUsuariosBloqueados();

    emit(
      state.copyWith(
        usuariosBloqueadosIds: nuevosBloqueados,
        mensajeExito: () => 'Jugador desbloqueado correctamente.',
      ),
    );
  }

  Future<void> _onUpdateMyProfile(
    UpdateMyProfileAction event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, mensajeExito: () => null));

    final perfilActualizado = await repo.actualizarMiPerfil(
      usuarioId: event.usuarioId,
      nuevoNombre: event.nuevoNombre,
      nuevoNivel: event.nuevoNivel,
      nuevoBarrio: event.nuevoBarrio,
      nuevaSuperficie: event.nuevaSuperficie,
      nuevaManoHabil: event.nuevaManoHabil,
      nuevoRadioKm: event.nuevoRadioKm,
      nuevoAvatarUrl: event.nuevoAvatarUrl,
    );

    final nuevoDirectorio = {
      ...state.directorioJugadores,
      event.usuarioId: perfilActualizado,
    };

    emit(
      state.copyWith(
        miPerfil: perfilActualizado,
        directorioJugadores: nuevoDirectorio,
        isLoading: false,
        mensajeExito: () => 'Perfil actualizado con éxito.',
      ),
    );
  }
}
