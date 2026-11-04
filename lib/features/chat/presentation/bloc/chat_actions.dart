import 'package:flutter/foundation.dart';

// EVENTOS DEL CHAT BLOC
@immutable
abstract class ChatAction {
  const ChatAction();
}

@immutable
class LoadChatAction extends ChatAction {
  final String partidoId;

  const LoadChatAction({required this.partidoId});
}

@immutable
class SendMessageAction extends ChatAction {
  final String partidoId;
  final String autorId;
  final String autorNombre;
  final String autorAvatar;
  final String texto;

  const SendMessageAction({
    required this.partidoId,
    required this.autorId,
    required this.autorNombre,
    required this.autorAvatar,
    required this.texto,
  });
}

@immutable
class BlockUserInChatAction extends ChatAction {
  final String partidoId;
  final String usuarioABloquearId;

  const BlockUserInChatAction({
    required this.partidoId,
    required this.usuarioABloquearId,
  });
}

@immutable
class UnblockUserInChatAction extends ChatAction {
  final String partidoId;
  final String usuarioADesbloquearId;

  const UnblockUserInChatAction({
    required this.partidoId,
    required this.usuarioADesbloquearId,
  });
}

@immutable
class DeleteMessageAction extends ChatAction {
  final String partidoId;
  final String mensajeId;

  const DeleteMessageAction({required this.partidoId, required this.mensajeId});
}
