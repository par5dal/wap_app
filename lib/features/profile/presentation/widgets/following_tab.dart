// lib/features/profile/presentation/widgets/following_tab.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';
import 'package:wap_app/features/profile/domain/usecases/get_followed_promoters.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unfollow_promoter.dart';
import 'package:wap_app/features/promoter_profile/presentation/pages/promoter_profile_page.dart';

class FollowingTab extends StatefulWidget {
  const FollowingTab({super.key});

  @override
  State<FollowingTab> createState() => _FollowingTabState();
}

class _FollowingTabState extends State<FollowingTab> {
  List<FollowedPromoter>? _following;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final getFollowedPromoters = sl<GetFollowedPromotersUseCase>();
      final result = await getFollowedPromoters();

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (promoters) {
          setState(() {
            _following = promoters;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      // Extraer el valor del contexto ANTES del setState para evitar
      // la race condition donde context se anula entre el mounted check y el acceso.
      final errorMsg = context.l10n.serverConnectionError;
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUnfollow(String promoterId) async {
    try {
      final unfollowPromoter = sl<UnfollowPromoterUseCase>();
      final result = await unfollowPromoter(promoterId);

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          // Recargar la lista después de dejar de seguir
          _loadFollowing();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.followingRemovedMessage),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.lightPrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFollowing,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightSecondary,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_following == null || _following!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              context.l10n.profileNoFollowing,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowing,
      color: AppColors.lightPrimary,
      child: ListView.builder(
        itemCount: _following!.length,
        itemBuilder: (context, index) {
          final promoter = _following![index];
          return _buildPromoterCard(promoter);
        },
      ),
    );
  }

  Widget _buildPromoterCard(FollowedPromoter promoter) {
    return Dismissible(
      key: Key(promoter.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_remove, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Dejar de\nseguir',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.followingDialogTitle),
            content: Text(context.l10n.followingDialogBody(promoter.fullName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  context.l10n.followingUnfollowSwipeLabel,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _toggleUnfollow(promoter.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.lightPrimary.withAlpha(51),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PromoterProfilePage(promoterId: promoter.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.lightPrimary.withAlpha(25),
                    backgroundImage: promoter.avatarUrl != null
                        ? CachedNetworkImageProvider(promoter.avatarUrl!)
                        : null,
                    child: promoter.avatarUrl == null
                        ? const Icon(
                            Icons.business,
                            size: 30,
                            color: AppColors.lightPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Nombre
                  Expanded(
                    child: Text(
                      promoter.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Flecha
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
