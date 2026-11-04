import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// ENTIDAD LIMPIA DE UN MENSAJE DE CHAT (Capa Domain de Chat)
@immutable
class MensajeEntity extends Equatable {
  final String id;
  final String partidoId;
  final String autorId;
  final String autorNombre;
  final String autorAvatar;
  final String texto;
  final DateTime fechaHora;

  const MensajeEntity({
    required this.id,
    required this.partidoId,
    required this.autorId,
    required this.autorNombre,
    required this.autorAvatar,
    required this.texto,
    required this.fechaHora,
  });

  @override
  List<Object?> get props => [
    id,
    partidoId,
    autorId,
    autorNombre,
    autorAvatar,
    texto,
    fechaHora,
  ];
}
