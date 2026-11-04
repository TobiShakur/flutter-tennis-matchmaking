import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile_actions.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

// Categorías y niveles oficiales de tenis SetPoint
class _TennisLevel {
  final String name;
  final String description;
  final Color color;

  const _TennisLevel({
    required this.name,
    required this.description,
    required this.color,
  });
}

final List<_TennisLevel> _tennisLevels = [
  _TennisLevel(
    name: 'Principiante',
    description: 'Recién empiezo',
    color: AppTheme.getColorForLevel('Principiante'),
  ),
  _TennisLevel(
    name: 'Básico',
    description: 'Conozco lo básico',
    color: AppTheme.getColorForLevel('Básico'),
  ),
  _TennisLevel(
    name: 'Intermedio',
    description: 'Juego regularmente',
    color: AppTheme.getColorForLevel('Intermedio'),
  ),
  _TennisLevel(
    name: 'Avanzado',
    description: 'Llevo tiempo jugando',
    color: AppTheme.getColorForLevel('Avanzado'),
  ),
  _TennisLevel(
    name: 'Experto',
    description: 'Nivel competitivo',
    color: AppTheme.getColorForLevel('Experto'),
  ),
];

Color _getColorForLevel(String levelName) =>
    AppTheme.getColorForLevel(levelName);

class _SurfaceOption {
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const _SurfaceOption({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });
}

const List<_SurfaceOption> _tennisSurfaces = [
  _SurfaceOption(
    name: 'Polvo de ladrillo',
    description: 'Canchas tradicionales de arcilla (juego lento)',
    color: AppTheme.accentClayColor,
    icon: Icons.layers_rounded,
  ),
  _SurfaceOption(
    name: 'Cemento',
    description: 'Canchas rápidas de superficie dura',
    color: AppTheme.accentHardCourtColor,
    icon: Icons.layers_rounded,
  ),
  _SurfaceOption(
    name: 'Césped',
    description: 'Canchas rápidas de césped natural o sintético',
    color: Color(0xFF10B981),
    icon: Icons.grass_rounded,
  ),
];

class _HandOption {
  final String name;
  final String description;

  const _HandOption({required this.name, required this.description});
}

const List<_HandOption> _handOptions = [
  _HandOption(name: 'Diestra', description: 'Golpe dominante con mano derecha'),
  _HandOption(name: 'Zurda', description: 'Golpe dominante con mano izquierda'),
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();

  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  String? _selectedLocation;
  bool _initialized = false;

  final List<String> _barriosCABA = [
    'Agronomía',
    'Almagro',
    'Balvanera',
    'Barracas',
    'Belgrano',
    'Boedo',
    'Caballito',
    'Chacarita',
    'Coghlan',
    'Colegiales',
    'Constitución',
    'Flores',
    'Floresta',
    'La Boca',
    'La Paternal',
    'Liniers',
    'Mataderos',
    'Monte Castro',
    'Montserrat',
    'Nueva Pompeya',
    'Núñez',
    'Palermo',
    'Parque Avellaneda',
    'Parque Chacabuco',
    'Parque Chas',
    'Parque Patricios',
    'Puerto Madero',
    'Recoleta',
    'Retiro',
    'Saavedra',
    'San Cristóbal',
    'San Nicolás',
    'San Telmo',
    'Vélez Sársfield',
    'Versalles',
    'Villa Crespo',
    'Villa del Parque',
    'Villa Devoto',
    'Villa General Mitre',
    'Villa Lugano',
    'Villa Luro',
    'Villa Ortúzar',
    'Villa Pueyrredón',
    'Villa Real',
    'Villa Riachuelo',
    'Villa Santa Rita',
    'Villa Soldati',
    'Villa Urquiza',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  void _initFieldsIfNeeded(String fullName, String barrio) {
    if (!_initialized) {
      final parts = fullName.trim().split(' ');
      if (parts.isNotEmpty) {
        _nameController.text = parts.first;
        _lastNameController.text = parts.length > 1
            ? parts.sublist(1).join(' ')
            : '';
      }
      final cleanBarrio = barrio.split(',').first.trim();
      if (_barriosCABA.contains(cleanBarrio)) {
        _selectedLocation = cleanBarrio;
      } else {
        _selectedLocation = 'Palermo';
      }
      _initialized = true;
    }
  }

  void _guardarNombreCompleto(BuildContext context, String currentUserId) {
    final nombre = _nameController.text.trim();
    final apellido = _lastNameController.text.trim();
    final nombreCompleto = '$nombre $apellido'.trim();
    if (nombreCompleto.isNotEmpty) {
      context.read<ProfileBloc>().add(
        UpdateMyProfileAction(
          usuarioId: currentUserId,
          nuevoNombre: nombreCompleto,
        ),
      );
      AppTheme.showSnackBar(context, 'Nombre actualizado con éxito');
    }
  }

  void _showLevelPickerSheet(String currentUserId, String currentLevel) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _LevelPickerSheet(levels: _tennisLevels, initialLevel: currentLevel),
    );

    if (!mounted) return;

    if (selected != null && selected != currentLevel) {
      context.read<ProfileBloc>().add(
        UpdateMyProfileAction(usuarioId: currentUserId, nuevoNivel: selected),
      );
      AppTheme.showSnackBar(context, 'Nivel de tenis actualizado a $selected');
    }
  }

  void _showSurfacePickerSheet(
    String currentUserId,
    String currentSurface,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurfacePickerSheet(
        surfaces: _tennisSurfaces,
        initialSurface: currentSurface,
      ),
    );

    if (!mounted) return;

    if (selected != null && selected != currentSurface) {
      context.read<ProfileBloc>().add(
        UpdateMyProfileAction(
          usuarioId: currentUserId,
          nuevaSuperficie: selected,
        ),
      );
      AppTheme.showSnackBar(
        context,
        'Preferencia de cancha actualizada a $selected',
      );
    }
  }

  void _showHandPickerSheet(String currentUserId, String currentHand) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _HandPickerSheet(options: _handOptions, initialHand: currentHand),
    );

    if (!mounted) return;

    if (selected != null && selected != currentHand) {
      context.read<ProfileBloc>().add(
        UpdateMyProfileAction(
          usuarioId: currentUserId,
          nuevaManoHabil: selected,
        ),
      );
      AppTheme.showSnackBar(context, 'Mano hábil actualizada a $selected');
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    AppTheme.showDarkDialog(
      context: context,
      title: 'Eliminar cuenta',
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      content:
          '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y perderás tu historial de partidos.',
      cancelText: 'Cancelar',
      confirmText: 'Eliminar',
      confirmTextColor: const Color(0xFFEF4444),
      onConfirm: () {
        Navigator.of(context).pop();
        AppTheme.showSnackBar(context, 'Solicitud de baja enviada al soporte.');
      },
    );
  }

  void _showBlockedUsersSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF161E1A),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final bloqueados = state.usuariosBloqueadosIds;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle superior
                    Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header del Sheet
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_person_outlined,
                              color: AppTheme.accentLimeColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Usuarios Bloqueados',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (bloqueados.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLimeColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.accentLimeColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${bloqueados.length}',
                                  style: const TextStyle(
                                    color: AppTheme.accentLimeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF8E9A93),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    if (bloqueados.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.accentLimeColor.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppTheme.accentLimeColor,
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tenés usuarios bloqueados',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Los jugadores que bloquees desde el chat de los partidos aparecerán acá para que puedas desbloquearlos cuando quieras.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF8E9A93),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 340),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: bloqueados.length,
                          separatorBuilder: (_, _) => Divider(
                            color: Colors.white.withValues(alpha: 0.08),
                            height: 16,
                          ),
                          itemBuilder: (context, index) {
                            final userId = bloqueados[index];
                            final jugador = state.directorioJugadores[userId];
                            final nombre =
                                jugador?.nombre ?? 'Jugador Bloqueado';
                            final nivel = jugador?.nivel ?? 'Intermedio';
                            final nivelColor = AppTheme.getColorForLevel(nivel);

                            return Row(
                              children: [
                                // Avatar con borde satinado
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1.2,
                                    ),
                                    color: const Color(0xFF202A24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      nombre.isNotEmpty
                                          ? nombre[0].toUpperCase()
                                          : 'J',
                                      style: const TextStyle(
                                        color: AppTheme.accentLimeColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: nivelColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            nivel,
                                            style: TextStyle(
                                              color: nivelColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    context.read<ProfileBloc>().add(
                                      UnblockUserAction(usuarioId: userId),
                                    );
                                    AppTheme.showSnackBar(
                                      context,
                                      'Desbloqueaste a $nombre.',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppTheme.accentLimeColor
                                        .withValues(alpha: 0.12),
                                    side: const BorderSide(
                                      color: AppTheme.accentLimeColor,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: const Text(
                                    'Desbloquear',
                                    style: TextStyle(
                                      color: AppTheme.accentLimeColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final jugador = state.miPerfil;
            if (jugador == null) {
              return const Center(child: CircularProgressIndicator());
            }

            _initFieldsIfNeeded(jugador.nombre, jugador.barrio);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.buildGlassBackButton(context),
                  const SizedBox(height: 24),

                  // Avatar con badge de cámara
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getColorForLevel(jugador.nivel),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              jugador.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: _getColorForLevel(
                                  jugador.nivel,
                                ).withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 45,
                                  color: _getColorForLevel(jugador.nivel),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161E1A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              AppTheme.showSnackBar(
                                context,
                                'Función de foto disponible próximamente.',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 20),

                  // Tu nombre
                  _buildSeparatelyEditableField(
                    label: 'Tu nombre',
                    controller: _nameController,
                    isEditing: _isEditingFirstName,
                    focusNode: _firstNameFocusNode,
                    onToggleEdit: () {
                      setState(() {
                        _isEditingFirstName = !_isEditingFirstName;
                      });
                      if (!_isEditingFirstName) {
                        _guardarNombreCompleto(context, jugador.id);
                      } else {
                        _firstNameFocusNode.requestFocus();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tu apellido
                  _buildSeparatelyEditableField(
                    label: 'Tu apellido',
                    controller: _lastNameController,
                    isEditing: _isEditingLastName,
                    focusNode: _lastNameFocusNode,
                    onToggleEdit: () {
                      setState(() {
                        _isEditingLastName = !_isEditingLastName;
                      });
                      if (!_isEditingLastName) {
                        _guardarNombreCompleto(context, jugador.id);
                      } else {
                        _lastNameFocusNode.requestFocus();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () =>
                        _showLevelPickerSheet(jugador.id, jugador.nivel),
                    child: _buildReadOnlyField(
                      label: 'Editar Nivel',
                      value: jugador.nivel,
                      valueColor: _getColorForLevel(jugador.nivel),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Preferencia de Cancha (Polvo de ladrillo / Cemento / Césped)
                  GestureDetector(
                    onTap: () => _showSurfacePickerSheet(
                      jugador.id,
                      jugador.superficieFavorita,
                    ),
                    child: _buildReadOnlyField(
                      label: 'Preferencia de Cancha',
                      value: jugador.superficieFavorita,
                      valueColor: AppTheme.getColorForSurface(
                        jugador.superficieFavorita,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mano Hábil (Diestra / Zurda)
                  GestureDetector(
                    onTap: () =>
                        _showHandPickerSheet(jugador.id, jugador.manoHabil),
                    child: _buildReadOnlyField(
                      label: 'Mano Hábil',
                      value: jugador.manoHabil,
                      valueColor: AppTheme.accentLimeColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tu Ubicación (Dropdown CABA)
                  _buildLocationDropdown(context, jugador.id),

                  const SizedBox(height: 36),

                  // Botón Usuarios Bloqueados
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showBlockedUsersSheet(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF161E1A),
                        side: const BorderSide(
                          color: AppTheme.accentLimeColor,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(
                        Icons.lock_person_outlined,
                        color: AppTheme.accentLimeColor,
                        size: 20,
                      ),
                      label: const Text(
                        'Usuarios Bloqueados',
                        style: TextStyle(
                          color: AppTheme.accentLimeColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Botón Eliminar mi cuenta
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF161E1A),
                        side: const BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      label: const Text(
                        'Eliminar mi cuenta',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Esta acción es irreversible',
                      style: TextStyle(color: Color(0xFF8E9A93), fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeparatelyEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required FocusNode focusNode,
    required VoidCallback onToggleEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E9A93),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: const Color(0xFF161E1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        controller.text.isEmpty
                            ? 'No configurado'
                            : controller.text,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              GestureDetector(
                onTap: onToggleEdit,
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 18,
                  color: isEditing
                      ? AppTheme.accentLimeColor
                      : const Color(0xFF8E9A93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E9A93),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: const Color(0xFF161E1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
              const RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF8E9A93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(BuildContext context, String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Tu Ubicación',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E9A93),
              letterSpacing: 0.4,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation,
          isExpanded: true,
          hint: const Text(
            'Selecciona tu barrio',
            style: TextStyle(fontSize: 13, color: Color(0xFF8E9A93)),
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          icon: const RotatedBox(
            quarterTurns: 1,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF8E9A93),
            ),
          ),
          dropdownColor: const Color(0xFF161E1A),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161E1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.accentLimeColor,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _barriosCABA
              .map(
                (b) => DropdownMenuItem<String>(
                  value: b,
                  child: Text(b, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedLocation = val;
              });
              context.read<ProfileBloc>().add(
                UpdateMyProfileAction(
                  usuarioId: currentUserId,
                  nuevoBarrio: '$val, CABA',
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

// Widget _LevelPickerSheet: Dark Frosted Glass SetPoint
class _LevelPickerSheet extends StatefulWidget {
  final List<_TennisLevel> levels;
  final String initialLevel;

  const _LevelPickerSheet({required this.levels, required this.initialLevel});

  @override
  State<_LevelPickerSheet> createState() => _LevelPickerSheetState();
}

class _LevelPickerSheetState extends State<_LevelPickerSheet> {
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141A17),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Cuál es tu nivel de tenis?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.levels.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = widget.levels[index];
                  final isSelected =
                      _selectedLevel.toLowerCase() == level.name.toLowerCase();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLevel = level.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? level.color.withValues(alpha: 0.18)
                            : const Color(0xFF1A221E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? level.color
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? level.color.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: level.color.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.star_rounded,
                              color: level.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${level.name} - ${level.description}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: level.color,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedLevel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Color(0xFF0E1311),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
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

// Widget _SurfacePickerSheet: Selector de Superficie Favorita
class _SurfacePickerSheet extends StatefulWidget {
  final List<_SurfaceOption> surfaces;
  final String initialSurface;

  const _SurfacePickerSheet({
    required this.surfaces,
    required this.initialSurface,
  });

  @override
  State<_SurfacePickerSheet> createState() => _SurfacePickerSheetState();
}

class _SurfacePickerSheetState extends State<_SurfacePickerSheet> {
  late String _selectedSurface;

  @override
  void initState() {
    super.initState();
    _selectedSurface = widget.initialSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141A17),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferencia de Cancha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Seleccioná tu tipo de superficie favorita para jugar',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E9A93)),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.surfaces.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final surface = widget.surfaces[index];
                  final isSelected =
                      _selectedSurface.toLowerCase() ==
                      surface.name.toLowerCase();
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedSurface = surface.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? surface.color.withValues(alpha: 0.18)
                            : const Color(0xFF1A221E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? surface.color
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? surface.color.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: surface.color.withValues(
                              alpha: 0.2,
                            ),
                            child: Icon(
                              surface.icon,
                              color: surface.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surface.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  surface.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E9A93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: surface.color,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedSurface),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Color(0xFF0E1311),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
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

// Widget _HandPickerSheet: Selector de Mano Hábil
class _HandPickerSheet extends StatefulWidget {
  final List<_HandOption> options;
  final String initialHand;

  const _HandPickerSheet({required this.options, required this.initialHand});

  @override
  State<_HandPickerSheet> createState() => _HandPickerSheetState();
}

class _HandPickerSheetState extends State<_HandPickerSheet> {
  late String _selectedHand;

  @override
  void initState() {
    super.initState();
    _selectedHand = widget.initialHand;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141A17),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mano Hábil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Seleccioná tu brazo de juego dominante',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E9A93)),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected =
                      _selectedHand.toLowerCase() ==
                          option.name.toLowerCase() ||
                      (_selectedHand.toLowerCase().startsWith('diestr') &&
                          option.name.toLowerCase().startsWith('diestr')) ||
                      (_selectedHand.toLowerCase().startsWith('zurd') &&
                          option.name.toLowerCase().startsWith('zurd'));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHand = option.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentLimeColor.withValues(alpha: 0.18)
                            : const Color(0xFF1A221E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentLimeColor
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppTheme.accentLimeColor.withValues(
                                    alpha: 0.25,
                                  )
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.accentLimeColor
                                .withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.sports_tennis_rounded,
                              color: AppTheme.accentLimeColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  option.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E9A93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.accentLimeColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedHand),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Color(0xFF0E1311),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
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
