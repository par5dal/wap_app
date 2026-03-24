// lib/core/theme/transitions/fade_page_transition.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transición de página con efecto fade
class FadePageTransition extends CustomTransitionPage {
  FadePageTransition({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
         },
       );
}
