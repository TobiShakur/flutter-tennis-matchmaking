import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mensaje_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_actions.dart';
import 'chat_state.dart';

// Manages real-time match chat state and UGC safety rules.
// Handles message loading, sending, own message deletion, and user blocking/unblocking.
class ChatBloc extends Bloc<ChatAction, ChatState> {
  final ChatRepository repo;

  ChatBloc({required this.repo}) : super(const ChatState()) {
    on<LoadChatAction>(_onLoadChat);
    on<SendMessageAction>(_onSendMessage);
    on<BlockUserInChatAction>(_onBlockUser);
    on<UnblockUserInChatAction>(_onUnblockUser);
    on<DeleteMessageAction>(_onDeleteMessage);
  }

  Future<void> _onLoadChat(
    LoadChatAction event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, avisoModeracion: () => null));

    final lista = await repo.traerMensajesPartido(
      event.partidoId,
      usuariosBloqueadosIds: state.usuariosBloqueadosIds,
    );

    emit(state.copyWith(mensajes: lista, isLoading: false));
  }

  Future<void> _onSendMessage(
    SendMessageAction event,
    Emitter<ChatState> emit,
  ) async {
    final textoLimpio = event.texto.trim();
    if (textoLimpio.isEmpty) return;

    final nuevo = MensajeEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      partidoId: event.partidoId,
      autorId: event.autorId,
      autorNombre: event.autorNombre,
      autorAvatar: event.autorAvatar,
      texto: textoLimpio,
      fechaHora: DateTime.now(),
    );

    await repo.enviarMensaje(nuevo);
    final listaActualizada = await repo.traerMensajesPartido(
      event.partidoId,
      usuariosBloqueadosIds: state.usuariosBloqueadosIds,
    );

    emit(
      state.copyWith(mensajes: listaActualizada, avisoModeracion: () => null),
    );
  }

  Future<void> _onBlockUser(
    BlockUserInChatAction event,
    Emitter<ChatState> emit,
  ) async {
    final nuevosBloqueados = [
      ...state.usuariosBloqueadosIds,
      event.usuarioABloquearId,
    ];

    final listaFiltrada = await repo.traerMensajesPartido(
      event.partidoId,
      usuariosBloqueadosIds: nuevosBloqueados,
    );

    emit(
      state.copyWith(
        usuariosBloqueadosIds: nuevosBloqueados,
        mensajes: listaFiltrada,
        avisoModeracion: () =>
            'Jugador bloqueado. Sus mensajes fueron ocultados del chat.',
      ),
    );
  }

  Future<void> _onUnblockUser(
    UnblockUserInChatAction event,
    Emitter<ChatState> emit,
  ) async {
    final nuevosBloqueados = List<String>.from(state.usuariosBloqueadosIds)
      ..remove(event.usuarioADesbloquearId);

    final listaFiltrada = await repo.traerMensajesPartido(
      event.partidoId,
      usuariosBloqueadosIds: nuevosBloqueados,
    );

    emit(
      state.copyWith(
        usuariosBloqueadosIds: nuevosBloqueados,
        mensajes: listaFiltrada,
        avisoModeracion: () => 'Jugador desbloqueado.',
      ),
    );
  }

  Future<void> _onDeleteMessage(
    DeleteMessageAction event,
    Emitter<ChatState> emit,
  ) async {
    await repo.borrarMensaje(event.mensajeId);
    final listaActualizada = await repo.traerMensajesPartido(
      event.partidoId,
      usuariosBloqueadosIds: state.usuariosBloqueadosIds,
    );

    emit(
      state.copyWith(
        mensajes: listaActualizada,
        avisoModeracion: () => 'Mensaje eliminado del chat.',
      ),
    );
  }
}
