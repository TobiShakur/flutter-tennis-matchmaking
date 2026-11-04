import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tenis_app/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tenis_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:tenis_app/features/chat/presentation/bloc/chat_actions.dart';
import 'package:tenis_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:tenis_app/features/chat/presentation/bloc/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  final fechaBase = DateTime(2026, 11, 3, 18, 0);

  group('ChatBloc UGC Moderation Tests', () {
    late MockChatRepository mockChatRepo;
    late ChatBloc chatBloc;

    final msgPrueba = MensajeEntity(
      id: 'msg_test_01',
      partidoId: 'match_01',
      autorId: 'user_spammer',
      autorNombre: 'Spammer',
      autorAvatar: 'https://example.com/spammer.jpg',
      texto: 'Mensaje no deseado',
      fechaHora: fechaBase,
    );

    setUp(() {
      mockChatRepo = MockChatRepository();
      chatBloc = ChatBloc(repo: mockChatRepo);
    });

    tearDown(() {
      chatBloc.close();
    });

    blocTest<ChatBloc, ChatState>(
      'DeleteMessageAction borra el mensaje del repo y actualiza el estado',
      build: () {
        when(
          () => mockChatRepo.borrarMensaje(msgPrueba.id),
        ).thenAnswer((_) async {});
        when(
          () => mockChatRepo.traerMensajesPartido(
            'match_01',
            usuariosBloqueadosIds: any(named: 'usuariosBloqueadosIds'),
          ),
        ).thenAnswer((_) async => []);
        return chatBloc;
      },
      act: (b) => b.add(
        DeleteMessageAction(partidoId: 'match_01', mensajeId: msgPrueba.id),
      ),
      expect: () => [
        const ChatState(
          mensajes: [],
          avisoModeracion: 'Mensaje eliminado del chat.',
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'BlockUserInChatAction bloquea al jugador y filtra sus mensajes',
      build: () {
        when(
          () => mockChatRepo.traerMensajesPartido(
            'match_01',
            usuariosBloqueadosIds: ['user_spammer'],
          ),
        ).thenAnswer((_) async => []);
        return chatBloc;
      },
      act: (b) => b.add(
        const BlockUserInChatAction(
          partidoId: 'match_01',
          usuarioABloquearId: 'user_spammer',
        ),
      ),
      expect: () => [
        const ChatState(
          usuariosBloqueadosIds: ['user_spammer'],
          mensajes: [],
          avisoModeracion:
              'Jugador bloqueado. Sus mensajes fueron ocultados del chat.',
        ),
      ],
    );
  });
}
