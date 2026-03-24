// lib/features/profile/presentation/widgets/promoters_tab.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';
import 'package:wap_app/features/profile/domain/usecases/get_followed_promoters.dart';
import 'package:wap_app/features/profile/domain/usecases/get_blocked_promoters.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unfollow_promoter.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unblock_user.dart';
import 'package:wap_app/features/promoter_profile/presentation/pages/promoter_profile_page.dart';

class PromotersTab extends StatefulWidget {
  const PromotersTab({super.key});

  @override
  State<PromotersTab> createState() => _PromotersTabState();
}

class _PromotersTabState extends State<PromotersTab> {
  List<FollowedPromoter>? _following;
  List<BlockedPromoter>? _blocked;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final followingResult = await sl<GetFollowedPromotersUseCase>()();
      final blockedResult = await sl<GetBlockedPromotersUseCase>()();

      if (!mounted) return;

      String? error;
      List<FollowedPromoter>? following;
      List<BlockedPromoter>? blocked;

      followingResult.fold(
        (failure) => error = failure.message,
        (promoters) => following = promoters,
      );
      blockedResult.fold(
        (failure) => error ??= failure.message,
        (promoters) => blocked = promoters,
      );

      setState(() {
        _error = error;
        _following = following;
        _blocked = blocked;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = context.l10n.serverConnectionError;
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _unfollow(String promoterId) async {
    try {
      final result = await sl<UnfollowPromoterUseCase>()(promoterId);
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
          _loadData();
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

  Future<void> _unblock(String userId) async {
    try {
      final result = await sl<UnblockUserUseCase>()(userId);
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
          sl<BlockedUsersService>().removeBlocked(userId);
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.profileUnblockLabel),
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
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightSecondary,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    final hasFollowing = _following != null && _following!.isNotEmpty;
    final hasBlocked = _blocked != null && _blocked!.isNotEmpty;

    if (!hasFollowing && !hasBlocked) {
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
      onRefresh: _loadData,
      color: AppColors.lightPrimary,
      child: ListView(
        children: [
          _buildSection<FollowedPromoter>(
            title: context.l10n.profilePromotersSectionFollowing,
            items: _following ?? [],
            emptyMessage: context.l10n.profileNoFollowing,
            icon: Icons.people,
            itemBuilder: _buildFollowingCard,
            initiallyExpanded: true,
          ),
          _buildSection<BlockedPromoter>(
            title: context.l10n.profilePromotersSectionBlocked,
            items: _blocked ?? [],
            emptyMessage: context.l10n.profileNoBlocked,
            icon: Icons.block,
            itemBuilder: _buildBlockedCard,
            initiallyExpanded: hasBlocked && !hasFollowing,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required String emptyMessage,
    required IconData icon,
    required Widget Function(T) itemBuilder,
    bool initiallyExpanded = true,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: AppColors.lightPrimary),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                items.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ),
        collapsedIconColor: AppColors.lightPrimary,
        iconColor: AppColors.lightPrimary,
        children: items.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),
              ]
            : items.map(itemBuilder).toList(),
      ),
    );
  }

  Widget _buildFollowingCard(FollowedPromoter promoter) {
    return Dismissible(
      key: Key('following_${promoter.id}'),
      direction: DismissDirection.endToStart,
      background: _dismissBackground(Icons.person_remove, 'Dejar de\nseguir'),
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
      onDismissed: (_) => _unfollow(promoter.id),
      child: _buildPromoterTile(
        id: promoter.id,
        name: promoter.fullName,
        avatarUrl: promoter.avatarUrl,
      ),
    );
  }

  Widget _buildBlockedCard(BlockedPromoter promoter) {
    return Dismissible(
      key: Key('blocked_${promoter.id}'),
      direction: DismissDirection.endToStart,
      background: _dismissBackground(
        Icons.lock_open,
        context.l10n.profileUnblockLabel,
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.profileUnblockDialogTitle),
            content: Text(
              context.l10n.profileUnblockDialogBody(promoter.fullName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  context.l10n.profileUnblockLabel,
                  style: const TextStyle(color: AppColors.lightPrimary),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _unblock(promoter.id),
      child: _buildPromoterTile(
        id: promoter.id,
        name: promoter.fullName,
        avatarUrl: promoter.avatarUrl,
      ),
    );
  }

  Widget _dismissBackground(IconData icon, String label) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoterTile({
    required String id,
    required String name,
    String? avatarUrl,
  }) {
    return Container(
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
                builder: (context) => PromoterProfilePage(promoterId: id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.lightPrimary.withAlpha(25),
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.business,
                          size: 30,
                          color: AppColors.lightPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
    );
  }
}
