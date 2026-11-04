import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_formatter.dart';
import 'core/widgets/desktop_showcase_wrapper.dart';
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
  const TenisApp({super.key});

  @override
  State<TenisApp> createState() => _TenisAppState();
}

class _TenisAppState extends State<TenisApp> {
  bool _onboardingCompletado = false;

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
        builder: (context, child) =>
            DesktopShowcaseWrapper(child: child ?? const SizedBox()),
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
