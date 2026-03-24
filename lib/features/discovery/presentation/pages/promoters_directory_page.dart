// lib/features/discovery/presentation/pages/promoters_directory_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:wap_app/features/discovery/data/models/promoter_model.dart';
import 'package:wap_app/features/promoter_profile/presentation/pages/promoter_profile_page.dart';
import 'package:wap_app/shared/widgets/custom_app_bar.dart';

class PromotersDirectoryPage extends StatefulWidget {
  const PromotersDirectoryPage({super.key});

  @override
  State<PromotersDirectoryPage> createState() => _PromotersDirectoryPageState();
}

class _PromotersDirectoryPageState extends State<PromotersDirectoryPage> {
  final DiscoveryRemoteDataSource _dataSource = DiscoveryRemoteDataSourceImpl(
    dio: sl<Dio>(),
  );
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PromoterModel> promoters = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSearching = false;
  bool hasMore = true;
  int currentPage = 1;
  String? error;
  String? currentSearch;

  @override
  void initState() {
    super.initState();
    _loadPromoters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePromoters();
    }
  }

  Future<void> _loadPromoters({String? search, bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        promoters.clear();
        currentPage = 1;
        hasMore = true;
        error = null;
      });
    }

    setState(() {
      isLoading = currentPage == 1;
      isSearching = search != null && currentPage == 1;
      error = null;
      currentSearch = search;
    });

    try {
      final response = await _dataSource.getPromoters(
        page: currentPage,
        limit: 20,
        search: search,
      );

      setState(() {
        if (currentPage == 1) {
          promoters = response.data;
        } else {
          promoters.addAll(response.data);
        }
        hasMore = response.meta.page < response.meta.totalPages;
        currentPage++;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar los promotores';
      });
    } finally {
      setState(() {
        isLoading = false;
        isSearching = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePromoters() async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      final response = await _dataSource.getPromoters(
        page: currentPage,
        limit: 20,
        search: currentSearch,
      );

      setState(() {
        promoters.addAll(response.data);
        hasMore = response.meta.page < response.meta.totalPages;
        currentPage++;
      });
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Error al cargar más promotores');
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      currentPage = 1;
    });

    if (value.isEmpty) {
      _loadPromoters(isRefresh: true);
    } else if (value.length >= 2) {
      _loadPromoters(search: value, isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.promotersTitle,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: context.l10n.promotersSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPromoters(isRefresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.colorScheme.surface,
              ),
            ),
          ),

          // Contenido
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPromoters(isRefresh: true),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (promoters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: context.colorScheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.promotersEmpty,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPromoters(search: currentSearch, isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: promoters.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == promoters.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final promoter = promoters[index];
          return _PromoterCard(
            promoter: promoter,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PromoterProfilePage(promoterId: promoter.id.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PromoterCard extends StatelessWidget {
  final PromoterModel promoter;
  final VoidCallback onTap;

  const _PromoterCard({required this.promoter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Obtener el nombre para mostrar
    final displayName = promoter.displayName.trim().isNotEmpty
        ? promoter.displayName
        : '${promoter.profile.firstName ?? ''} ${promoter.profile.lastName ?? ''}'
              .trim();
    final nameToShow = displayName.isNotEmpty ? displayName : promoter.email;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colorScheme.primary.withAlpha(51),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: promoter.profile.avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: promoter.profile.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: context.colorScheme.surface,
                                child: const Icon(Icons.business),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: context.colorScheme.surface,
                                child: const Icon(Icons.business),
                              ),
                            )
                          : Container(
                              color: context.colorScheme.primary.withAlpha(25),
                              child: Icon(
                                Icons.business,
                                color: context.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nombre
                  Expanded(
                    child: Text(
                      nameToShow,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Indicador de flecha
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: context.colorScheme.onSurface.withAlpha(153),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estadísticas centradas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(
                    icon: Icons.people_outline,
                    label: '${promoter.followersCount}',
                    subtitle: 'Seguidores',
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.event_outlined,
                    label: '${promoter.eventsCount}',
                    subtitle: context.l10n.promotersStatPlans,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            subtitle,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}
