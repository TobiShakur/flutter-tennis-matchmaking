import '../../domain/entities/partido_entity.dart';

/// Data Transfer Object para serialización y mapeo de [PartidoEntity].
class PartidoDto {
  static PartidoEntity transformarDesdeBDD(Map<String, dynamic> datos) {
    final String estadoTexto = datos['status']?.toString() ?? 'missingPlayer';
    EstadoPartido estadoLimpio = EstadoPartido.faltanJugadores;
    if (estadoTexto == 'completed') {
      estadoLimpio = EstadoPartido.canchaCompleta;
    } else if (estadoTexto == 'cancelled') {
      estadoLimpio = EstadoPartido.cancelado;
    } else if (estadoTexto == 'finished' || estadoTexto == 'finalizado') {
      estadoLimpio = EstadoPartido.finalizado;
    }

    final String modalidad = datos['modalidad']?.toString() ?? 'Dobles';
    final int cuposPorDefecto = modalidad == 'Singles' ? 2 : 4;

    return PartidoEntity(
      id: datos['id']?.toString() ?? '',
      titulo: datos['title']?.toString() ?? 'Partido de Tenis',
      modalidad: modalidad,
      superficie: datos['superficie']?.toString() ?? 'Polvo de ladrillo',
      nivel: datos['level']?.toString() ?? 'Intermedio',
      organizadorId: datos['organizerId']?.toString() ?? '',
      organizadorNombre: datos['organizerName']?.toString() ?? 'Jugador',
      imagenUrl:
          datos['imageUrl']?.toString() ??
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
      fechaHora: datos['dateTime'] != null
          ? DateTime.parse(datos['dateTime'].toString())
          : DateTime.now().add(const Duration(hours: 4)),
      fechaCreacion: datos['createdAt'] != null
          ? DateTime.parse(datos['createdAt'].toString())
          : DateTime.now().subtract(const Duration(hours: 2)),
      cuposTotales: (datos['capacity'] as num?)?.toInt() ?? cuposPorDefecto,
      jugadoresUnidosIds: List<String>.from(datos['joinedPlayerIds'] ?? []),
      clubNombre: datos['clubName']?.toString() ?? 'Club de Tenis',
      direccion: datos['direccion']?.toString() ?? 'Palermo, CABA',
      barrio: datos['barrio']?.toString() ?? 'Palermo',
      latitud: (datos['lat'] as num?)?.toDouble() ?? -34.6037,
      longitud: (datos['lng'] as num?)?.toDouble() ?? -58.3816,
      estado: estadoLimpio,
    );
  }

  static Map<String, dynamic> aMapaBDD(PartidoEntity partido) {
    String estadoString = 'missingPlayer';
    if (partido.estado == EstadoPartido.canchaCompleta) {
      estadoString = 'completed';
    } else if (partido.estado == EstadoPartido.cancelado) {
      estadoString = 'cancelled';
    } else if (partido.estado == EstadoPartido.finalizado) {
      estadoString = 'finalizado';
    }

    return {
      'id': partido.id,
      'title': partido.titulo,
      'modalidad': partido.modalidad,
      'superficie': partido.superficie,
      'level': partido.nivel,
      'organizerId': partido.organizadorId,
      'organizerName': partido.organizadorNombre,
      'imageUrl': partido.imagenUrl,
      'dateTime': partido.fechaHora.toIso8601String(),
      'createdAt': partido.fechaCreacion.toIso8601String(),
      'capacity': partido.cuposTotales,
      'joinedPlayerIds': partido.jugadoresUnidosIds,
      'clubName': partido.clubNombre,
      'direccion': partido.direccion,
      'barrio': partido.barrio,
      'lat': partido.latitud,
      'lng': partido.longitud,
      'status': estadoString,
    };
  }
}
