// lib/features/promoter_profile/presentation/pages/promoter_profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/home/data/datasources/location_data_source.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/presentation/widgets/event_list_card.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';
import 'package:wap_app/features/promoter_profile/domain/usecases/get_promoter_events.dart';
import 'package:wap_app/features/promoter_profile/domain/usecases/get_promoter_profile.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/features/user_actions/domain/usecases/block_user.dart';
import 'package:wap_app/features/user_actions/domain/usecases/unblock_user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wap_app/shared/widgets/custom_button.dart';
import 'package:wap_app/shared/widgets/follow_button.dart';
import 'package:wap_app/shared/widgets/report_dialog.dart';

class PromoterProfilePage extends StatefulWidget {
  final String promoterId;

  const PromoterProfilePage({super.key, required this.promoterId});

  @override
  State<PromoterProfilePage> createState() => _PromoterProfilePageState();
}

class _PromoterProfilePageState extends State<PromoterProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoadingEvents = true;
  PromoterProfile? _profile;
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  String? _errorMessage;

  late TabController _tabController;

  // GlobalKey para obtener la posición del botón compartir (iOS requiere sharePositionOrigin)
  final _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadEvents()]);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getProfile = di.sl<GetPromoterProfileUseCase>();
      final result = await getProfile(widget.promoterId);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (profile) {
          setState(() {
            _profile = profile;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el perfil';
      });
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);

    try {
      final locationDataSource = di.sl<LocationDataSource>();
      Position? userPosition;
      try {
        userPosition = await locationDataSource.getCurrentPosition();
      } catch (e) {
        userPosition = null;
      }

      final getEvents = di.sl<GetPromoterEventsUseCase>();
      final result = await getEvents(
        promoterId: widget.promoterId,
        limit: 50,
        userLatitude: userPosition?.latitude,
        userLongitude: userPosition?.longitude,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() => _isLoadingEvents = false);
        },
        (events) {
          final upcoming = <Event>[];
          final past = <Event>[];

          for (final event in events) {
            final isFinished = event.status == 'FINISHED';
            if (isFinished) {
              past.add(event);
            } else {
              upcoming.add(event);
            }
          }

          // Próximos: distancia ASC (si la hay), luego fecha ASC
          upcoming.sort((a, b) {
            final aDist = a.distance;
            final bDist = b.distance;
            if (aDist != null && bDist != null) {
              final cmp = aDist.compareTo(bDist);
              if (cmp != 0) return cmp;
            } else if (aDist != null) {
              return -1;
            } else if (bDist != null) {
              return 1;
            }
            return a.startDate.compareTo(b.startDate);
          });
          // Pasados: distancia ASC (si la hay), luego fecha DESC (más recientes primero)
          past.sort((a, b) {
            final aDist = a.distance;
            final bDist = b.distance;
            if (aDist != null && bDist != null) {
              final cmp = aDist.compareTo(bDist);
              if (cmp != 0) return cmp;
            } else if (aDist != null) {
              return -1;
            } else if (bDist != null) {
              return 1;
            }
            return b.startDate.compareTo(a.startDate);
          });

          setState(() {
            _upcomingEvents = upcoming;
            _pastEvents = past;
            _isLoadingEvents = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _onShare() async {
    final promoterId = widget.promoterId;
    final url = 'https://www.whataplan.net/es/promotores/$promoterId';
    final name = _profile?.fullName ?? '';
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await Share.share(
      name.isNotEmpty ? '¡Mira este promotor en WAP! - $name\n$url' : url,
      subject: name,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleBlock(BuildContext context, bool block) async {
    final messenger = ScaffoldMessenger.of(context);
    if (block) {
      final result = await di.sl<BlockUserUseCase>()(widget.promoterId);
      if (!mounted) return;
      result.fold(
        (failure) =>
            messenger.showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          di.sl<BlockedUsersService>().addBlocked(widget.promoterId);
          messenger.showSnackBar(
            const SnackBar(content: Text('Usuario bloqueado')),
          );
        },
      );
    } else {
      final result = await di.sl<UnblockUserUseCase>()(widget.promoterId);
      if (!mounted) return;
      result.fold(
        (failure) =>
            messenger.showSnackBar(SnackBar(content: Text(failure.message))),
        (_) {
          di.sl<BlockedUsersService>().removeBlocked(widget.promoterId);
          messenger.showSnackBar(
            const SnackBar(content: Text('Usuario desbloqueado')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: context.colorScheme.surface),
        backgroundColor: context.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: context.colorScheme.surface),
        backgroundColor: context.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: context.textTheme.titleMedium),
              const SizedBox(height: 24),
              CustomButton(text: t.retry, onPressed: _loadData),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: context.colorScheme.surface),
        backgroundColor: context.colorScheme.surface,
        body: Center(
          child: Text(
            'Promotor no encontrado',
            style: context.textTheme.titleMedium,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: context.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (di.sl<AppBloc>().state.status == AuthStatus.authenticated)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'report') {
                      final messenger = ScaffoldMessenger.of(context);
                      final sent = await showReportDialog(
                        context,
                        reportedUserId: widget.promoterId,
                      );
                      if (sent == true && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte enviado. Gracias por ayudarnos a mejorar.',
                            ),
                          ),
                        );
                      }
                    } else if (value == 'block' || value == 'unblock') {
                      await _toggleBlock(context, value == 'block');
                    }
                  },
                  itemBuilder: (_) {
                    final isBlocked = di.sl<BlockedUsersService>().isBlocked(
                      widget.promoterId,
                    );
                    return [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined),
                            SizedBox(width: 8),
                            Text('Reportar usuario'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: isBlocked ? 'unblock' : 'block',
                        child: Row(
                          children: [
                            Icon(
                              isBlocked
                                  ? Icons.lock_open_outlined
                                  : Icons.block,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBlocked
                                  ? 'Desbloquear usuario'
                                  : 'Bloquear usuario',
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),

          // Header del promotor
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: context.colorScheme.surface,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: context.colorScheme.primary,
                    backgroundImage: _profile!.avatarUrl != null
                        ? CachedNetworkImageProvider(_profile!.avatarUrl!)
                        : null,
                    child: _profile!.avatarUrl == null
                        ? Icon(
                            Icons.business,
                            size: 48,
                            color: context.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _profile!.fullName,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // UbicaciÃ³n
                if (_profile!.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: context.colorScheme.onSurface.withAlpha(179),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _profile!.location!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(
                      context,
                      t.promoterProfileEvents,
                      _profile!.eventsCount.toString(),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: context.colorScheme.onSurface.withAlpha(51),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _buildStat(
                      context,
                      t.promoterProfileFollowers,
                      _profile!.followersCount.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón compartir + seguir
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        key: _shareButtonKey,
                        onPressed: _onShare,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.share_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FollowButton(
                          promoterId: _profile!.id,
                          initialIsFollowing: _profile!.isFollowing,
                          onToggled: _loadProfile,
                        ),
                      ),
                    ],
                  ),
                ),

                // BiografÃ­a
                if (_profile!.bio != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _profile!.bio!,
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // Website
                if (_profile!.websiteUrl != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _launchUrl(_profile!.websiteUrl!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.link,
                          size: 18,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _profile!.websiteUrl!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(height: 1),
              ],
            ),
          ),

          // TabBar fija
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.lightPrimary,
                unselectedLabelColor: context.colorScheme.onSurface.withAlpha(
                  128,
                ),
                indicatorColor: AppColors.lightPrimary,
                tabs: [
                  Tab(text: t.promoterProfileUpcoming),
                  Tab(text: t.promoterProfilePast),
                ],
              ),
              backgroundColor: context.colorScheme.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab: PrÃ³ximos
            _buildEventsList(_upcomingEvents, t.promoterProfileNoEvents),
            // Tab: Pasados
            _buildEventsList(_pastEvents, t.promoterProfileNoEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, String emptyMessage) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: events.length,
      itemBuilder: (context, index) => EventListCard(event: events[index]),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }
}

// Delegate para mantener el TabBar sticky
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  const _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
