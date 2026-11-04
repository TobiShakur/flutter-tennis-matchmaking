import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/matches_actions.dart';
import '../bloc/matches_bloc.dart';

class MatchFiltersBottomSheet extends StatefulWidget {
  final List<String> initialModalidades;
  final List<String> initialSuperficies;
  final List<String> initialNiveles;
  final double initialRadioKm;

  const MatchFiltersBottomSheet({
    super.key,
    this.initialModalidades = const [],
    this.initialSuperficies = const [],
    this.initialNiveles = const [],
    required this.initialRadioKm,
  });

  static Future<void> show(BuildContext context) {
    final state = context.read<MatchesBloc>().state;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MatchFiltersBottomSheet(
        initialModalidades: state.modalidadesFiltro,
        initialSuperficies: state.superficiesFiltro,
        initialNiveles: state.nivelesFiltro,
        initialRadioKm: state.radioKm,
      ),
    );
  }

  @override
  State<MatchFiltersBottomSheet> createState() =>
      _MatchFiltersBottomSheetState();
}

class _MatchFiltersBottomSheetState extends State<MatchFiltersBottomSheet> {
  late Set<String> _modalidades;
  late Set<String> _superficies;
  late Set<String> _niveles;
  late double _radioKm;

  static const List<String> _todasModalidades = ['Singles', 'Dobles'];
  static const List<String> _todasSuperficies = [
    'Polvo de ladrillo',
    'Cemento',
    'Césped',
  ];
  static const List<String> _todosNiveles = [
    'Principiante',
    'Básico',
    'Intermedio',
    'Avanzado',
    'Experto',
  ];

  @override
  void initState() {
    super.initState();
    _modalidades = Set<String>.from(widget.initialModalidades);
    _superficies = Set<String>.from(widget.initialSuperficies);
    _niveles = Set<String>.from(widget.initialNiveles);

    // Radio de búsqueda en pasos de 1 km
    _radioKm = widget.initialRadioKm.clamp(5.0, 20.0).roundToDouble();
  }

  void _toggleModalidad(String mod) {
    setState(() {
      if (_modalidades.contains(mod)) {
        _modalidades.remove(mod);
      } else {
        _modalidades.add(mod);
      }
      // Si elige ambas o ninguna, se marca "Todas"
      if (_modalidades.length >= _todasModalidades.length) {
        _modalidades.clear();
      }
    });
  }

  void _seleccionarTodasModalidades() {
    setState(() {
      _modalidades.clear();
    });
  }

  void _toggleSuperficie(String sup) {
    setState(() {
      if (_superficies.contains(sup)) {
        _superficies.remove(sup);
      } else {
        _superficies.add(sup);
      }
      // Si elige las 3 o ninguna, se marca "Todas"
      if (_superficies.length >= _todasSuperficies.length) {
        _superficies.clear();
      }
    });
  }

  void _seleccionarTodasSuperficies() {
    setState(() {
      _superficies.clear();
    });
  }

  void _toggleNivel(String lvl) {
    setState(() {
      if (_niveles.contains(lvl)) {
        _niveles.remove(lvl);
      } else {
        _niveles.add(lvl);
      }
      // Si elige los 5 o ninguno, se marca "Todos"
      if (_niveles.length >= _todosNiveles.length) {
        _niveles.clear();
      }
    });
  }

  void _seleccionarTodosNiveles() {
    setState(() {
      _niveles.clear();
    });
  }

  void _restablecerFiltros() {
    final miPerfil = context.read<ProfileBloc>().state.miPerfil;
    final nivelUsuario = miPerfil?.nivel ?? 'Intermedio';

    context.read<MatchesBloc>().add(
      LoadMatchesAction(
        modalidadesFiltro: const [],
        superficiesFiltro: const [],
        nivelesFiltro: const [],
        radioFiltroKm: 10.0,
        nivelUsuario: nivelUsuario,
      ),
    );

    Navigator.of(context).pop();
    AppTheme.showSnackBar(
      context,
      'Filtros restablecidos.',
      icon: Icons.restore_rounded,
    );
  }

  void _aplicarFiltros() {
    final miPerfil = context.read<ProfileBloc>().state.miPerfil;
    final nivelUsuario = miPerfil?.nivel ?? 'Intermedio';

    context.read<MatchesBloc>().add(
      LoadMatchesAction(
        modalidadesFiltro: _modalidades.toList(),
        superficiesFiltro: _superficies.toList(),
        nivelesFiltro: _niveles.toList(),
        radioFiltroKm: _radioKm,
        nivelUsuario: nivelUsuario,
      ),
    );

    Navigator.of(context).pop();
    AppTheme.showSnackBar(
      context,
      'Filtros aplicados.',
      icon: Icons.tune_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141A17),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLimeColor.withValues(
                            alpha: 0.16,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppTheme.accentLimeColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Filtros de Partidos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _restablecerFiltros,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Restablecer',
                          style: TextStyle(
                            color: Color(0xFF8E9A93),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF8E9A93),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 16),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Modalidad de Juego'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Todas',
                            isSelected: _modalidades.isEmpty,
                            activeColor: AppTheme.accentLimeColor,
                            onSelected: _seleccionarTodasModalidades,
                          ),
                          _buildChoiceChip(
                            label: 'Singles (2J)',
                            isSelected: _modalidades.contains('Singles'),
                            activeColor: AppTheme.accentLimeColor,
                            onSelected: () => _toggleModalidad('Singles'),
                          ),
                          _buildChoiceChip(
                            label: 'Dobles (4J)',
                            isSelected: _modalidades.contains('Dobles'),
                            activeColor: AppTheme.accentLimeColor,
                            onSelected: () => _toggleModalidad('Dobles'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _buildSectionTitle('Superficie de la Cancha'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Todas',
                            isSelected: _superficies.isEmpty,
                            activeColor: AppTheme.accentLimeColor,
                            onSelected: _seleccionarTodasSuperficies,
                          ),
                          _buildChoiceChip(
                            label: 'Polvo de ladrillo',
                            isSelected: _superficies.contains(
                              'Polvo de ladrillo',
                            ),
                            activeColor: AppTheme.accentClayColor,
                            onSelected: () =>
                                _toggleSuperficie('Polvo de ladrillo'),
                          ),
                          _buildChoiceChip(
                            label: 'Cemento',
                            isSelected: _superficies.contains('Cemento'),
                            activeColor: AppTheme.accentHardCourtColor,
                            onSelected: () => _toggleSuperficie('Cemento'),
                          ),
                          _buildChoiceChip(
                            label: 'Césped',
                            isSelected: _superficies.contains('Césped'),
                            activeColor: AppTheme.accentGrassColor,
                            onSelected: () => _toggleSuperficie('Césped'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _buildSectionTitle('Nivel de Juego Buscado'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip(
                            label: 'Todos',
                            isSelected: _niveles.isEmpty,
                            activeColor: AppTheme.accentLimeColor,
                            onSelected: _seleccionarTodosNiveles,
                          ),
                          ..._todosNiveles.map((lvl) {
                            final color = AppTheme.getColorForLevel(lvl);
                            return _buildChoiceChip(
                              label: lvl,
                              isSelected: _niveles.contains(lvl),
                              activeColor: color,
                              hasStar: true,
                              onSelected: () => _toggleNivel(lvl),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Radio de Búsqueda'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
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
                            child: Text(
                              '${_radioKm.toInt()} km',
                              style: const TextStyle(
                                color: AppTheme.accentLimeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Slider Neón con paso de 1 km (min: 5.0, max: 20.0, divisiones: 15)
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.accentLimeColor,
                          inactiveTrackColor: const Color(0xFF243028),
                          trackHeight: 4,
                          thumbColor: AppTheme.accentLimeColor,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9,
                          ),
                          overlayColor: AppTheme.accentLimeColor.withValues(
                            alpha: 0.2,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                        ),
                        child: Slider(
                          value: _radioKm,
                          min: 5.0,
                          max: 20.0,
                          divisions: 15,
                          onChanged: (val) =>
                              setState(() => _radioKm = val.roundToDouble()),
                        ),
                      ),

                      // Chips rápidos alineados directamente bajo los puntos del slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [5.0, 10.0, 15.0, 20.0].map((km) {
                            final bool activo = (_radioKm - km).abs() < 0.5;
                            return GestureDetector(
                              onTap: () => setState(() => _radioKm = km),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: activo
                                      ? AppTheme.accentLimeColor.withValues(
                                          alpha: 0.18,
                                        )
                                      : Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: activo
                                        ? AppTheme.accentLimeColor
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '${km.toInt()} km',
                                  style: TextStyle(
                                    color: activo
                                        ? AppTheme.accentLimeColor
                                        : const Color(0xFF8E9A93),
                                    fontSize: 11.5,
                                    fontWeight: activo
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Botón Aplicar Filtros limpio
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _aplicarFiltros,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    foregroundColor: const Color(0xFF0E1311),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: AppTheme.accentLimeColor.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    bool hasStar = false,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.white.withValues(alpha: 0.09),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 14, color: activeColor),
              const SizedBox(width: 5),
            ] else if (hasStar) ...[
              Icon(Icons.star_rounded, size: 13, color: activeColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF9EABA3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
