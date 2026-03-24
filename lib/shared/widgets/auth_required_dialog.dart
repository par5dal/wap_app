// lib/shared/widgets/auth_required_dialog.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/l10n/app_localizations.dart';

class AuthRequiredDialog extends StatelessWidget {
  const AuthRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(t.authDialogTitle),
      content: Text(t.authDialogDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/auth');
          },
          child: Text(t.authDialogLogin),
        ),
      ],
    );
  }
}
