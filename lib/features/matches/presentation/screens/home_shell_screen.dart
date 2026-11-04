import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/screens/mi_cuenta_screen.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_state.dart';
import 'create_match_screen.dart';
import 'feed_screen.dart';
import 'my_matches_screen.dart';

// NAVEGACIÓN PRINCIPAL ESTILO CLASH ROYALE CON DESLIZAMIENTO ENTRE PESTAÑAS
// Y OCULTAMIENTO ANIMADO DEL NAVBAR Y DEL FAB CUANDO SE ABRE EL MAPA
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final AnimationController _homeElementsController;
  late final Animation<Offset> _slideDownAnimation;
  late final Animation<Offset> _fabSlideAnimation;
  ScrollPhysics _pagePhysics = const AlwaysScrollableScrollPhysics();

  late final List<Widget> _widgetOptions = <Widget>[
    FeedScreen(
      onMapToggle: (isMapOpen) {
        if (mounted) {
          setState(() {
            _pagePhysics = isMapOpen
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics();
          });
        }
        if (isMapOpen) {
          _homeElementsController.forward();
        } else {
          _homeElementsController.reverse();
        }
      },
    ),
    const MyMatchesScreen(),
    const MiCuentaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _homeElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideDownAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.2)).animate(
          CurvedAnimation(
            parent: _homeElementsController,
            curve: Curves.easeInOut,
          ),
        );

    _fabSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 6.0)).animate(
          CurvedAnimation(
            parent: _homeElementsController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _homeElementsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if ((index - _selectedIndex).abs() != 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildNavItem(String assetPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected
        ? AppTheme.accentLimeColor
        : const Color(0xFF7E8A83);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  letterSpacing: 0.4,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchesBloc, MatchesState>(
      listenWhen: (prev, curr) =>
          prev.matchError != curr.matchError ||
          prev.mensajeExito != curr.mensajeExito,
      listener: (context, state) {
        if (state.matchError != null) {
          AppTheme.showDarkDialog(
            context: context,
            title: state.matchError!.dialogTitle,
            content: state.matchError!.dialogText,
            icon: Icons.error_outline_rounded,
            iconColor: AppTheme.accentLimeColor,
          );
        } else if (state.mensajeExito != null) {
          AppTheme.showSnackBar(context, state.mensajeExito!);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            // PageView navegable deslizando horizontalmente (Clash Royale style)
            PageView(
              physics: _pagePhysics,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: _widgetOptions,
            ),

            // FAB Flotante Circular Neón (+) con animación de salida hacia abajo
            if (_selectedIndex == 0)
              Positioned(
                bottom: 88,
                right: 22,
                child: SlideTransition(
                  position: _fabSlideAnimation,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateMatchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.accentLimeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentLimeColor.withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
              ),

            // Navbar Flotante Dark Glass despegado del borde inferior
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideDownAnimation,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF141A17,
                            ).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavItem(
                                'assets/images/icons/Home.svg',
                                'Home',
                                0,
                              ),
                              _buildNavItem(
                                'assets/images/icons/cup.svg',
                                'Mis partidos',
                                1,
                              ),
                              _buildNavItem(
                                'assets/images/icons/user.svg',
                                'Cuenta',
                                2,
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
