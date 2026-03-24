// lib/shared/widgets/error_message.dart

import 'package:flutter/material.dart';
import 'package:wap_app/core/error/failures.dart';

class ErrorMessage extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorMessage({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForFailure(failure),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              failure.userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return Icons.wifi_off;
    } else if (failure is ServerFailure) {
      return Icons.cloud_off;
    } else if (failure is AuthenticationFailure) {
      return Icons.lock;
    } else if (failure is LocationFailure) {
      return Icons.location_off;
    }
    return Icons.error_outline;
  }
}
