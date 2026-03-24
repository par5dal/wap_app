// lib/shared/widgets/follow_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/features/user_actions/domain/usecases/follow_promoter.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unfollow_promoter.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/shared/widgets/auth_required_dialog.dart';

class FollowButton extends StatefulWidget {
  final String promoterId;
  final bool initialIsFollowing;
  final VoidCallback? onToggled; // Callback para actualizar estado padre

  const FollowButton({
    super.key,
    required this.promoterId,
    required this.initialIsFollowing,
    this.onToggled,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
  }

  @override
  void didUpdateWidget(FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFollowing != widget.initialIsFollowing) {
      setState(() {
        _isFollowing = widget.initialIsFollowing;
      });
    }
  }

  Future<void> _toggleFollow() async {
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
      if (_isFollowing) {
        final unfollowPromoter = di.sl<UnfollowPromoterUseCase>();
        final result = await unfollowPromoter(widget.promoterId);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              );
            }
          },
          (_) {
            setState(() => _isFollowing = false);
            widget.onToggled?.call();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.followingRemovedMessage,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      } else {
        final followPromoter = di.sl<FollowPromoterUseCase>();
        final result = await followPromoter(widget.promoterId);

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              );
            }
          },
          (_) {
            setState(() => _isFollowing = true);
            widget.onToggled?.call();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.followingAddedMessage,
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
    final t = AppLocalizations.of(context)!;

    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _toggleFollow,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
      label: Text(
        _isFollowing ? t.promoterProfileUnfollow : t.promoterProfileFollow,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing ? Colors.grey.shade100 : null,
        foregroundColor: _isFollowing ? Colors.grey.shade700 : null,
      ),
    );
  }
}
