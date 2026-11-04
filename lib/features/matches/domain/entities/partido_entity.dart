import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// CAPA DE DOMINIO: Entidad limpia de un Partido de Tenis
enum EstadoPartido { faltanJugadores, canchaCompleta, cancelado, finalizado }

@immutable
class PartidoEntity extends Equatable {
  final String id;
  final String titulo;
  final String modalidad; // 'Singles' (2 jugadores) o 'Dobles' (4 jugadores)
  final String superficie; // 'Polvo de ladrillo', 'Cemento', 'Césped'
  final String
  nivel; // 'Principiante', 'Básico', 'Intermedio', 'Avanzado', 'Experto'
  final String organizadorId;
  final String organizadorNombre;
  final String imagenUrl;
  final DateTime fechaHora;
  final DateTime fechaCreacion;
  final int cuposTotales;
  final List<String> jugadoresUnidosIds;
  final String clubNombre;
  final String direccion;
  final String barrio;
  final double latitud;
  final double longitud;
  final EstadoPartido estado;

  const PartidoEntity({
    required this.id,
    required this.titulo,
    required this.modalidad,
    required this.superficie,
    required this.nivel,
    required this.organizadorId,
    required this.organizadorNombre,
    required this.imagenUrl,
    required this.fechaHora,
    required this.fechaCreacion,
    required this.cuposTotales,
    required this.jugadoresUnidosIds,
    required this.clubNombre,
    required this.direccion,
    this.barrio = 'CABA',
    required this.latitud,
    required this.longitud,
    this.estado = EstadoPartido.faltanJugadores,
  });

  int get cuposOcupados => jugadoresUnidosIds.length;
  int get cuposLibres => cuposTotales - cuposOcupados;
  bool get estaLleno => cuposLibres <= 0;

  double distanciaDesdeKm(double userLat, double userLng) {
    const double radioTierraKm = 6371.0;
    final double dLat = (latitud - userLat) * (pi / 180.0);
    final double dLon = (longitud - userLng) * (pi / 180.0);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(userLat * (pi / 180.0)) *
            cos(latitud * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierraKm * c;
  }

  PartidoEntity copyWith({
    String? id,
    String? titulo,
    String? modalidad,
    String? superficie,
    String? nivel,
    String? organizadorId,
    String? organizadorNombre,
    String? imagenUrl,
    DateTime? fechaHora,
    DateTime? fechaCreacion,
    int? cuposTotales,
    List<String>? jugadoresUnidosIds,
    String? clubNombre,
    String? direccion,
    String? barrio,
    double? latitud,
    double? longitud,
    EstadoPartido? estado,
  }) {
    return PartidoEntity(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      modalidad: modalidad ?? this.modalidad,
      superficie: superficie ?? this.superficie,
      nivel: nivel ?? this.nivel,
      organizadorId: organizadorId ?? this.organizadorId,
      organizadorNombre: organizadorNombre ?? this.organizadorNombre,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaHora: fechaHora ?? this.fechaHora,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      cuposTotales: cuposTotales ?? this.cuposTotales,
      jugadoresUnidosIds: jugadoresUnidosIds ?? this.jugadoresUnidosIds,
      clubNombre: clubNombre ?? this.clubNombre,
      direccion: direccion ?? this.direccion,
      barrio: barrio ?? this.barrio,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      estado: estado ?? this.estado,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    modalidad,
    superficie,
    nivel,
    organizadorId,
    organizadorNombre,
    imagenUrl,
    fechaHora,
    fechaCreacion,
    cuposTotales,
    jugadoresUnidosIds,
    clubNombre,
    direccion,
    barrio,
    latitud,
    longitud,
    estado,
  ];
}
