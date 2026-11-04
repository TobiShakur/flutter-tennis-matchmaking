import '../entities/mensaje_entity.dart';

// CONTRATO DEL REPOSITORIO DE CHAT Y MODERACIÓN UGC (Capa Domain)
abstract class ChatRepository {
  /// Trae los mensajes del partido (excluyendo jugadores bloqueados)
  Future<List<MensajeEntity>> traerMensajesPartido(
    String partidoId, {
    required List<String> usuariosBloqueadosIds,
  });

  /// Envía un mensaje nuevo al grupo del partido
  Future<void> enviarMensaje(MensajeEntity nuevoMensaje);

  /// Borra un mensaje del chat
  Future<void> borrarMensaje(String mensajeId);
}
