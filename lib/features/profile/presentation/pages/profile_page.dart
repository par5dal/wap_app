// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wap_app/features/profile/presentation/widgets/profile_data_tab.dart';
import 'package:wap_app/features/profile/presentation/widgets/favorites_tab.dart';
import 'package:wap_app/features/profile/presentation/widgets/promoters_tab.dart';
import 'package:wap_app/shared/widgets/loading_overlay.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<NotificationsBloc>()..add(const RefreshUnreadCount()),
      child: BlocProvider.value(
        value: () {
          final profileBloc = sl<ProfileBloc>();
          if (profileBloc.state is! ProfileLoaded &&
              profileBloc.state is! ProfileUpdating &&
              profileBloc.state is! ProfileUploadingAvatar) {
            profileBloc.add(ProfileLoadRequested());
          }
          return profileBloc;
        }(),
        child: const _ProfilePageContent(),
      ),
    );
  }
}

class _ProfilePageContent extends StatefulWidget {
  const _ProfilePageContent();

  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) {
        // Fallo en la carga inicial (ProfileLoading → ProfileError)
        if (previous is ProfileLoading && current is ProfileError) return true;
        // Fallo o éxito tras una actualización
        return (previous is ProfileUpdating ||
                previous is ProfileUploadingAvatar) &&
            (current is ProfileLoaded || current is ProfileError);
      },
      listener: (context, state) {
        if (state is ProfileError) {
          if (state.lastKnownProfile == null) {
            // Error en la carga inicial: credenciales inválidas / cuenta eliminada.
            // Navegamos al mapa y dejamos que el router haga el resto si procede.
            context.showErrorSnackBar(state.message);
            GoRouter.of(context).go('/${AppRoute.home.name}');
          } else {
            context.showErrorSnackBar(state.message);
          }
        } else if (state is ProfileLoaded) {
          context.showSuccessSnackBar(context.l10n.profileUpdateSuccess);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Scaffold(
            body: LoadingOverlay(isLoading: true, child: Container()),
          );
        }

        if (state is ProfileError && state.lastKnownProfile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.profileTitle)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(ProfileLoadRequested()),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final UserWithProfileEntity? userProfile;

        if (state is ProfileLoaded) {
          userProfile = state.userProfile;
        } else if (state is ProfileUpdating) {
          userProfile = state.currentProfile;
        } else if (state is ProfileUploadingAvatar) {
          userProfile = state.currentProfile;
        } else if (state is ProfileError && state.lastKnownProfile != null) {
          userProfile = state.lastKnownProfile;
        } else {
          userProfile = null;
        }

        final profile = userProfile?.profile;
        final isLoading =
            state is ProfileUpdating || state is ProfileUploadingAvatar;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.profileTitle),
            actions: [
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, notifState) {
                  final unread = notifState.unreadCount;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () =>
                            context.pushNamed(AppRoute.notifications.name),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: context.l10n.profileTabProfile),
                Tab(text: context.l10n.profileTabFavorites),
                Tab(text: context.l10n.profileTabFollowing),
              ],
              labelColor: AppColors.lightPrimary,
              indicatorColor: AppColors.lightPrimary,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ProfileDataTab(
                profile: profile,
                isLoading: isLoading,
                email: userProfile?.email,
              ),
              const FavoritesTab(),
              const PromotersTab(),
            ],
          ),
        );
      },
    );
  }
}
