// lib/shared/widgets/report_dialog.dart

import 'package:flutter/material.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/reports/domain/usecases/create_report.dart';

/// Diálogo para reportar un evento o un usuario.
/// Exactamente uno de [eventId] o [reportedUserId] debe ser no-nulo.
class ReportDialog extends StatefulWidget {
  final String? eventId;
  final String? reportedUserId;

  const ReportDialog({super.key, this.eventId, this.reportedUserId})
    : assert(
        eventId != null || reportedUserId != null,
        'Either eventId or reportedUserId must be provided',
      );

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  static const _reasons = [
    ('SPAM', 'Spam o contenido no deseado'),
    ('INAPPROPRIATE', 'Contenido inapropiado'),
    ('MISLEADING', 'Información falsa o engañosa'),
    ('HARASSMENT', 'Acoso o comportamiento abusivo'),
    ('OTHER', 'Otro motivo'),
  ];

  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      setState(() => _error = 'Por favor selecciona un motivo');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await di.sl<CreateReportUseCase>()(
      CreateReportParams(
        eventId: widget.eventId,
        reportedUserId: widget.reportedUserId,
        reason: _selectedReason!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _submitting = false;
        _error = failure.message;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEvent = widget.eventId != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withAlpha(64),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEvent ? 'Reportar evento' : 'Reportar usuario',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona el motivo del reporte',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (v) => setState(() => _selectedReason = v),
            child: Column(
              children: _reasons
                  .map(
                    (r) => ListTile(
                      leading: Radio<String>(value: r.$1),
                      title: Text(r.$2),
                      onTap: () => setState(() => _selectedReason = r.$1),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Descripción adicional (opcional)',
              border: const OutlineInputBorder(),
              counterText: '',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: context.colorScheme.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar reporte'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

/// Muestra el diálogo de reporte como un bottom sheet modal.
/// Devuelve [true] si el reporte fue enviado exitosamente.
Future<bool?> showReportDialog(
  BuildContext context, {
  String? eventId,
  String? reportedUserId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        ReportDialog(eventId: eventId, reportedUserId: reportedUserId),
  );
}
