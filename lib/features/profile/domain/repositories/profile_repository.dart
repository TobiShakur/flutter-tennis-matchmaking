import '../entities/jugador_entity.dart';

// CONTRATO DEL REPOSITORIO DE PERFILES (Capa Domain)
abstract class ProfileRepository {
  /// Trae el perfil de un jugador por su ID (sirve para Mi Cuenta y para ver a otro jugador)
  Future<JugadorEntity> traerPerfilJugador(String usuarioId);

  /// Trae el mapa de todos los jugadores para mostrar nombres y fotos en las canchas
  Future<Map<String, JugadorEntity>> traerTodosLosJugadores();

  /// Actualiza los datos o preferencias de tu cuenta
  Future<JugadorEntity> actualizarMiPerfil({
    required String usuarioId,
    String? nuevoNombre,
    String? nuevoNivel,
    String? nuevoBarrio,
    String? nuevaSuperficie,
    String? nuevaManoHabil,
    int? nuevoRadioKm,
    String? nuevoAvatarUrl,
  });

  /// Trae la lista de IDs de usuarios bloqueados
  Future<List<String>> traerUsuariosBloqueados();

  /// Bloquea a un jugador por su ID
  Future<void> bloquearUsuario(String usuarioId);

  /// Desbloquea a un jugador por su ID
  Future<void> desbloquearUsuario(String usuarioId);
}
