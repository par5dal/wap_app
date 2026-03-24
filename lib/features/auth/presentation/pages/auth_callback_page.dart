// lib/features/auth/presentation/pages/auth_callback_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/features/auth/presentation/bloc/auth_bloc.dart';

/// Página de redirección que recibe los tokens de Supabase después del OAuth
/// y los despacha al [AuthBloc] para completar el flujo de autenticación.
class AuthCallbackPage extends StatefulWidget {
  final String supabaseAccessToken;
  final String supabaseRefreshToken;

  /// 'google' (por defecto) o 'apple'
  final String provider;

  const AuthCallbackPage({
    super.key,
    required this.supabaseAccessToken,
    required this.supabaseRefreshToken,
    this.provider = 'google',
  });

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.supabaseAccessToken.isEmpty ||
          widget.supabaseRefreshToken.isEmpty) {
        // Tokens no recibidos: volver a auth sin llamar a la API
        context.go('/auth');
        return;
      }
      if (widget.provider == 'apple') {
        context.read<AuthBloc>().add(
          AppleCallbackReceived(
            supabaseAccessToken: widget.supabaseAccessToken,
            supabaseRefreshToken: widget.supabaseRefreshToken,
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          GoogleCallbackReceived(
            supabaseAccessToken: widget.supabaseAccessToken,
            supabaseRefreshToken: widget.supabaseRefreshToken,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFormSuccess ||
            state is AuthFormSuccessNewUser ||
            state is AuthFormSuccessProfileIncomplete) {
          context.go('/home');
        } else if (state is AuthFormFailure) {
          context.go('/auth');
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
