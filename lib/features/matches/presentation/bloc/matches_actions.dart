import 'package:flutter/foundation.dart';
import '../../domain/entities/partido_entity.dart';

/// Eventos semánticos de acción para [MatchesBloc].
@immutable
abstract class MatchesAction {
  const MatchesAction();
}

@immutable
class LoadMatchesAction extends MatchesAction {
  final List<String> modalidadesFiltro;
  final List<String> superficiesFiltro;
  final List<String> nivelesFiltro;
  final double? radioFiltroKm;
  final String nivelUsuario;
  final double usuarioLat;
  final double usuarioLng;

  const LoadMatchesAction({
    this.modalidadesFiltro = const [],
    this.superficiesFiltro = const [],
    this.nivelesFiltro = const [],
    this.radioFiltroKm,
    this.nivelUsuario = 'Intermedio',
    this.usuarioLat = -34.6037, // Obelisco CABA
    this.usuarioLng = -58.3816,
  });

  String? get modalidadFiltro =>
      modalidadesFiltro.isNotEmpty ? modalidadesFiltro.first : null;
  String? get superficieFiltro =>
      superficiesFiltro.isNotEmpty ? superficiesFiltro.first : null;
  String? get nivelFiltro =>
      nivelesFiltro.isNotEmpty ? nivelesFiltro.first : null;
}

@immutable
class UpdateRadiusAction extends MatchesAction {
  final double radioKm;

  const UpdateRadiusAction(this.radioKm);
}

@immutable
class JoinMatchAction extends MatchesAction {
  final String partidoId;
  final String usuarioId;

  const JoinMatchAction({required this.partidoId, required this.usuarioId});
}

@immutable
class LeaveMatchAction extends MatchesAction {
  final String partidoId;
  final String usuarioId;

  const LeaveMatchAction({required this.partidoId, required this.usuarioId});
}

@immutable
class CreateMatchAction extends MatchesAction {
  final PartidoEntity partidoNuevo;

  const CreateMatchAction({required this.partidoNuevo});
}

@immutable
class UpdateMatchAction extends MatchesAction {
  final PartidoEntity partidoActualizado;

  const UpdateMatchAction({required this.partidoActualizado});
}

@immutable
class DeleteMatchAction extends MatchesAction {
  final String partidoId;

  const DeleteMatchAction({required this.partidoId});
}
