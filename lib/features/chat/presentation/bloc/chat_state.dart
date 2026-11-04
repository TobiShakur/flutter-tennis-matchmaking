import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/mensaje_entity.dart';

// ESTADO DEL CHAT BLOC
@immutable
class ChatState extends Equatable {
  final List<MensajeEntity> mensajes;
  final List<String> usuariosBloqueadosIds;
  final bool isLoading;
  final String? avisoModeracion;

  const ChatState({
    this.mensajes = const [],
    this.usuariosBloqueadosIds = const [],
    this.isLoading = false,
    this.avisoModeracion,
  });

  ChatState copyWith({
    List<MensajeEntity>? mensajes,
    List<String>? usuariosBloqueadosIds,
    bool? isLoading,
    String? Function()? avisoModeracion,
  }) {
    return ChatState(
      mensajes: mensajes ?? this.mensajes,
      usuariosBloqueadosIds:
          usuariosBloqueadosIds ?? this.usuariosBloqueadosIds,
      isLoading: isLoading ?? this.isLoading,
      avisoModeracion: avisoModeracion != null ? avisoModeracion() : null,
    );
  }

  @override
  List<Object?> get props => [
    mensajes,
    usuariosBloqueadosIds,
    isLoading,
    avisoModeracion,
  ];
}
