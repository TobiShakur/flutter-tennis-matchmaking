import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// FORMATEADOR CENTRALIZADO Y RESILIENTE DE FECHAS (Staff Engineer Hardened)
// Garantiza formateo en español rioplatense sin arrojar LocaleDataException jamás.
class AppDateFormatter {
  AppDateFormatter._();

  static bool _initialized = false;

  /// Inicializa los símbolos de fechas para español de manera segura
  static Future<void> inicializar() async {
    if (_initialized) return;
    try {
      await initializeDateFormatting('es_ES', null);
      await initializeDateFormatting('es', null);
      _initialized = true;
    } catch (_) {
      // Fallback silencioso si el entorno no soporta carga dinámica
      _initialized = false;
    }
  }

  static const List<String> _mesesAbreviadosMayus = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  static const List<String> _mesesAbreviadosCap = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  static const List<String> _diasAbreviados = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  /// Devuelve formato corto lateral para partidos (ej: "FEB 24", "MAR 4")
  static String mesDiaLateral(DateTime dt) {
    try {
      final mes = DateFormat(
        'MMM',
        'es_ES',
      ).format(dt).toUpperCase().replaceAll('.', '');
      return '$mes ${dt.day}';
    } catch (_) {
      // Fallback robusto garantizado: no depende de intl locales cargados
      final mesIndex = dt.month - 1;
      final mesSafe = (mesIndex >= 0 && mesIndex < 12)
          ? _mesesAbreviadosMayus[mesIndex]
          : 'MES';
      return '$mesSafe ${dt.day}';
    }
  }

  /// Devuelve formato para cabecera de detalle de partido (ej: "Mar 4 - 18:30")
  static String fechaDetalle(DateTime dt) {
    final hora = dosDigitos(dt.hour);
    final minuto = dosDigitos(dt.minute);
    try {
      final mes = DateFormat('MMM', 'es_ES').format(dt);
      final mesCap = mes.isNotEmpty
          ? '${mes[0].toUpperCase()}${mes.substring(1).replaceAll('.', '')}'
          : '';
      return '$mesCap ${dt.day} - $hora:$minuto';
    } catch (_) {
      final mesIndex = dt.month - 1;
      final mesSafe = (mesIndex >= 0 && mesIndex < 12)
          ? _mesesAbreviadosCap[mesIndex]
          : '';
      return '$mesSafe ${dt.day} - $hora:$minuto';
    }
  }

  /// Devuelve formato relativo amigable para cards del Feed (ej: "Hoy, 18:30", "Mañana, 09:15", "Lun 4 Mar • 18:30")
  static String fechaRelativa(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final maniana = hoy.add(const Duration(days: 1));
    final fechaDia = DateTime(fecha.year, fecha.month, fecha.day);

    final hora = '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}';

    if (fechaDia == hoy) {
      return 'Hoy, $hora';
    } else if (fechaDia == maniana) {
      return 'Mañana, $hora';
    }

    try {
      return DateFormat('EEE d MMM • HH:mm', 'es_ES').format(fecha);
    } catch (_) {
      final diaSemanaIndex = fecha.weekday - 1;
      final diaSemana = (diaSemanaIndex >= 0 && diaSemanaIndex < 7)
          ? _diasAbreviados[diaSemanaIndex]
          : '';
      final mesIndex = fecha.month - 1;
      final mesSafe = (mesIndex >= 0 && mesIndex < 12)
          ? _mesesAbreviadosCap[mesIndex]
          : '';
      return '$diaSemana ${fecha.day} $mesSafe • $hora';
    }
  }

  /// Devuelve la hora con 2 dígitos (ej: "18:30")
  static String hora(DateTime dt) {
    return '${dosDigitos(dt.hour)}:${dosDigitos(dt.minute)}';
  }

  /// Devuelve fecha en formato estándar (ej: "04/11/2026")
  static String fechaEstandar(DateTime dt) {
    return '${dosDigitos(dt.day)}/${dosDigitos(dt.month)}/${dt.year}';
  }

  static String dosDigitos(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
