import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_ready_notifier.dart';
import 'core/services/perf_telemetry_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_formatter.dart';
import 'core/widgets/desktop_showcase_wrapper.dart';
import 'core/widgets/perf_debug_overlay.dart';
import 'features/chat/data/repositories/local_chat_repository.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/matches/data/repositories/local_matches_repository.dart';
import 'features/matches/presentation/bloc/matches_actions.dart';
import 'features/matches/presentation/bloc/matches_bloc.dart';
import 'features/matches/presentation/screens/home_shell_screen.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';
import 'features/profile/data/repositories/local_profile_repository.dart';
import 'features/profile/presentation/bloc/profile_actions.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// Permite arrastrar con el mouse y rueda en Web/Desktop exactamente como en Mobile
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDateFormatter.inicializar();
  runApp(const TenisApp());
}

class TenisApp extends StatefulWidget {
  const TenisApp({super.key, this.perfTelemetryService});

  final PerfTelemetryService? perfTelemetryService;

  @override
  State<TenisApp> createState() => _TenisAppState();
}

class _TenisAppState extends State<TenisApp> {
  static const List<String> _criticalImageAssets = [
    'assets/images/stock/tennis_1.webp',
    'assets/images/stock/tennis_2.webp',
    'assets/images/stock/tennis_4.webp',
  ];

  static const List<String> _localFontAssets = [
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Medium.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
    'assets/fonts/Poppins-ExtraBold.ttf',
    'assets/fonts/Poppins-Black.ttf',
  ];

  bool _onboardingCompletado = false;
  bool _warmupStarted = false;
  Timer? _warmupTimeoutTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmupStarted) {
      return;
    }
    _warmupStarted = true;
    _awaitInitialAssetsAndNotify();
  }

  Future<void> _preloadLocalFonts() async {
    final loader = FontLoader('Poppins');
    for (final assetPath in _localFontAssets) {
      loader.addFont(rootBundle.load(assetPath));
    }
    await loader.load();
  }

  Future<void> _awaitInitialAssetsAndNotify() async {
    final readyCompleter = Completer<void>();

    void finishWarmup() {
      _warmupTimeoutTimer?.cancel();
      _warmupTimeoutTimer = null;
      if (!readyCompleter.isCompleted) {
        readyCompleter.complete();
      }
    }

    _warmupTimeoutTimer = Timer(
      const Duration(milliseconds: 1500),
      finishWarmup,
    );

    final firstFrameCompleter = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!firstFrameCompleter.isCompleted) {
        firstFrameCompleter.complete();
      }
    });

    final imageFutures = <Future<void>>[
      for (final asset in _criticalImageAssets)
        precacheImage(AssetImage(asset), context).catchError((_) {}),
    ];

    unawaited(
      Future.wait<void>([
        firstFrameCompleter.future,
        _preloadLocalFonts().catchError((_) {}),
        ...imageFutures,
      ]).then((_) => finishWarmup(), onError: (_) => finishWarmup()),
    );

    await readyCompleter.future;

    if (mounted) {
      notifyAppReady();
    }
  }

  @override
  void dispose() {
    _warmupTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(repo: LocalProfileRepository())
            ..add(
              const LoadProfilesAction(
                currentUserId: AppConstants.currentUserId,
              ),
            ),
        ),
        BlocProvider<MatchesBloc>(
          create: (_) =>
              MatchesBloc(repo: LocalMatchesRepository())
                ..add(const LoadMatchesAction()),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(repo: LocalChatRepository()),
        ),
      ],
      child: MaterialApp(
        title: AppTheme.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scrollBehavior: const AppScrollBehavior(),
        builder: (context, child) => Stack(
          alignment: Alignment.topLeft,
          children: [
            DesktopShowcaseWrapper(child: child ?? const SizedBox()),
            PerfDebugOverlay(telemetryService: widget.perfTelemetryService),
          ],
        ),
        home: _onboardingCompletado
            ? const HomeShellScreen()
            : WelcomeScreen(
                onFinishOnboarding: () {
                  setState(() => _onboardingCompletado = true);
                },
              ),
      ),
    );
  }
}
