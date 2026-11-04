import '../../domain/entities/jugador_entity.dart';

// EL TRADUCTOR DE JUGADORES (DTO en Capa Data)
class JugadorDto {
  static JugadorEntity transformarDesdeBDD(Map<String, dynamic> datos) {
    final listaHistorialCruda =
        (datos['historial'] as List<dynamic>?) ?? const [];

    final historialLimpio = listaHistorialCruda.map((item) {
      final mapa = item as Map<String, dynamic>;
      return HistorialPartidoItem(
        id: mapa['id']?.toString() ?? '',
        titulo: mapa['titulo']?.toString() ?? 'Partido de Tenis',
        clubNombre: mapa['clubNombre']?.toString() ?? 'Club',
        modalidad: mapa['modalidad']?.toString() ?? 'Singles',
        superficie: mapa['superficie']?.toString() ?? 'Polvo de ladrillo',
        resultadoMarcador: mapa['resultado']?.toString() ?? '6-4 / 6-4',
        fecha: mapa['fecha'] != null
            ? DateTime.parse(mapa['fecha'].toString())
            : DateTime.now(),
        victoria: (mapa['victoria'] as bool?) ?? true,
      );
    }).toList();

    return JugadorEntity(
      id: datos['id']?.toString() ?? '',
      nombre: datos['nombre']?.toString() ?? 'Jugador',
      avatarUrl:
          datos['avatarUrl']?.toString() ?? 'https://i.pravatar.cc/300?img=11',
      bio: datos['bio']?.toString() ?? 'Jugador de tenis amateur.',
      nivel: datos['nivel']?.toString() ?? 'Intermedio',
      manoHabil: datos['manoHabil']?.toString() ?? 'Diestro',
      tipoReves: datos['tipoReves']?.toString() ?? 'Revés a dos manos',
      superficieFavorita:
          datos['superficieFavorita']?.toString() ?? 'Polvo de ladrillo',
      barrio: datos['barrio']?.toString() ?? 'Palermo, CABA',
      radioBusquedaKm: (datos['radioBusquedaKm'] as num?)?.toInt() ?? 10,
      historialPartidos: historialLimpio,
    );
  }
}
