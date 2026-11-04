import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tenis_app/core/theme/app_theme.dart';
import 'package:tenis_app/features/matches/domain/entities/partido_entity.dart';
import 'package:tenis_app/features/matches/domain/repositories/matches_repository.dart';
import 'package:tenis_app/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:tenis_app/features/matches/presentation/bloc/matches_state.dart';
import 'package:tenis_app/features/matches/presentation/screens/match_detail_screen.dart';
import 'package:tenis_app/features/matches/presentation/screens/my_matches_screen.dart';
import 'package:tenis_app/features/profile/domain/entities/jugador_entity.dart';
import 'package:tenis_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:tenis_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tenis_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:tenis_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:tenis_app/features/profile/presentation/screens/mi_cuenta_screen.dart';
import 'package:tenis_app/features/profile/presentation/screens/perfil_jugador_screen.dart';

class MockMatchesRepository extends Mock implements MatchesRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockMatchesRepository mockMatchesRepo;
  late MockProfileRepository mockProfileRepo;

  final ahora = DateTime.now();
  final partidoProximo = PartidoEntity(
    id: 'partido_01',
    titulo: 'Singles Nocturno en Palermo',
    modalidad: 'Singles',
    superficie: 'Polvo de ladrillo',
    nivel: 'Intermedio',
    organizadorId: 'user_tobias_01',
    organizadorNombre: 'Tobías Shakur',
    imagenUrl: 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0',
    fechaHora: ahora.add(const Duration(days: 1)),
    fechaCreacion: ahora.subtract(const Duration(days: 1)),
    cuposTotales: 2,
    jugadoresUnidosIds: const ['user_tobias_01'],
    clubNombre: 'Club Comercio Tenis',
    direccion: 'Palermo Chico, CABA',
    latitud: -34.5781,
    longitud: -58.4260,
  );

  final jugadorMock = const JugadorEntity(
    id: 'user_tobias_01',
    nombre: 'Tobías Shakur',
    avatarUrl: 'https://i.pravatar.cc/300?img=12',
    bio: 'Jugador de polvo de ladrillo.',
    nivel: 'Intermedio',
    manoHabil: 'Diestro',
    tipoReves: 'Revés a dos manos',
    superficieFavorita: 'Polvo de ladrillo',
    barrio: 'Palermo, CABA',
    radioBusquedaKm: 12,
    historialPartidos: [],
  );

  setUp(() {
    mockMatchesRepo = MockMatchesRepository();
    mockProfileRepo = MockProfileRepository();
  });

  Widget crearAppConProviders({
    required Widget child,
    MatchesState? matchesState,
    ProfileState? profileState,
  }) {
    final matchesBloc = MatchesBloc(repo: mockMatchesRepo);
    final profileBloc = ProfileBloc(repo: mockProfileRepo);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MatchesBloc>.value(
            value: matchesBloc
              ..emit(matchesState ?? MatchesState(partidos: [partidoProximo])),
          ),
          BlocProvider<ProfileBloc>.value(
            value: profileBloc
              ..emit(
                profileState ??
                    ProfileState(
                      miPerfil: jugadorMock,
                      directorioJugadores: {'user_tobias_01': jugadorMock},
                    ),
              ),
          ),
        ],
        child: child,
      ),
    );
  }

  group('Screens Rendering Tests (Sin LocaleDataException)', () {
    testWidgets(
      'MyMatchesScreen renderiza correctamente sin arrojar excepciones de fecha',
      (tester) async {
        await tester.pumpWidget(
          crearAppConProviders(child: const MyMatchesScreen()),
        );
        await tester.pump();

        // Verificar que el título de la pantalla está presente
        expect(find.text('Mis partidos!'), findsOneWidget);
        expect(find.text('Próximos'), findsOneWidget);
        expect(find.text('Pasados'), findsOneWidget);

        // No debe existir ningún widget de error rojo
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'MatchDetailScreen renderiza con diseno Glassmorphism, formacion de equipos y botones neon',
      (tester) async {
        await tester.pumpWidget(
          crearAppConProviders(
            child: const MatchDetailScreen(partidoId: 'partido_01'),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar título hero y fecha
        expect(find.text('SINGLES NOCTURNO EN PALERMO'), findsOneWidget);
        expect(find.text('Club Comercio Tenis'), findsOneWidget);
        expect(find.text('90 min'), findsOneWidget);

        // Verificar controles de header (Volver glass y Compartir neon)
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.share_rounded), findsOneWidget);

        // Sin excepciones de renderizado
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'EditProfileScreen renderiza los campos y botón de Editar Nivel',
      (tester) async {
        await tester.pumpWidget(
          crearAppConProviders(child: const EditProfileScreen()),
        );
        await tester.pump();

        expect(find.text('Tu nombre'), findsOneWidget);
        expect(find.text('Tu apellido'), findsOneWidget);
        expect(find.text('Editar Nivel'), findsOneWidget);
        expect(find.text('Preferencia de Cancha'), findsOneWidget);
        expect(find.text('Mano Hábil'), findsOneWidget);
        expect(find.text('Tu Ubicación'), findsOneWidget);
        expect(find.text('Usuarios Bloqueados'), findsOneWidget);
        expect(find.text('Eliminar mi cuenta'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'MiCuentaScreen renderiza PlayerProfileCard armónica con pods y botón editar',
      (tester) async {
        await tester.pumpWidget(
          crearAppConProviders(child: const MiCuentaScreen()),
        );
        await tester.pump();

        expect(find.text('Mi Perfil'), findsOneWidget);
        expect(find.text('Tobías Shakur'), findsOneWidget);
        expect(find.text('Palermo, CABA'), findsOneWidget);
        expect(find.text('Diestro'), findsOneWidget);
        expect(find.text('Intermedio'), findsOneWidget);
        expect(find.text('Polvo'), findsOneWidget);
        expect(find.text('Editar'), findsOneWidget);
        expect(find.text('Perfil'), findsOneWidget);
        expect(find.text('Notificaciones'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PerfilJugadorScreen renderiza PlayerProfileCard armónica sin frase ni bio',
      (tester) async {
        await tester.pumpWidget(
          crearAppConProviders(
            child: PerfilJugadorScreen(jugador: jugadorMock),
          ),
        );
        await tester.pump();

        expect(find.text('Tobías Shakur'), findsOneWidget);
        expect(find.text('Palermo, CABA'), findsOneWidget);
        expect(find.text('Diestro'), findsOneWidget);
        expect(find.text('Intermedio'), findsOneWidget);
        expect(find.text('Polvo'), findsOneWidget);
        expect(find.text('Historial de partidos'), findsOneWidget);

        // No debe contener la bio/frase
        expect(find.text('Jugador de polvo de ladrillo.'), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );

    test(
      'AppTheme.getColorForSurface retorna los colores correctos para las 3 variantes',
      () {
        expect(
          AppTheme.getColorForSurface('Césped'),
          AppTheme.accentGrassColor,
        );
        expect(
          AppTheme.getColorForSurface('cesped natural'),
          AppTheme.accentGrassColor,
        );
        expect(AppTheme.getColorForSurface('pasto'), AppTheme.accentGrassColor);

        expect(
          AppTheme.getColorForSurface('Cemento'),
          AppTheme.accentHardCourtColor,
        );
        expect(
          AppTheme.getColorForSurface('rápida'),
          AppTheme.accentHardCourtColor,
        );

        expect(
          AppTheme.getColorForSurface('Polvo de ladrillo'),
          AppTheme.accentClayColor,
        );
      },
    );

    test(
      'ProfileState almacena y copia correctamente la lista de usuariosBloqueadosIds',
      () {
        const stateInicial = ProfileState();
        expect(stateInicial.usuariosBloqueadosIds, isEmpty);

        final stateConBloqueados = stateInicial.copyWith(
          usuariosBloqueadosIds: ['user_santi_04'],
        );
        expect(
          stateConBloqueados.usuariosBloqueadosIds,
          contains('user_santi_04'),
        );
      },
    );

    test('MatchesState calcula correctamente totalFiltrosActivos', () {
      const stateLimpio = MatchesState();
      expect(stateLimpio.totalFiltrosActivos, 0);

      final stateConFiltros = stateLimpio.copyWith(
        modalidadFiltro: () => 'Singles',
        superficieFiltro: () => 'Césped',
        nivelFiltro: () => 'Avanzado',
        radioKm: 15.0,
      );
      expect(stateConFiltros.totalFiltrosActivos, 4);
    });

    test(
      'MatchesState multi-criterios calcula totalFiltrosActivos y getters',
      () {
        final stateMulti = const MatchesState().copyWith(
          modalidadesFiltro: ['Singles', 'Dobles'],
          superficiesFiltro: ['Polvo de ladrillo', 'Cemento'],
          nivelesFiltro: ['Intermedio'],
          radioKm: 20.0,
        );
        expect(stateMulti.totalFiltrosActivos, 4);
        expect(stateMulti.modalidadFiltro, 'Singles');
        expect(stateMulti.superficieFiltro, 'Polvo de ladrillo');
        expect(stateMulti.nivelFiltro, 'Intermedio');
      },
    );
  });
}
