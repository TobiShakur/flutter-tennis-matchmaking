import 'package:flutter/material.dart';

/// Transición de página personalizada "Smoke / Frosted Reveal":
/// Desliza suavemente desde abajo, con opacidad progresiva y difuminado tipo humo.
class SmokePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmokePageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.22),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
}
