import '../../domain/entities/mensaje_entity.dart';

// EL TRADUCTOR DE MENSAJES (DTO en Capa Data de Chat)
class MensajeDto {
  static MensajeEntity transformarDesdeBDD(Map<String, dynamic> datos) {
    return MensajeEntity(
      id: datos['id']?.toString() ?? '',
      partidoId: datos['partidoId']?.toString() ?? '',
      autorId: datos['autorId']?.toString() ?? '',
      autorNombre: datos['autorNombre']?.toString() ?? 'Jugador',
      autorAvatar:
          datos['autorAvatar']?.toString() ??
          'https://i.pravatar.cc/300?img=12',
      texto: datos['texto']?.toString() ?? '',
      fechaHora: datos['fechaHora'] != null
          ? DateTime.parse(datos['fechaHora'].toString())
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> aMapaBDD(MensajeEntity mensaje) {
    return {
      'id': mensaje.id,
      'partidoId': mensaje.partidoId,
      'autorId': mensaje.autorId,
      'autorNombre': mensaje.autorNombre,
      'autorAvatar': mensaje.autorAvatar,
      'texto': mensaje.texto,
      'fechaHora': mensaje.fechaHora.toIso8601String(),
    };
  }
}
