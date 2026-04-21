// lib/features/home/presentation/widgets/map_toolbar.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wap_app/core/config/dependency_injection.dart';
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/theme/app_colors.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapToolbar extends StatelessWidget {
  final VoidCallback onListTap;
  final VoidCallback onLocationTap;

  const MapToolbar({
    super.key,
    required this.onListTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        sl<AppBloc>().state.status == AuthStatus.authenticated;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.lightPrimary.withAlpha(51),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Avatar del usuario (Perfil)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: isAuthenticated
                  ? _AuthenticatedAvatar()
                  : GestureDetector(
                      onTap: () => _showAuthDialog(context),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.lightPrimary,
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
            ),

            // Botón de Listado
            _ToolbarButton(
              icon: Icons.list,
              label: context.l10n.navBarList,
              onTap: onListTap,
            ),

            // Logo en el centro - clickeable para explorar
            GestureDetector(
              onTap: () => _showDiscoveryBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Botón de Ubicación
            _ToolbarButton(
              icon: Icons.my_location,
              label: context.l10n.navBarLocation,
              onTap: onLocationTap,
            ),

            // Botón de Ajustes
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _ToolbarButton(
                icon: Icons.settings,
                label: 'Ajustes',
                onTap: () => context.pushNamed(AppRoute.settings.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscoveryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20), // Reducido de 24 a 20
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16), // Reducido de 24 a 16
              // Título
              Text(
                context.l10n.toolbarDiscoverTitle,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4), // Reducido de 8 a 4
              Text(
                context.l10n.toolbarDiscoverSubtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 20), // Reducido de 32 a 20
              // Opciones
              _DiscoveryOption(
                icon: Icons.category,
                title: context.l10n.toolbarDiscoverCategories,
                subtitle: context.l10n.toolbarDiscoverCategoriesSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/categories');
                },
              ),
              const SizedBox(height: 12), // Reducido de 16 a 12
              _DiscoveryOption(
                icon: Icons.business,
                title: context.l10n.toolbarDiscoverPromoters,
                subtitle: context.l10n.toolbarDiscoverPromotersSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/promoters');
                },
              ),
              const SizedBox(height: 12),
              _DiscoveryOption(
                icon: Icons.store_outlined,
                title: context.l10n.toolbarDiscoverPromoterAccess,
                subtitle: context.l10n.toolbarDiscoverPromoterAccessSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  final appState = sl<AppBloc>().state;
                  if (appState.status != AuthStatus.authenticated) {
                    context.push('/for-promoters');
                  } else {
                    final userRole = sl<SharedPreferences>().getString(
                      'user_role',
                    );
                    if (userRole == 'PROMOTER' || userRole == 'ADMIN') {
                      context.push('/promoter-dashboard');
                    } else {
                      context.push('/upgrade-to-promoter');
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AuthPromptDialog(),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  @override
  Widget build(BuildContext context) {
    final buttonColor = context.colorScheme.onSurface;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(widget.icon, color: buttonColor, size: 24),
      ),
    );
  }
}

// Diálogo para usuarios no autenticados
class _AuthPromptDialog extends StatelessWidget {
  const _AuthPromptDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 48,
                color: AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              context.l10n.authDialogTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción
            Text(
              context.l10n.authDialogDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Botón de Iniciar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(AppRoute.auth.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.authDialogLogin,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón de Registrarse
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(AppRoute.auth.name);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: AppColors.lightPrimary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.authDialogRegister,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separado para manejar el avatar de usuario autenticado
class _AuthenticatedAvatar extends StatefulWidget {
  const _AuthenticatedAvatar();

  @override
  State<_AuthenticatedAvatar> createState() => _AuthenticatedAvatarState();
}

class _AuthenticatedAvatarState extends State<_AuthenticatedAvatar> {
  StreamSubscription<AppState>? _appBlocSubscription;
  bool _hasLoadedProfile = false;

  @override
  void initState() {
    super.initState();

    // Cargar perfil al inicializar si ya estamos autenticados
    final appState = sl<AppBloc>().state;
    if (appState.status == AuthStatus.authenticated) {
      _loadProfileIfNeeded();
      sl<NotificationsBloc>().add(const RefreshUnreadCount());
    }

    // Escuchar cambios en el estado de autenticación
    _appBlocSubscription = sl<AppBloc>().stream.listen((appState) {
      if (appState.status == AuthStatus.authenticated && !_hasLoadedProfile) {
        // Usuario acaba de hacer login, cargar perfil
        _loadProfileIfNeeded();
        sl<NotificationsBloc>().add(const RefreshUnreadCount());
      } else if (appState.status == AuthStatus.unauthenticated) {
        // Usuario ha hecho logout, resetear flag
        _hasLoadedProfile = false;
      }
    });
  }

  void _loadProfileIfNeeded() {
    final profileBloc = sl<ProfileBloc>();
    // Solo cargar si no está ya cargado o si está en inicial
    if (profileBloc.state is ProfileInitial) {
      profileBloc.add(ProfileLoadRequested());
      _hasLoadedProfile = true;
    } else if (profileBloc.state is ProfileLoaded) {
      _hasLoadedProfile = true;
    }
  }

  @override
  void dispose() {
    _appBlocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = sl<ProfileBloc>();
    final notificationsBloc = sl<NotificationsBloc>();

    return StreamBuilder<ProfileState>(
      stream: profileBloc.stream,
      initialData: profileBloc.state,
      builder: (context, profileSnapshot) {
        final state = profileSnapshot.data;
        String? avatarUrl;
        String? firstName;
        String? lastName;

        // Extraer datos según el estado
        if (state is ProfileLoaded) {
          avatarUrl = state.userProfile.profile?.avatarUrl;
          firstName = state.userProfile.profile?.firstName;
          lastName = state.userProfile.profile?.lastName;
        } else if (state is ProfileUpdating) {
          avatarUrl = state.currentProfile.profile?.avatarUrl;
          firstName = state.currentProfile.profile?.firstName;
          lastName = state.currentProfile.profile?.lastName;
        } else if (state is ProfileUploadingAvatar) {
          avatarUrl = state.currentProfile.profile?.avatarUrl;
          firstName = state.currentProfile.profile?.firstName;
          lastName = state.currentProfile.profile?.lastName;
        } else if (state is ProfileError && state.lastKnownProfile != null) {
          avatarUrl = state.lastKnownProfile!.profile?.avatarUrl;
          firstName = state.lastKnownProfile!.profile?.firstName;
          lastName = state.lastKnownProfile!.profile?.lastName;
        }

        // Calcular iniciales
        String initials = '';
        if (firstName != null && firstName.isNotEmpty) {
          initials += firstName[0].toUpperCase();
        }
        if (lastName != null && lastName.isNotEmpty) {
          initials += lastName[0].toUpperCase();
        }

        final hasInitials = initials.isNotEmpty;

        final avatar = CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.lightPrimary,
          backgroundImage: avatarUrl != null
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: avatarUrl == null
              ? (hasInitials
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 24))
              : null,
        );

        return GestureDetector(
          onTap: () async {
            await context.pushNamed(AppRoute.profile.name);
            if (context.mounted) {
              profileBloc.add(ProfileLoadRequested());
            }
          },
          child: StreamBuilder<NotificationsState>(
            stream: notificationsBloc.stream,
            initialData: notificationsBloc.state,
            builder: (context, notifSnapshot) {
              final unread = notifSnapshot.data?.unreadCount ?? 0;
              if (unread == 0) return avatar;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  avatar,
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _UnreadBadge(count: unread),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DiscoveryOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DiscoveryOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.lightPrimary.withAlpha(51),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.lightPrimary,
                  size: 20,
                ), // Reducido de 24 a 20
              ),
              const SizedBox(width: 12), // Reducido de 16 a 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        // Cambiado de titleMedium a titleSmall
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2), // Reducido de 4 a 2
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14, // Reducido de 16 a 14
                color: context.colorScheme.onSurface.withAlpha(153),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
