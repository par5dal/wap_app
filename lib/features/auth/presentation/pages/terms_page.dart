// lib/features/auth/presentation/pages/terms_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/usecases/accept_terms.dart';
import 'package:wap_app/features/auth/domain/usecases/get_legal_document.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  LegalDocument? _termsDocument;
  bool _loadingDocument = true;
  bool _accepting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Se usa addPostFrameCallback para diferir el acceso a Localizations hasta
    // que el árbol de widgets esté completamente montado (initState no permite
    // acceder a inherited widgets como Localizations).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchTermsDocument();
    });
  }

  Future<void> _fetchTermsDocument() async {
    setState(() {
      _loadingDocument = true;
      _error = null;
    });

    // Obtener idioma del device
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;

    final result = await di.sl<GetLegalDocumentUseCase>()(
      type: 'terms',
      lang: lang,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loadingDocument = false;
        _error = failure.message;
      }),
      (document) => setState(() {
        _termsDocument = document;
        _loadingDocument = false;
      }),
    );
  }

  Future<void> _acceptTerms() async {
    if (_accepting || _termsDocument == null) return;

    setState(() => _accepting = true);

    final result = await di.sl<AcceptTermsUseCase>()(_termsDocument!.version);

    if (!mounted) return;

    await result.fold(
      (failure) async => setState(() {
        _accepting = false;
        _error = failure.message;
      }),
      (_) async {
        if (!mounted) return;
        di.sl<AppBloc>().add(
          const AppAuthStatusChanged(AuthStatus.authenticated),
        );
      },
    );
  }

  void _logout() {
    di.sl<AppBloc>().add(AppLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Términos y Condiciones',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, lee cuidadosamente antes de continuar',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withAlpha(153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(child: _buildContent(context)),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed:
                          (_loadingDocument ||
                              _accepting ||
                              _termsDocument == null)
                          ? null
                          : _acceptTerms,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _accepting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Acepto los Términos y Condiciones'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _logout,
                      child: Text(
                        'No acepto – Cerrar sesión',
                        style: TextStyle(
                          color: context.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loadingDocument) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los términos',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchTermsDocument,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_termsDocument == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final section in _termsDocument!.sections) ...[
          const SizedBox(height: 24),
          MarkdownBody(
            data: section.content,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
