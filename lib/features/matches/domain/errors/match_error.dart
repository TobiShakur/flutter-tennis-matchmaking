import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Jerarquía sellada (Dart 3) para el modelado exhaustivo de errores de dominio en partidos.
@immutable
sealed class MatchError extends Equatable {
  final String dialogTitle;
  final String dialogText;

  const MatchError({required this.dialogTitle, required this.dialogText});

  @override
  List<Object?> get props => [dialogTitle, dialogText];
}

@immutable
class MatchErrorCanchaCompleta extends MatchError {
  const MatchErrorCanchaCompleta()
    : super(
        dialogTitle: 'Cancha completa',
        dialogText:
            'Justo se ocupó el último lugar disponible para este partido.',
      );
}

@immutable
class MatchErrorYaAnotado extends MatchError {
  const MatchErrorYaAnotado()
    : super(
        dialogTitle: 'Ya estás anotado',
        dialogText: 'Ya formás parte de la lista de jugadores de este partido.',
      );
}

@immutable
class MatchErrorGeneral extends MatchError {
  const MatchErrorGeneral(String detalle)
    : super(dialogTitle: 'Ocurrió un problema', dialogText: detalle);
}
