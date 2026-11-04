import '../entities/partido_entity.dart';

// Contrato del repositorio de partidos (Capa Domain)
abstract class MatchesRepository {
  /// Obtiene los partidos disponibles con soporte para filtros individuales o múltiples criterios.
  Future<List<PartidoEntity>> traerPartidos({
    String? modalidad,
    String? superficie,
    String? nivel,
    List<String>? modalidades,
    List<String>? superficies,
    List<String>? niveles,
  });

  /// Registra una nueva convocatoria o partido organizado.
  Future<void> crearPartido(PartidoEntity partidoNuevo);

  /// Actualiza los datos de un partido existente.
  Future<void> actualizarPartido(PartidoEntity partidoActualizado);

  /// Anota al jugador en la cancha validando disponibilidad de cupo.
  Future<void> unirseAPartido(String partidoId, String usuarioId);

  /// Remueve al jugador de la convocatoria liberando su cupo.
  Future<void> salirDePartido(String partidoId, String usuarioId);

  /// Cancela y elimina una convocatoria organizada.
  Future<void> cancelarPartido(String partidoId);
}
