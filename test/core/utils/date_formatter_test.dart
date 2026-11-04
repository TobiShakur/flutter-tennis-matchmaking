import 'package:flutter_test/flutter_test.dart';
import 'package:tenis_app/core/utils/date_formatter.dart';

void main() {
  group('AppDateFormatter Resilient Unit Tests', () {
    test('mesDiaLateral formatea correctamente meses y días', () {
      final fecha1 = DateTime(2026, 2, 24, 15, 30);
      final resultado1 = AppDateFormatter.mesDiaLateral(fecha1);
      expect(resultado1, contains('24'));
      expect(resultado1, contains('FEB'));

      final fecha2 = DateTime(2026, 11, 4, 10, 0);
      final resultado2 = AppDateFormatter.mesDiaLateral(fecha2);
      expect(resultado2, contains('4'));
      expect(resultado2, contains('NOV'));
    });

    test('fechaDetalle formatea mes, día y hora en 24h', () {
      final fecha = DateTime(2026, 3, 4, 18, 30);
      final resultado = AppDateFormatter.fechaDetalle(fecha);
      expect(resultado, contains('4'));
      expect(resultado, contains('18:30'));
      expect(resultado, anyOf(contains('Mar'), contains('MAR')));
    });

    test('fechaRelativa devuelve "Hoy, HH:mm" para la fecha actual', () {
      final ahora = DateTime.now();
      final fechaHoy = DateTime(ahora.year, ahora.month, ahora.day, 19, 45);
      final resultado = AppDateFormatter.fechaRelativa(fechaHoy);
      expect(resultado, 'Hoy, 19:45');
    });

    test('fechaRelativa devuelve "Mañana, HH:mm" para el día siguiente', () {
      final ahora = DateTime.now();
      final maniana = ahora.add(const Duration(days: 1));
      final fechaManiana = DateTime(
        maniana.year,
        maniana.month,
        maniana.day,
        10,
        15,
      );
      final resultado = AppDateFormatter.fechaRelativa(fechaManiana);
      expect(resultado, 'Mañana, 10:15');
    });

    test('hora formatea con padding de cero a la izquierda', () {
      final fecha = DateTime(2026, 1, 1, 9, 5);
      expect(AppDateFormatter.hora(fecha), '09:05');

      final fechaTarde = DateTime(2026, 1, 1, 23, 59);
      expect(AppDateFormatter.hora(fechaTarde), '23:59');
    });

    test('fechaEstandar formatea dd/MM/yyyy de forma consistente', () {
      final fecha = DateTime(2026, 7, 9);
      expect(AppDateFormatter.fechaEstandar(fecha), '09/07/2026');
    });

    test('dosDigitos maneja números unitarios y de dos cifras', () {
      expect(AppDateFormatter.dosDigitos(0), '00');
      expect(AppDateFormatter.dosDigitos(7), '07');
      expect(AppDateFormatter.dosDigitos(12), '12');
    });
  });
}
