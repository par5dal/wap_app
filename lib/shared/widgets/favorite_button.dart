// lib/shared/widgets/favorite_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/services/analytics_service.dart';
import 'package:wap_app/features/user_actions/domain/usecases/add_event_to_favorites.dart';
import 'package:wap_app/features/user_actions/domain/usecases/remove_event_from_favorites.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/shared/widgets/auth_required_dialog.dart';

class FavoriteButton extends StatefulWidget {
  final String eventId;
  final bool initialIsFavorite;
  final String? eventName;
  final VoidCallback? onToggled;
  final bool showLabel;

  const FavoriteButton({
    super.key,
    required this.eventId,
    required this.initialIsFavorite,
    this.eventName,
    this.onToggled,
    this.showLabel = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite) {
      setState(() {
        _isFavorite = widget.initialIsFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    // Verificar autenticación
    final appState = context.read<AppBloc>().state;
    if (appState.status != AuthStatus.authenticated) {
      await showDialog<void>(
        context: context,
        builder: (context) => const AuthRequiredDialog(),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        final removeFromFavorites = di.sl<RemoveEventFromFavoritesUseCase>();
        final result = await removeFromFavorites(widget.eventId);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              );
            }
          },
          (_) {
            setState(() => _isFavorite = false);
            widget.onToggled?.call();
            di.sl<AnalyticsService>().logFavoriteEvent(
              eventId: widget.eventId.toString(),
              eventName: widget.eventName ?? widget.eventId.toString(),
              added: false,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.favoriteRemovedMessage,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      } else {
        final addToFavorites = di.sl<AddEventToFavoritesUseCase>();
        final result = await addToFavorites(widget.eventId);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              );
            }
          },
          (_) {
            setState(() => _isFavorite = true);
            widget.onToggled?.call();
            di.sl<AnalyticsService>().logFavoriteEvent(
              eventId: widget.eventId.toString(),
              eventName: widget.eventName ?? widget.eventId.toString(),
              added: true,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.favoriteAddedMessage,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLabel) {
      // Versión con texto para páginas de detalle
      return ElevatedButton.icon(
        onPressed: _isLoading ? null : _toggleFavorite,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: _isFavorite ? Colors.orange : null,
              ),
        label: Text(
          _isFavorite
              ? AppLocalizations.of(context)!.favoriteSaved
              : AppLocalizations.of(context)!.eventDetailSave,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFavorite ? Colors.orange.shade50 : null,
          foregroundColor: _isFavorite ? Colors.orange : null,
        ),
      );
    } else {
      // Versión solo icono para tarjetas de eventos
      return IconButton(
        onPressed: _isLoading ? null : _toggleFavorite,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: _isFavorite ? Colors.orange : null,
                size: 24,
              ),
        tooltip: _isFavorite
            ? AppLocalizations.of(context)!.favoriteRemoveFromFavorites
            : AppLocalizations.of(context)!.favoriteAddToFavorites,
      );
    }
  }
}
