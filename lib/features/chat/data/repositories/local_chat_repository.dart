import '../../domain/entities/mensaje_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/mensaje_dto.dart';

// REPOSITORIO LOCAL DE CHAT CON CONVERSACIONES REALISTAS DE TENIS
class LocalChatRepository implements ChatRepository {
  final List<Map<String, dynamic>> _mensajesCrudos = _crearMensajesSemilla();

  @override
  Future<List<MensajeEntity>> traerMensajesPartido(
    String partidoId, {
    required List<String> usuariosBloqueadosIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _mensajesCrudos
        .map((m) => MensajeDto.transformarDesdeBDD(m))
        .where(
          (msg) =>
              msg.partidoId == partidoId &&
              !usuariosBloqueadosIds.contains(msg.autorId),
        )
        .toList();
  }

  @override
  Future<void> enviarMensaje(MensajeEntity nuevoMensaje) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mensajesCrudos.add(MensajeDto.aMapaBDD(nuevoMensaje));
  }

  @override
  Future<void> borrarMensaje(String mensajeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mensajesCrudos.removeWhere((m) => m['id'] == mensajeId);
  }

  static List<Map<String, dynamic>> _crearMensajesSemilla() {
    final ahora = DateTime.now();
    return [
      {
        'id': 'msg_01',
        'partidoId': 'match_01',
        'autorId': 'user_martin_02',
        'autorNombre': 'Martín Gómez',
        'autorAvatar': 'https://i.pravatar.cc/300?img=33',
        'texto':
            '¡Buenas! Reservé la cancha 3 techada de polvo de ladrillo a nombre mío.',
        'fechaHora': ahora
            .subtract(const Duration(minutes: 45))
            .toIso8601String(),
      },
      {
        'id': 'msg_02',
        'partidoId': 'match_01',
        'autorId': 'user_lucas_03',
        'autorNombre': 'Lucas Rodríguez',
        'autorAvatar': 'https://i.pravatar.cc/300?img=53',
        'texto': 'Excelente Martín, yo llevo un tubo de pelotas Wilson nuevas.',
        'fechaHora': ahora
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      },
      {
        'id': 'msg_03',
        'partidoId': 'match_01',
        'autorId': 'user_santi_04',
        'autorNombre': 'Santiago Vega',
        'autorAvatar': 'https://i.pravatar.cc/300?img=60',
        'texto': 'Llego 10 minutos antes para calentar el saque.',
        'fechaHora': ahora
            .subtract(const Duration(minutes: 15))
            .toIso8601String(),
      },
      {
        'id': 'msg_04',
        'partidoId': 'match_02',
        'autorId': 'user_nico_05',
        'autorNombre': 'Nicolás P.',
        'autorAvatar': 'https://i.pravatar.cc/300?img=68',
        'texto': 'Jugamos en la cancha rápida del fondo. ¿Tenés pelotas?',
        'fechaHora': ahora
            .subtract(const Duration(minutes: 20))
            .toIso8601String(),
      },
    ];
  }
}
