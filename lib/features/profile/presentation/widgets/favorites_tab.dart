// lib/features/profile/presentation/widgets/favorites_tab.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/data/datasources/location_data_source.dart';
import 'package:wap_app/features/user_actions/domain/usecases/remove_event_from_favorites.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/features/home/presentation/widgets/event_list_card.dart';
import 'package:wap_app/features/event_detail/presentation/pages/event_detail_page.dart';
import 'package:dio/dio.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<Event>? _favorites;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = sl<Dio>();
      final response = await dio.get('/events/favorites');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data ?? [];

        Position? userPosition;
        try {
          final locationDataSource = sl<LocationDataSource>();
          userPosition = await locationDataSource.getCurrentPosition();
        } catch (e) {
          userPosition = null;
        }

        if (!mounted) return;
        setState(() {
          if (data is List) {
            _favorites = data.map((json) {
              final model = EventModel.fromJson(json);
              double? distanceInKm;
              if (userPosition != null) {
                final distanceInMeters = Geolocator.distanceBetween(
                  userPosition.latitude,
                  userPosition.longitude,
                  model.venue.location.latitude,
                  model.venue.location.longitude,
                );
                distanceInKm = distanceInMeters / 1000;
              }
              return model.toEntity(calculatedDistance: distanceInKm);
            }).toList();
          } else {
            _favorites = [];
          }
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        final errorMsg = context.l10n.favoritesError;
        setState(() {
          _error = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException &&
          (e.response?.statusCode == 200 || e.response?.statusCode == 304)) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
      } else if (e is DioException && e.response != null) {
        setState(() {
          _error = 'Error del servidor: ${e.response?.statusCode}';
          _isLoading = false;
        });
      } else {
        final errorMsg = context.l10n.serverConnectionError;
        setState(() {
          _error = errorMsg;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromFavorites(Event event) async {
    try {
      final removeFromFavorites = sl<RemoveEventFromFavoritesUseCase>();
      final result = await removeFromFavorites(event.id);

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
          setState(() {
            _favorites?.remove(event);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.favoriteRemovedMessage),
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
    final t = context.l10n;

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
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightSecondary,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_favorites == null || _favorites!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              t.profileNoFavorites,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final upcoming = _favorites!
        .where((e) => e.status != 'FINISHED' && !e.startDate.isBefore(now))
        .toList();
    final past = _favorites!
        .where((e) => e.status == 'FINISHED' || e.startDate.isBefore(now))
        .toList();

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.lightPrimary,
      child: ListView(
        children: [
          // SecciÃ³n PrÃ³ximos
          _buildSection(
            title: t.favoritesUpcoming,
            events: upcoming,
            emptyMessage: t.favoritesNoUpcoming,
            icon: Icons.upcoming,
            initiallyExpanded: true,
          ),

          // SecciÃ³n Pasados
          _buildSection(
            title: t.favoritesPast,
            events: past,
            emptyMessage: t.favoritesNoPast,
            icon: Icons.history,
            initiallyExpanded: past.isNotEmpty && upcoming.isEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Event> events,
    required String emptyMessage,
    required IconData icon,
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
                events.length.toString(),
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
        children: events.isEmpty
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
            : events
                  .map(
                    (event) => Dismissible(
                      key: Key(event.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              context.l10n.favoritesDeleteLabel,
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
                            title: Text(context.l10n.favoritesDeleteTitle),
                            content: Text(context.l10n.favoritesDeleteConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(context.l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  context.l10n.favoritesDeleteLabel,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => _removeFromFavorites(event),
                      child: EventListCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(event: event),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
      ),
    );
  }
}
