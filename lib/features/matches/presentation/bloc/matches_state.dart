import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/partido_entity.dart';
import '../../domain/errors/match_error.dart';

/// Estado inmutable de [MatchesBloc] con soporte para multi-filtros y radio geográfico.
@immutable
class MatchesState extends Equatable {
  final List<PartidoEntity> partidos;
  final List<String> modalidadesFiltro;
  final List<String> superficiesFiltro;
  final List<String> nivelesFiltro;
  final bool isLoadingFeed;
  final String? procesandoPartidoId;
  final MatchError? matchError;
  final String? mensajeExito;

  // Ubicación del usuario y radio dinámico en KM
  final double usuarioLat;
  final double usuarioLng;
  final String direccionUsuario;
  final double radioKm;

  const MatchesState({
    this.partidos = const [],
    this.modalidadesFiltro = const [],
    this.superficiesFiltro = const [],
    this.nivelesFiltro = const [],
    this.isLoadingFeed = false,
    this.procesandoPartidoId,
    this.matchError,
    this.mensajeExito,
    this.usuarioLat = -34.6037, // Obelisco CABA
    this.usuarioLng = -58.3816,
    this.direccionUsuario = 'Av. 9 de Julio, Obelisco',
    this.radioKm = 10.0,
  });

  // Getters para compatibilidad
  String? get modalidadFiltro =>
      modalidadesFiltro.isNotEmpty ? modalidadesFiltro.first : null;
  String? get superficieFiltro =>
      superficiesFiltro.isNotEmpty ? superficiesFiltro.first : null;
  String? get nivelFiltro =>
      nivelesFiltro.isNotEmpty ? nivelesFiltro.first : null;

  // Contador de filtros aplicados
  int get totalFiltrosActivos {
    int count = 0;
    if (modalidadesFiltro.isNotEmpty) count++;
    if (superficiesFiltro.isNotEmpty) count++;
    if (nivelesFiltro.isNotEmpty) count++;
    if ((radioKm - 10.0).abs() > 0.5) count++;
    return count;
  }

  // Getter que filtra los partidos que están dentro del radio configurado
  List<PartidoEntity> get partidosDentroDelRadio {
    return partidos.where((p) {
      final distancia = p.distanciaDesdeKm(usuarioLat, usuarioLng);
      return distancia <= radioKm;
    }).toList();
  }

  MatchesState copyWith({
    List<PartidoEntity>? partidos,
    List<String>? modalidadesFiltro,
    List<String>? superficiesFiltro,
    List<String>? nivelesFiltro,
    String? Function()? modalidadFiltro,
    String? Function()? superficieFiltro,
    String? Function()? nivelFiltro,
    bool? isLoadingFeed,
    String? Function()? procesandoPartidoId,
    MatchError? Function()? matchError,
    String? Function()? mensajeExito,
    double? usuarioLat,
    double? usuarioLng,
    String? direccionUsuario,
    double? radioKm,
  }) {
    List<String> modFinal = modalidadesFiltro ?? this.modalidadesFiltro;
    if (modalidadFiltro != null) {
      final s = modalidadFiltro();
      modFinal = s != null && s.isNotEmpty ? [s] : const [];
    }

    List<String> supFinal = superficiesFiltro ?? this.superficiesFiltro;
    if (superficieFiltro != null) {
      final s = superficieFiltro();
      supFinal = s != null && s.isNotEmpty ? [s] : const [];
    }

    List<String> nivFinal = nivelesFiltro ?? this.nivelesFiltro;
    if (nivelFiltro != null) {
      final s = nivelFiltro();
      nivFinal = s != null && s.isNotEmpty ? [s] : const [];
    }

    return MatchesState(
      partidos: partidos ?? this.partidos,
      modalidadesFiltro: modFinal,
      superficiesFiltro: supFinal,
      nivelesFiltro: nivFinal,
      isLoadingFeed: isLoadingFeed ?? this.isLoadingFeed,
      procesandoPartidoId: procesandoPartidoId != null
          ? procesandoPartidoId()
          : this.procesandoPartidoId,
      matchError: matchError != null ? matchError() : null,
      mensajeExito: mensajeExito != null ? mensajeExito() : null,
      usuarioLat: usuarioLat ?? this.usuarioLat,
      usuarioLng: usuarioLng ?? this.usuarioLng,
      direccionUsuario: direccionUsuario ?? this.direccionUsuario,
      radioKm: radioKm ?? this.radioKm,
    );
  }

  @override
  List<Object?> get props => [
    partidos,
    modalidadesFiltro,
    superficiesFiltro,
    nivelesFiltro,
    isLoadingFeed,
    procesandoPartidoId,
    matchError,
    mensajeExito,
    usuarioLat,
    usuarioLng,
    direccionUsuario,
    radioKm,
  ];
}
