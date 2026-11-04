import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../profile/presentation/bloc/profile_actions.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/perfil_jugador_screen.dart';
import '../../domain/entities/mensaje_entity.dart';
import '../bloc/chat_actions.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';

// PANTALLA DE CHAT DEL PARTIDO CON DISEÑO DARK GLASS & MODERACIÓN UGC
class ChatPartidoScreen extends StatefulWidget {
  final String partidoId;
  final String tituloPartido;

  const ChatPartidoScreen({
    super.key,
    required this.partidoId,
    required this.tituloPartido,
  });

  @override
  State<ChatPartidoScreen> createState() => _ChatPartidoScreenState();
}

class _ChatPartidoScreenState extends State<ChatPartidoScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatAction(partidoId: widget.partidoId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final miPerfil = context.read<ProfileBloc>().state.miPerfil;
    context.read<ChatBloc>().add(
      SendMessageAction(
        partidoId: widget.partidoId,
        autorId: AppConstants.currentUserId,
        autorNombre: miPerfil?.nombre ?? 'Tobías',
        autorAvatar: miPerfil?.avatarUrl ?? 'https://i.pravatar.cc/300?img=12',
        texto: texto,
      ),
    );
    _controller.clear();
  }

  Widget _buildAvatar(String avatarUrl, String autorNombre) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF161E1A),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF161E1A),
            alignment: Alignment.center,
            child: Text(
              autorNombre.isNotEmpty ? autorNombre[0].toUpperCase() : 'J',
              style: const TextStyle(
                color: AppTheme.accentLimeColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MENÚ DE OPCIONES AL MANTENER PRESIONADO UN MENSAJE (DARK GLASSMORPHISM)
  void _mostrarOpcionesMensaje(MensajeEntity msg, bool esMio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161E1A),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildAvatar(msg.autorAvatar, msg.autorNombre),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.autorNombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Opciones del mensaje',
                              style: TextStyle(
                                color: Color(0xFF8E9A93),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                  ),
                  title: const Text(
                    'Borrar mensaje',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _confirmarBorrarMensaje(msg);
                  },
                ),
                if (!esMio)
                  ListTile(
                    leading: const Icon(
                      Icons.block_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    title: const Text(
                      'Bloquear jugador',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _confirmarBloquearJugador(msg);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF8E9A93),
                  ),
                  title: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E9A93),
                    ),
                  ),
                  onTap: () => Navigator.of(bottomSheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DIÁLOGO DE CONFIRMACIÓN PARA BORRAR MENSAJE
  void _confirmarBorrarMensaje(MensajeEntity msg) {
    AppTheme.showDarkDialog(
      context: context,
      title: '¿Borrar mensaje?',
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFEF4444),
      content: 'El mensaje será eliminado de la conversación de esta cancha.',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar y Borrar',
      confirmTextColor: const Color(0xFFEF4444),
      onConfirm: () {
        context.read<ChatBloc>().add(
          DeleteMessageAction(partidoId: widget.partidoId, mensajeId: msg.id),
        );
      },
    );
  }

  // DIÁLOGO DE CONFIRMACIÓN PARA BLOQUEAR JUGADOR
  void _confirmarBloquearJugador(MensajeEntity msg) {
    AppTheme.showDarkDialog(
      context: context,
      title: '¿Bloquear a ${msg.autorNombre}?',
      icon: Icons.lock_person_outlined,
      iconColor: const Color(0xFFEF4444),
      content:
          'Ya no verás los mensajes ni las publicaciones de ${msg.autorNombre} en SetPoint.',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar y Bloquear',
      confirmTextColor: const Color(0xFFEF4444),
      onConfirm: () {
        context.read<ChatBloc>().add(
          BlockUserInChatAction(
            partidoId: widget.partidoId,
            usuarioABloquearId: msg.autorId,
          ),
        );
        context.read<ProfileBloc>().add(
          BlockUserAction(usuarioId: msg.autorId),
        );
        AppTheme.showSnackBar(
          context,
          'Bloqueaste a ${msg.autorNombre}. Podés gestionarlo en tu perfil.',
          icon: Icons.lock_person_outlined,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final directorioJugadores = context
        .watch<ProfileBloc>()
        .state
        .directorioJugadores;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocListener<ChatBloc, ChatState>(
          listenWhen: (prev, curr) =>
              prev.avisoModeracion != curr.avisoModeracion,
          listener: (context, state) {
            if (state.avisoModeracion != null) {
              AppTheme.showSnackBar(context, state.avisoModeracion!);
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: Row(
                  children: [
                    AppTheme.buildGlassBackButton(context),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tituloPartido,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 3.5,
                                backgroundColor: Color(0xFF10B981),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Chat de la Cancha en vivo',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF8E9A93),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentLimeColor,
                        ),
                      );
                    }
                    if (state.mensajes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLimeColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sports_tennis_rounded,
                                  size: 36,
                                  color: AppTheme.accentLimeColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Comenzá la charla',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Coordiná pelotas, horario y detalles del partido con los jugadores.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8E9A93),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.mensajes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final msg = state.mensajes[index];
                        final esMio = msg.autorId == AppConstants.currentUserId;

                        return Row(
                          mainAxisAlignment: esMio
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!esMio) ...[
                              GestureDetector(
                                onTap: () {
                                  final jugador =
                                      directorioJugadores[msg.autorId];
                                  if (jugador != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PerfilJugadorScreen(
                                          jugador: jugador,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: _buildAvatar(
                                  msg.autorAvatar,
                                  msg.autorNombre,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: GestureDetector(
                                onLongPress: () =>
                                    _mostrarOpcionesMensaje(msg, esMio),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: esMio
                                        ? AppTheme.accentLimeColor
                                        : const Color(0xFF161E1A),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        esMio ? 16 : 4,
                                      ),
                                      bottomRight: Radius.circular(
                                        esMio ? 4 : 16,
                                      ),
                                    ),
                                    border: Border.all(
                                      color: esMio
                                          ? AppTheme.accentLimeColor
                                          : Colors.white.withValues(
                                              alpha: 0.14,
                                            ),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8,
                                        color: esMio
                                            ? AppTheme.accentLimeColor
                                                  .withValues(alpha: 0.25)
                                            : Colors.black.withValues(
                                                alpha: 0.35,
                                              ),
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: esMio
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (!esMio) ...[
                                        Text(
                                          msg.autorNombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppTheme.accentLimeColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                      Text(
                                        msg.texto,
                                        style: TextStyle(
                                          color: esMio
                                              ? const Color(0xFF0E1311)
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: esMio
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppDateFormatter.hora(msg.fechaHora),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: esMio
                                              ? const Color(
                                                  0xFF0E1311,
                                                ).withValues(alpha: 0.65)
                                              : const Color(0xFF8E9A93),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A17),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _enviar(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribí un mensaje al grupo...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8E9A93),
                              fontSize: 13.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF161E1A),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.14),
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.14),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: AppTheme.accentLimeColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accentLimeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentLimeColor.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _enviar,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Color(0xFF0E1311),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
