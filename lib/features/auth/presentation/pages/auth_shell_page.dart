// lib/presentation/pages/auth_shell_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Este es un widget "plantilla" o "shell". Su única misión es mostrar
// la página hija que GoRouter le pase.
class AuthShellPage extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const AuthShellPage({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Simplemente devuelve el hijo. La magia del BlocProvider ocurrirá en GoRouter.
    return child;
  }
}