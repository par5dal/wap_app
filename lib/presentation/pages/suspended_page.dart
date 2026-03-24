// lib/presentation/pages/suspended_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

class SuspendedPage extends StatelessWidget {
  const SuspendedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                final reason = state.suspendedReason;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.block,
                      size: 80,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cuenta suspendida',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tu cuenta ha sido suspendida temporalmente.',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withAlpha(179),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (reason != null && reason.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: context.colorScheme.onErrorContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const Spacer(),
                    FilledButton(
                      onPressed: () =>
                          context.read<AppBloc>().add(AppLogoutRequested()),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.colorScheme.error,
                        foregroundColor: context.colorScheme.onError,
                      ),
                      child: const Text('Cerrar sesión'),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
