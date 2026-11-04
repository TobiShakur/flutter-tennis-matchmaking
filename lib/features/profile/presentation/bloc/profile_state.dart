import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/jugador_entity.dart';

// ESTADO UNIFICADO DE PERFILES
@immutable
class ProfileState extends Equatable {
  final JugadorEntity? miPerfil;
  final Map<String, JugadorEntity> directorioJugadores;
  final List<String> usuariosBloqueadosIds;
  final bool isLoading;
  final String? mensajeExito;

  const ProfileState({
    this.miPerfil,
    this.directorioJugadores = const {},
    this.usuariosBloqueadosIds = const [],
    this.isLoading = false,
    this.mensajeExito,
  });

  ProfileState copyWith({
    JugadorEntity? miPerfil,
    Map<String, JugadorEntity>? directorioJugadores,
    List<String>? usuariosBloqueadosIds,
    bool? isLoading,
    String? Function()? mensajeExito,
  }) {
    return ProfileState(
      miPerfil: miPerfil ?? this.miPerfil,
      directorioJugadores: directorioJugadores ?? this.directorioJugadores,
      usuariosBloqueadosIds:
          usuariosBloqueadosIds ?? this.usuariosBloqueadosIds,
      isLoading: isLoading ?? this.isLoading,
      mensajeExito: mensajeExito != null ? mensajeExito() : null,
    );
  }

  @override
  List<Object?> get props => [
    miPerfil,
    directorioJugadores,
    usuariosBloqueadosIds,
    isLoading,
    mensajeExito,
  ];
}
