import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Modal Bottom Sheet para selección de Fecha y Horario de la cancha
/// (Calendario visual mensual + grilla de turnos en franjas Mañana / Tarde / Noche).
class MatchDateTimePickerSheet extends StatefulWidget {
  final DateTime initialDateTime;

  const MatchDateTimePickerSheet({super.key, required this.initialDateTime});

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDateTime,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          MatchDateTimePickerSheet(initialDateTime: initialDateTime),
    );
  }

  @override
  State<MatchDateTimePickerSheet> createState() =>
      _MatchDateTimePickerSheetState();
}

class _MatchDateTimePickerSheetState extends State<MatchDateTimePickerSheet> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;

  late int _viewYear;
  late int _viewMonth;

  final DateTime _today = DateTime.now();

  static const List<String> _nombresMeses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> _diasSemana = [
    'LUN',
    'MAR',
    'MIÉ',
    'JUE',
    'VIE',
    'SÁB',
    'DOM',
  ];

  // Horarios agrupados por franja
  static const List<String> _horariosManana = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
  ];

  static const List<String> _horariosTarde = [
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
  ];

  static const List<String> _horariosNoche = [
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
    '00:00',
    '00:30',
    '01:00',
    '01:30',
    '02:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    _selectedHour = widget.initialDateTime.hour;
    _selectedMinute = widget.initialDateTime.minute >= 30 ? 30 : 0;

    _viewYear = _selectedDate.year;
    _viewMonth = _selectedDate.month;
  }

  void _mesAnterior() {
    final now = DateTime(_today.year, _today.month);
    final actual = DateTime(_viewYear, _viewMonth);
    if (actual.isAfter(now)) {
      setState(() {
        if (_viewMonth == 1) {
          _viewMonth = 12;
          _viewYear--;
        } else {
          _viewMonth--;
        }
      });
    }
  }

  void _mesSiguiente() {
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
    });
  }

  void _seleccionarHorario(String horarioStr) {
    final parts = horarioStr.split(':');
    if (parts.length == 2) {
      setState(() {
        _selectedHour = int.parse(parts[0]);
        _selectedMinute = int.parse(parts[1]);
      });
    }
  }

  bool _esHorarioSeleccionado(String horarioStr) {
    final parts = horarioStr.split(':');
    if (parts.length == 2) {
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return _selectedHour == h && _selectedMinute == m;
    }
    return false;
  }

  void _confirmar() {
    final resultado = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final int diasEnMes = DateTime(_viewYear, _viewMonth + 1, 0).day;
    final int primerDiaSemana = DateTime(
      _viewYear,
      _viewMonth,
      1,
    ).weekday; // 1 = Lun, 7 = Dom
    final int celdasVacias = primerDiaSemana - 1;

    final String horarioActualStr =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF101713),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Botón volver + Título "Fecha y hora"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Fecha y hora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Contenido Scrolleable (Calendario + Horarios)
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // CARD DEL CALENDARIO
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151E19),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header del mes con flechas < y >
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_nombresMeses[_viewMonth - 1]} $_viewYear',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  color: Colors.white70,
                                  onPressed: _mesAnterior,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  color: Colors.white70,
                                  onPressed: _mesSiguiente,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Días de la semana (LUN, MAR, ...)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _diasSemana.map((d) {
                            return SizedBox(
                              width: 34,
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF728078),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),

                        // Grilla de días
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: celdasVacias + diasEnMes,
                          itemBuilder: (context, index) {
                            if (index < celdasVacias) {
                              return const SizedBox();
                            }

                            final int dia = index - celdasVacias + 1;
                            final DateTime fechaCelda = DateTime(
                              _viewYear,
                              _viewMonth,
                              dia,
                            );
                            final bool esPasado = fechaCelda.isBefore(
                              DateTime(_today.year, _today.month, _today.day),
                            );
                            final bool esSeleccionado =
                                _selectedDate.year == fechaCelda.year &&
                                _selectedDate.month == fechaCelda.month &&
                                _selectedDate.day == fechaCelda.day;
                            final bool esHoy =
                                _today.year == fechaCelda.year &&
                                _today.month == fechaCelda.month &&
                                _today.day == fechaCelda.day;

                            return GestureDetector(
                              onTap: esPasado
                                  ? null
                                  : () => setState(
                                      () => _selectedDate = fechaCelda,
                                    ),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: esSeleccionado
                                      ? AppTheme.accentLimeColor
                                      : Colors.transparent,
                                  border: esHoy && !esSeleccionado
                                      ? Border.all(
                                          color: AppTheme.accentLimeColor
                                              .withValues(alpha: 0.6),
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  '$dia',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: esSeleccionado
                                        ? FontWeight.w900
                                        : (esHoy
                                              ? FontWeight.w700
                                              : FontWeight.w500),
                                    color: esSeleccionado
                                        ? const Color(0xFF0E1311)
                                        : (esPasado
                                              ? Colors.white24
                                              : Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECCIÓN: HORARIOS DISPONIBLES
                  const Text(
                    'Horarios disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Franja 1: Mañana
                  _buildFranjaHoraria(
                    titulo: 'Mañana',
                    horarios: _horariosManana,
                  ),

                  const SizedBox(height: 16),

                  // Franja 2: Tarde
                  _buildFranjaHoraria(
                    titulo: 'Tarde',
                    horarios: _horariosTarde,
                  ),

                  const SizedBox(height: 16),

                  // Franja 3: Noche
                  _buildFranjaHoraria(
                    titulo: 'Noche',
                    horarios: _horariosNoche,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // BOTÓN CTA INFERIOR: GUARDAR HORARIO
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLimeColor,
                    foregroundColor: const Color(0xFF0E1311),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.accentLimeColor.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  onPressed: _confirmar,
                  child: Text(
                    'Guardar horario ($horarioActualStr hs)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Color(0xFF0E1311),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFranjaHoraria({
    required String titulo,
    required List<String> horarios,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8E9A93),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: horarios.map((h) {
            final bool seleccionado = _esHorarioSeleccionado(h);
            return GestureDetector(
              onTap: () => _seleccionarHorario(h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 72,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppTheme.accentLimeColor
                      : const Color(0xFF151E19),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: seleccionado
                        ? AppTheme.accentLimeColor
                        : Colors.white.withValues(alpha: 0.10),
                    width: 1.2,
                  ),
                  boxShadow: seleccionado
                      ? [
                          BoxShadow(
                            color: AppTheme.accentLimeColor.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  h,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: seleccionado
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: seleccionado
                        ? const Color(0xFF0E1311)
                        : const Color(0xFF8E9A93),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
