import 'package:flutter/foundation.dart';

// EVENTOS DEL PROFILE BLOC
@immutable
abstract class ProfileAction {
  const ProfileAction();
}

@immutable
class LoadProfilesAction extends ProfileAction {
  final String currentUserId;

  const LoadProfilesAction({required this.currentUserId});
}

@immutable
class UpdateMyProfileAction extends ProfileAction {
  final String usuarioId;
  final String? nuevoNombre;
  final String? nuevoNivel;
  final String? nuevoBarrio;
  final String? nuevaSuperficie;
  final String? nuevaManoHabil;
  final int? nuevoRadioKm;
  final String? nuevoAvatarUrl;

  const UpdateMyProfileAction({
    required this.usuarioId,
    this.nuevoNombre,
    this.nuevoNivel,
    this.nuevoBarrio,
    this.nuevaSuperficie,
    this.nuevaManoHabil,
    this.nuevoRadioKm,
    this.nuevoAvatarUrl,
  });
}

@immutable
class BlockUserAction extends ProfileAction {
  final String usuarioId;

  const BlockUserAction({required this.usuarioId});
}

@immutable
class UnblockUserAction extends ProfileAction {
  final String usuarioId;

  const UnblockUserAction({required this.usuarioId});
}
