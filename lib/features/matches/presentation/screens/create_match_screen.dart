import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/partido_entity.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';
import '../widgets/match_date_time_picker_sheet.dart';
import 'location_picker_map_screen.dart';

/// Pantalla para la creación y edición de partidos organizados.
class CreateMatchScreen extends StatefulWidget {
  final PartidoEntity? partidoAEditar;

  const CreateMatchScreen({super.key, this.partidoAEditar});
  const CreateMatchScreen.editar({super.key, required PartidoEntity partido})
    : partidoAEditar = partido;

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _clubCtrl;
  late final TextEditingController _direccionCtrl;

  late String _barrio;
  late double _latitud;
  late double _longitud;

  late String _modalidad;
  late String _superficie;
  late String _nivel;
  late DateTime _fechaHoraSeleccionada;

  @override
  void initState() {
    super.initState();
    final p = widget.partidoAEditar;
    _tituloCtrl = TextEditingController(text: p?.titulo ?? 'Singles de Tarde');
    _clubCtrl = TextEditingController(
      text: p?.clubNombre ?? 'El Abierto Tenis Club',
    );
    _direccionCtrl = TextEditingController(
      text: p?.direccion ?? 'Galván 3920, Saavedra',
    );

    _barrio = p?.barrio ?? 'Saavedra, CABA';
    _latitud = p?.latitud ?? -34.5518;
    _longitud = p?.longitud ?? -58.4912;

    _modalidad = p?.modalidad ?? 'Singles';
    _superficie = p?.superficie ?? 'Polvo de ladrillo';
    _nivel = p?.nivel ?? 'Intermedio';

    _fechaHoraSeleccionada =
        p?.fechaHora ?? DateTime.now().add(const Duration(hours: 4));
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _clubCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorFechaHora() async {
    final nuevaFecha = await MatchDateTimePickerSheet.show(
      context,
      initialDateTime: _fechaHoraSeleccionada,
    );
    if (nuevaFecha != null) {
      setState(() => _fechaHoraSeleccionada = nuevaFecha);
    }
  }

  void _abrirSelectorUbicacionMapa() async {
    final seleccion = await Navigator.of(context)
        .push<CanchaUbicacionSeleccionada>(
          MaterialPageRoute(
            builder: (_) => LocationPickerMapScreen(
              initialSelection: CanchaUbicacionSeleccionada(
                clubNombre: _clubCtrl.text,
                direccion: _direccionCtrl.text,
                barrio: _barrio,
                latitud: _latitud,
                longitud: _longitud,
                superficieSugerida: _superficie,
              ),
            ),
          ),
        );

    if (seleccion != null) {
      setState(() {
        _clubCtrl.text = seleccion.clubNombre;
        _direccionCtrl.text = seleccion.direccion;
        _barrio = seleccion.barrio;
        _latitud = seleccion.latitud;
        _longitud = seleccion.longitud;
        if ([
          'Polvo de ladrillo',
          'Cemento',
          'Césped',
        ].contains(seleccion.superficieSugerida)) {
          _superficie = seleccion.superficieSugerida;
        }
      });
      if (mounted) {
        AppTheme.showSnackBar(
          context,
          'Cancha seleccionada: ${seleccion.clubNombre}',
        );
      }
    }
  }

  void _publicarPartido() {
    final titulo = _tituloCtrl.text.trim();
    final club = _clubCtrl.text.trim();
    if (titulo.isEmpty || club.isEmpty) {
      AppTheme.showSnackBar(
        context,
        'Por favor ingresá un título y el club de tenis.',
      );
      return;
    }

    if (widget.partidoAEditar != null) {
      final actualizado = widget.partidoAEditar!.copyWith(
        titulo: titulo,
        modalidad: _modalidad,
        superficie: _superficie,
        nivel: _nivel,
        fechaHora: _fechaHoraSeleccionada,
        clubNombre: club,
        direccion: _direccionCtrl.text.trim(),
        barrio: _barrio,
        latitud: _latitud,
        longitud: _longitud,
      );

      context.read<MatchesBloc>().add(
        UpdateMatchAction(partidoActualizado: actualizado),
      );
      Navigator.of(context).pop();
      AppTheme.showSnackBar(context, 'Partido actualizado exitosamente.');
      return;
    }

    final miPerfil = context.read<ProfileBloc>().state.miPerfil;
    final cupos = _modalidad == 'Singles' ? 2 : 4;
    final String imagenUrl = AppTheme.getCourtImageUrl(_superficie);

    final nuevoPartido = PartidoEntity(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      titulo: titulo,
      modalidad: _modalidad,
      superficie: _superficie,
      nivel: _nivel,
      organizadorId: AppConstants.currentUserId,
      organizadorNombre: miPerfil?.nombre ?? 'Tobías',
      imagenUrl: imagenUrl,
      fechaHora: _fechaHoraSeleccionada,
      fechaCreacion: DateTime.now(),
      cuposTotales: cupos,
      jugadoresUnidosIds: const [AppConstants.currentUserId],
      clubNombre: club,
      direccion: _direccionCtrl.text.trim(),
      barrio: _barrio,
      latitud: _latitud,
      longitud: _longitud,
    );

    context.read<MatchesBloc>().add(
      CreateMatchAction(partidoNuevo: nuevoPartido),
    );
    Navigator.of(context).pop();
  }

  void _confirmarEliminarPartido() async {
    final bool? confirmar = await AppTheme.showDarkDialog<bool>(
      context: context,
      title: '¿Borrar Convocatoria?',
      content:
          '¿Estás seguro de que querés cancelar y eliminar este partido? Esta acción no se puede deshacer y se removerá del feed.',
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      confirmText: 'Borrar Partido',
      confirmTextColor: const Color(0xFFEF4444),
      cancelText: 'Cancelar',
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );

    if (confirmar == true && mounted) {
      final partidoId = widget.partidoAEditar!.id;
      context.read<MatchesBloc>().add(DeleteMatchAction(partidoId: partidoId));

      // Volver a la pantalla principal cerrando la pantalla de edición y detalle
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppTheme.showSnackBar(
        context,
        'Partido eliminado correctamente.',
        icon: Icons.delete_outline_rounded,
        iconColor: const Color(0xFFEF4444),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E9A93),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111714),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.accentLimeColor, size: 20),
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF555B58)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalidadSegment(String modalidad, String label, IconData icon) {
    final bool activo = _modalidad == modalidad;
    final bool esEdicion = widget.partidoAEditar != null;

    return Expanded(
      child: GestureDetector(
        onTap: esEdicion ? null : () => setState(() => _modalidad = modalidad),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activo
                ? (esEdicion
                      ? AppTheme.accentLimeColor.withValues(alpha: 0.35)
                      : AppTheme.accentLimeColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: activo && !esEdicion
                ? [
                    BoxShadow(
                      color: AppTheme.accentLimeColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: activo
                    ? (esEdicion ? Colors.white70 : const Color(0xFF0E1311))
                    : const Color(0xFF65726B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: activo
                        ? (esEdicion ? Colors.white70 : const Color(0xFF0E1311))
                        : const Color(0xFF65726B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurfaceChip(String surface) {
    final bool activo = _superficie == surface;
    final Color surfaceColor = AppTheme.getColorForSurface(surface);

    return GestureDetector(
      onTap: () => setState(() => _superficie = surface),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? surfaceColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? surfaceColor : Colors.white.withValues(alpha: 0.1),
            width: activo ? 1.4 : 1.0,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: surfaceColor.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activo) ...[
              Icon(Icons.check_rounded, size: 14, color: surfaceColor),
              const SizedBox(width: 5),
            ],
            Text(
              surface,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: activo ? surfaceColor : const Color(0xFF9EABA3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(String level) {
    final bool activo = _nivel == level;
    final Color levelColor = AppTheme.getColorForLevel(level);

    return GestureDetector(
      onTap: () => setState(() => _nivel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: activo
              ? levelColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? levelColor : Colors.white.withValues(alpha: 0.1),
            width: activo ? 1.4 : 1.0,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: levelColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          level,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
            color: activo ? levelColor : const Color(0xFF9EABA3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormatted = AppDateFormatter.fechaDetalle(
      _fechaHoraSeleccionada,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER ESTILO SETPOINT (Botón volver circular + Título centrado)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppTheme.buildGlassBackButton(context),
                  Text(
                    widget.partidoAEditar != null
                        ? 'Editar Partido'
                        : 'Armar Cancha',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.partidoAEditar != null)
                    GestureDetector(
                      onTap: _confirmarEliminarPartido,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFEF4444,
                          ).withValues(alpha: 0.12),
                          border: Border.all(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),

            // FORMULARIO PRINCIPAL EN LISTVIEW
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
                children: [
                  // Convocatoria
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppTheme.accentLimeColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Datos de la Convocatoria',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _tituloCtrl,
                          label: 'Título del Partido',
                          icon: Icons.title_rounded,
                          hintText: 'Ej: Singles de Tarde',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Ubicación y club
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  color: AppTheme.accentLimeColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Cancha y Ubicación',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _abrirSelectorUbicacionMapa,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLimeColor.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.accentLimeColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 14,
                                      color: AppTheme.accentLimeColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Elegir en Mapa',
                                      style: TextStyle(
                                        color: AppTheme.accentLimeColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _clubCtrl,
                          label: 'Nombre del Club de Tenis',
                          icon: Icons.sports_tennis_rounded,
                          hintText: 'Ej: El Abierto Tenis Club',
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _direccionCtrl,
                          label: 'Dirección o Barrio en CABA',
                          icon: Icons.location_on_outlined,
                          hintText: 'Ej: Galván 3920, Saavedra',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Fecha y horario
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppTheme.accentLimeColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Fecha y Horario',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _abrirSelectorFechaHora,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLimeColor.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.accentLimeColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_calendar_rounded,
                                      size: 14,
                                      color: AppTheme.accentLimeColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Cambiar',
                                      style: TextStyle(
                                        color: AppTheme.accentLimeColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Card interactiva con el horario seleccionado
                        GestureDetector(
                          onTap: _abrirSelectorFechaHora,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111714),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLimeColor.withValues(
                                      alpha: 0.14,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    color: AppTheme.accentLimeColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Horario confirmado',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF8E9A93),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        fechaFormatted,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF8E9A93),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Modalidad, superficie y nivel
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: AppTheme.accentLimeColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Detalles Técnicos',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // MODALIDAD SEGMENTED CAPSULE (FIJA EN MODO EDICIÓN)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Modalidad',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.partidoAEditar != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 11,
                                      color: Color(0xFF8E9A93),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fija en edición',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8E9A93),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: widget.partidoAEditar != null ? 0.65 : 1.0,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: widget.partidoAEditar != null
                                  ? const Color(0xFF060907)
                                  : const Color(0xFF090D0B),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: widget.partidoAEditar != null
                                      ? 0.04
                                      : 0.08,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildModalidadSegment(
                                  'Singles',
                                  'Singles (2J)',
                                  Icons.person_rounded,
                                ),
                                _buildModalidadSegment(
                                  'Dobles',
                                  'Dobles (4J)',
                                  Icons.group_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // SUPERFICIE DE LA CANCHA
                        const Text(
                          'Superficie de la Cancha',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Polvo de ladrillo',
                            'Cemento',
                            'Césped',
                          ].map((sup) => _buildSurfaceChip(sup)).toList(),
                        ),

                        const SizedBox(height: 18),

                        // CATEGORÍA DE JUEGO (NIVELES CON COLOR DEDICADO)
                        const Text(
                          'Categoría de Juego Buscada',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Principiante',
                            'Básico',
                            'Intermedio',
                            'Avanzado',
                            'Experto',
                          ].map((niv) => _buildLevelChip(niv)).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentLimeColor,
                        foregroundColor: const Color(0xFF0E1311),
                        elevation: 6,
                        shadowColor: AppTheme.accentLimeColor.withValues(
                          alpha: 0.45,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: _publicarPartido,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.partidoAEditar != null
                                ? Icons.save_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 20,
                            color: const Color(0xFF0E1311),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.partidoAEditar != null
                                ? 'Guardar Cambios'
                                : 'Publicar Cancha en el Feed',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: Color(0xFF0E1311),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.partidoAEditar != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: BorderSide(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.55),
                            width: 1.3,
                          ),
                          backgroundColor: const Color(
                            0xFFEF4444,
                          ).withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _confirmarEliminarPartido,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Borrar Convocatoria / Partido',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
