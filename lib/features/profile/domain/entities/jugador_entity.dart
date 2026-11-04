import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// ENTIDAD DE UN PARTIDO PASADO EN EL HISTORIAL DEL JUGADOR
@immutable
class HistorialPartidoItem extends Equatable {
  final String id;
  final String titulo;
  final String clubNombre;
  final String modalidad;
  final String superficie;
  final String resultadoMarcador; // Ej: '6-4 / 6-3'
  final DateTime fecha;
  final bool victoria;

  const HistorialPartidoItem({
    required this.id,
    required this.titulo,
    required this.clubNombre,
    required this.modalidad,
    required this.superficie,
    required this.resultadoMarcador,
    required this.fecha,
    required this.victoria,
  });

  @override
  List<Object?> get props => [
    id,
    titulo,
    clubNombre,
    modalidad,
    superficie,
    resultadoMarcador,
    fecha,
    victoria,
  ];
}

// ENTIDAD LIMPIA DE UN JUGADOR DE TENIS (Capa Domain de Profile)
@immutable
class JugadorEntity extends Equatable {
  final String id;
  final String nombre;
  final String avatarUrl;
  final String bio;
  final String
  nivel; // 'Principiante', 'Básico', 'Intermedio', 'Avanzado', 'Experto'
  final String manoHabil; // 'Diestro' o 'Zurdo'
  final String tipoReves; // 'Revés a dos manos' o 'Revés a una mano'
  final String superficieFavorita; // 'Polvo de ladrillo' o 'Cemento'
  final String barrio;
  final int radioBusquedaKm;
  final List<HistorialPartidoItem> historialPartidos;

  const JugadorEntity({
    required this.id,
    required this.nombre,
    required this.avatarUrl,
    required this.bio,
    required this.nivel,
    required this.manoHabil,
    required this.tipoReves,
    required this.superficieFavorita,
    required this.barrio,
    required this.radioBusquedaKm,
    required this.historialPartidos,
  });

  int get totalJugados => historialPartidos.length;
  int get totalVictorias => historialPartidos.where((p) => p.victoria).length;

  @override
  List<Object?> get props => [
    id,
    nombre,
    avatarUrl,
    bio,
    nivel,
    manoHabil,
    tipoReves,
    superficieFavorita,
    barrio,
    radioBusquedaKm,
    historialPartidos,
  ];
}
