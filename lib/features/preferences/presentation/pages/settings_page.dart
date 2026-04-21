// lib/features/preferences/presentation/pages/settings_page.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wap_app/core/config/dependency_injection.dart' as di;
import 'package:wap_app/core/router/app_router.dart';
import 'package:wap_app/core/services/notification_service.dart';
import 'package:wap_app/core/utils/extensions.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/usecases/get_legal_document.dart';
import 'package:wap_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:wap_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wap_app/l10n/app_localizations.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';
import 'package:wap_app/presentation/bloc/locale/locale_cubit.dart';
import 'package:wap_app/presentation/bloc/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isAuthenticated =
        context.watch<AppBloc>().state.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        title: Text(t.settingsTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // --- Sección Idioma (visible siempre) ---
          _CollapsibleSection(
            title: t.settingsSectionLanguage,
            icon: Icons.language_outlined,
            child: _LanguageSelector(t: t, isAuthenticated: isAuthenticated),
          ),

          // --- Sección Apariencia (visible siempre) ---
          _CollapsibleSection(
            title: t.settingsSectionAppearance,
            icon: Icons.palette_outlined,
            child: _ThemeSelector(t: t, isAuthenticated: isAuthenticated),
          ),

          // --- Sección Notificaciones ---
          _CollapsibleSection(
            title: t.settingsSectionNotifications,
            icon: Icons.notifications_outlined,
            child: isAuthenticated
                ? _NotificationsSection(t: t)
                : _NotificationsGuestBanner(t: t),
          ),

          // --- Sección Permisos (siempre visible) ---
          _CollapsibleSection(
            title: t.settingsSectionPermissions,
            icon: Icons.security_outlined,
            child: const _PermissionsSection(),
          ),

          // --- Sección Legal (siempre visible) ---
          _CollapsibleSection(
            title: t.settingsSectionLegal,
            icon: Icons.gavel_outlined,
            child: Column(
              children: [
                _LegalDocumentTile(
                  icon: Icons.privacy_tip_outlined,
                  title: t.settingsPrivacyPolicy,
                  type: 'privacy',
                ),
                _LegalDocumentTile(
                  icon: Icons.description_outlined,
                  title: t.settingsTermsOfUse,
                  type: 'terms',
                ),
              ],
            ),
          ),
          // --- Sección Tutoriales (siempre visible) ---
          _CollapsibleSection(
            title: t.settingsSectionTutorials,
            icon: Icons.help_outline,
            child: ListTile(
              leading: const Icon(Icons.replay_outlined),
              title: Text(t.settingsTutorialReplay),
              subtitle: Text(t.settingsTutorialReplayDesc),
              onTap: () {
                di.sl<SharedPreferences>().setBool('onboarding_seen', false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.settingsTutorialReplayConfirm)),
                );
              },
            ),
          ),
          // --- Sección Información (siempre visible) ---
          _CollapsibleSection(
            title: t.settingsSectionInfo,
            icon: Icons.info_outline,
            child: const _AppInfoSection(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsible section
// ---------------------------------------------------------------------------

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            maintainState: true,
            leading: Icon(icon, color: context.colorScheme.primary),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            iconColor: context.colorScheme.primary,
            collapsedIconColor: context.colorScheme.onSurface.withValues(
              alpha: 0.4,
            ),
            children: [child],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language selector
// ---------------------------------------------------------------------------

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.t, required this.isAuthenticated});
  final AppLocalizations t;
  final bool isAuthenticated;

  static const _options = [
    (code: 'es', flag: '🇪🇸'),
    (code: 'en', flag: '🇬🇧'),
    (code: 'pt', flag: '🇵🇹'),
  ];

  static const _supported = ['es', 'en', 'pt'];

  String _label(AppLocalizations t, String code) => switch (code) {
    'en' => t.settingsLanguageEn,
    'pt' => t.settingsLanguagePt,
    _ => t.settingsLanguageEs,
  };

  /// Devuelve el código activo: preferencia guardada o, si no hay ninguna,
  /// el idioma real del dispositivo mapeado a es/en/pt (fallback 'es').
  String _activeCode(BuildContext context) {
    final stored = context.watch<LocaleCubit>().state?.languageCode;
    if (stored != null) return stored;
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return _supported.contains(deviceCode) ? deviceCode : 'es';
  }

  @override
  Widget build(BuildContext context) {
    final activeCode = _activeCode(context);

    return RadioGroup<String>(
      groupValue: activeCode,
      onChanged: (value) => _onChanged(context, value),
      child: Column(
        children: _options.map((opt) {
          final isSelected = opt.code == activeCode;
          return RadioListTile<String>(
            value: opt.code,
            title: Row(
              children: [
                Text(opt.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(_label(t, opt.code)),
              ],
            ),
            selected: isSelected,
            activeColor: context.colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _onChanged(BuildContext context, String? code) async {
    if (code == null) return;
    // Actualizar locale inmediatamente en la UI
    await context.read<LocaleCubit>().setLocale(Locale(code));

    // Re-registrar el token FCM solo si está autenticado
    if (isAuthenticated) {
      unawaited(di.sl<NotificationService>().registerToken());
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsLanguageSaved),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Theme selector
// ---------------------------------------------------------------------------

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.t, required this.isAuthenticated});
  final AppLocalizations t;
  final bool isAuthenticated;

  static const _options = [
    (mode: ThemeMode.system, icon: Icons.brightness_auto_outlined),
    (mode: ThemeMode.light, icon: Icons.light_mode_outlined),
    (mode: ThemeMode.dark, icon: Icons.dark_mode_outlined),
  ];

  String _label(AppLocalizations t, ThemeMode mode) => switch (mode) {
    ThemeMode.light => t.settingsThemeLight,
    ThemeMode.dark => t.settingsThemeDark,
    _ => t.settingsThemeSystem,
  };

  @override
  Widget build(BuildContext context) {
    final currentMode = context.watch<ThemeCubit>().state;

    return RadioGroup<ThemeMode>(
      groupValue: currentMode,
      onChanged: (value) => _onChanged(context, value),
      child: Column(
        children: _options.map((opt) {
          return RadioListTile<ThemeMode>(
            value: opt.mode,
            title: Row(
              children: [
                Icon(opt.icon, size: 22),
                const SizedBox(width: 12),
                Text(_label(t, opt.mode)),
              ],
            ),
            selected: opt.mode == currentMode,
            activeColor: context.colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _onChanged(BuildContext context, ThemeMode? mode) async {
    if (mode == null) return;
    await context.read<ThemeCubit>().setTheme(mode);

    // Re-registrar el token FCM solo si está autenticado
    if (isAuthenticated) {
      unawaited(di.sl<NotificationService>().registerToken());
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsThemeSaved),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Permissions section
// ---------------------------------------------------------------------------

enum _PermState { loading, granted, denied, blocked }

class _PermissionsSection extends StatefulWidget {
  const _PermissionsSection();

  @override
  State<_PermissionsSection> createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends State<_PermissionsSection>
    with WidgetsBindingObserver {
  _PermState _locationStatus = _PermState.loading;
  _PermState _notifStatus = _PermState.loading;
  _PermState _cameraStatus = _PermState.loading;

  /// Prevents the lifecycle observer from resetting state mid-request dialog.
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Small delay so iOS has time to propagate any permission grant that just
    // happened before this page was opened (e.g. notification granted on home).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(const Duration(milliseconds: 400), _checkAll),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_requesting) {
      // Delay avoids reading stale status: iOS can take ~200-500 ms to
      // propagate a permission grant made in the Settings app.
      Future.delayed(const Duration(milliseconds: 500), _checkAll);
    }
  }

  Future<void> _checkAll() async {
    try {
      final prevLocation = _locationStatus;
      final loc = await Geolocator.checkPermission();
      final notif = await Permission.notification.status;
      final cam = await Permission.camera.status;
      if (!mounted) return;
      final newLocation = _fromGeolocator(loc);
      setState(() {
        _locationStatus = newLocation;
        _notifStatus = _fromPermission(notif);
        _cameraStatus = _fromPermission(cam);
      });
      // Reload map/events when location permission changes (granted ↔ denied)
      if (prevLocation != _PermState.loading && prevLocation != newLocation) {
        di.sl<HomeBloc>().add(const LoadNearbyEvents());
      }
    } catch (_) {
      // Platform channels may not be available in test environments.
      // Fail silently and show permissions as denied.
      if (mounted) {
        setState(() {
          _locationStatus = _PermState.denied;
          _notifStatus = _PermState.denied;
          _cameraStatus = _PermState.denied;
        });
      }
    }
  }

  _PermState _fromGeolocator(LocationPermission p) => switch (p) {
    LocationPermission.always ||
    LocationPermission.whileInUse => _PermState.granted,
    LocationPermission.deniedForever => _PermState.blocked,
    _ => _PermState.denied,
  };

  _PermState _fromPermission(PermissionStatus s) => switch (s) {
    PermissionStatus.granted ||
    PermissionStatus.limited ||
    PermissionStatus.provisional => _PermState.granted,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => _PermState.blocked,
    _ => _PermState.denied,
  };

  Future<void> _handleLocation() async {
    if (_locationStatus == _PermState.granted) {
      _showRevokeHint(useLocationSettings: true);
      return;
    }
    if (_locationStatus == _PermState.blocked) {
      _showActivateHint(useLocationSettings: true);
      await Geolocator.openAppSettings();
      return;
    }
    // denied: show system dialog
    _requesting = true;
    final result = await Geolocator.requestPermission();
    _requesting = false;
    if (!mounted) return;
    final newStatus = _fromGeolocator(result);
    setState(() => _locationStatus = newStatus);
    if (newStatus == _PermState.granted) {
      // Reload events so distances are calculated with the new location access.
      di.sl<HomeBloc>().add(const LoadNearbyEvents());
    } else {
      _showActivateHint(useLocationSettings: true);
    }
  }

  Future<void> _handleNotif() async {
    if (_notifStatus == _PermState.granted) {
      _showRevokeHint();
      return;
    }
    if (_notifStatus == _PermState.blocked) {
      _showActivateHint();
      await openAppSettings();
      return;
    }
    _requesting = true;
    await Permission.notification.request();
    // iOS needs a moment to propagate the grant before status() reflects it.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final actualNotif = await Permission.notification.status;
    _requesting = false;
    if (!mounted) return;
    final newStatus = _fromPermission(actualNotif);
    setState(() => _notifStatus = newStatus);
    if (newStatus != _PermState.granted) {
      _showActivateHint();
    }
  }

  Future<void> _handleCamera() async {
    if (_cameraStatus == _PermState.granted) {
      _showRevokeHint();
      return;
    }
    if (_cameraStatus == _PermState.blocked) {
      _showActivateHint();
      await openAppSettings();
      return;
    }
    _requesting = true;
    await Permission.camera.request();
    // iOS needs a moment to propagate the grant before status() reflects it.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final actualCam = await Permission.camera.status;
    _requesting = false;
    if (!mounted) return;
    final newStatus = _fromPermission(actualCam);
    setState(() => _cameraStatus = newStatus);
    if (newStatus != _PermState.granted) {
      _showActivateHint();
    }
  }

  void _showActivateHint({bool useLocationSettings = false}) {
    if (!mounted) return;
    final t = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.settingsPermActivateHint),
        action: SnackBarAction(
          label: t.settingsPermOpenSettings,
          onPressed: useLocationSettings
              ? Geolocator.openAppSettings
              : openAppSettings,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showRevokeHint({bool useLocationSettings = false}) {
    if (!mounted) return;
    final t = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.settingsPermRevokeHint),
        action: SnackBarAction(
          label: t.settingsPermOpenSettings,
          onPressed: useLocationSettings
              ? Geolocator.openAppSettings
              : openAppSettings,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      children: [
        _PermissionTile(
          icon: Icons.location_on_outlined,
          title: t.settingsPermLocation,
          description: t.settingsPermLocationDesc,
          status: _locationStatus,
          onTap: _handleLocation,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _PermissionTile(
          icon: Icons.notifications_outlined,
          title: t.settingsPermNotifications,
          description: t.settingsPermNotificationsDesc,
          status: _notifStatus,
          onTap: _handleNotif,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _PermissionTile(
          icon: Icons.camera_alt_outlined,
          title: t.settingsPermCamera,
          description: t.settingsPermCameraDesc,
          status: _cameraStatus,
          onTap: _handleCamera,
        ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final _PermState status;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final (chipLabel, chipColor, chipIcon) = switch (status) {
      _PermState.granted => (
        t.settingsPermStatusGranted,
        Colors.green.shade600,
        Icons.check_circle_outline,
      ),
      _PermState.denied || _PermState.blocked => (
        t.settingsPermStatusDenied,
        Colors.amber.shade700,
        Icons.help_outline,
      ),
      _PermState.loading => ('...', Colors.grey, Icons.hourglass_empty),
    };

    return ListTile(
      leading: Icon(icon, color: context.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: status == _PermState.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _StatusChip(label: chipLabel, color: chipColor, icon: chipIcon),
      onTap: status == _PermState.loading ? null : onTap,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications guest banner
// ---------------------------------------------------------------------------

class _NotificationsGuestBanner extends StatelessWidget {
  const _NotificationsGuestBanner({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final onPrimary = context.colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_active, color: onPrimary, size: 36),
            const SizedBox(height: 12),
            Text(
              t.settingsNotifGuestBanner,
              style: context.textTheme.titleMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: onPrimary,
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.pushNamed(AppRoute.auth.name),
                child: Text(
                  t.settingsNotifGuestBannerCta,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications section
// ---------------------------------------------------------------------------

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection({required this.t});
  final AppLocalizations t;

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _loading = true;
  bool _newEventsPush = true;
  bool _moderationEmail = true;
  bool _allPaused = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/users/me/notification-preferences');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _newEventsPush = data['new_events_push'] as bool? ?? true;
            _moderationEmail = data['moderation_email'] as bool? ?? true;
            _allPaused = data['all_paused'] as bool? ?? false;
            _loading = false;
          });
        }
      } else {
        // Respuesta no-200 (ej. 304): detener el spinner con los valores por defecto
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _patch(Map<String, dynamic> body) async {
    try {
      final dio = di.sl<Dio>();
      await dio.patch('/users/me/notification-preferences', data: body);
    } catch (_) {
      // fallo silencioso — el estado local ya se actualizó optimistamente
    }
  }

  bool get _isPromoterOrAdmin {
    final profileState = di.sl<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final role = profileState.userProfile.role?.toUpperCase();
      return role == 'PROMOTER' || role == 'ADMIN';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        // Master switch — todos los usuarios
        SwitchListTile(
          value: _allPaused,
          secondary: Icon(
            Icons.do_not_disturb_on_outlined,
            color: context.colorScheme.primary,
          ),
          title: Text(t.settingsNotifAllPaused),
          subtitle: Text(
            t.settingsNotifAllPausedDesc,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          activeThumbColor: context.colorScheme.primary,
          onChanged: (value) {
            setState(() => _allPaused = value);
            _patch({'all_paused': value});
          },
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        // Push nuevos eventos — todos los usuarios
        SwitchListTile(
          value: _newEventsPush && !_allPaused,
          secondary: Icon(
            Icons.campaign_outlined,
            color: _allPaused
                ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                : context.colorScheme.primary,
          ),
          title: Text(
            t.settingsNotifNewEvents,
            style: _allPaused
                ? TextStyle(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  )
                : null,
          ),
          subtitle: Text(
            t.settingsNotifNewEventsDesc,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.onSurface.withValues(
                alpha: _allPaused ? 0.3 : 0.6,
              ),
            ),
          ),
          activeThumbColor: context.colorScheme.primary,
          onChanged: _allPaused
              ? null
              : (value) {
                  setState(() => _newEventsPush = value);
                  _patch({'new_events_push': value});
                },
        ),
        // Email moderación — solo promotores y admins
        if (_isPromoterOrAdmin) ...[
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            value: _moderationEmail && !_allPaused,
            secondary: Icon(
              Icons.mark_email_read_outlined,
              color: _allPaused
                  ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                  : context.colorScheme.primary,
            ),
            title: Text(
              t.settingsNotifModerationEmail,
              style: _allPaused
                  ? TextStyle(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                    )
                  : null,
            ),
            subtitle: Text(
              t.settingsNotifModerationEmailDesc,
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.onSurface.withValues(
                  alpha: _allPaused ? 0.3 : 0.6,
                ),
              ),
            ),
            activeThumbColor: context.colorScheme.primary,
            onChanged: _allPaused
                ? null
                : (value) {
                    setState(() => _moderationEmail = value);
                    _patch({'moderation_email': value});
                  },
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Legal document tile - Loads Markdown content from backend
// ---------------------------------------------------------------------------

class _LegalDocumentTile extends StatefulWidget {
  const _LegalDocumentTile({
    required this.icon,
    required this.title,
    required this.type,
  });

  final IconData icon;
  final String title;
  final String type;

  @override
  State<_LegalDocumentTile> createState() => _LegalDocumentTileState();
}

class _LegalDocumentTileState extends State<_LegalDocumentTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: context.colorScheme.primary),
      title: Text(widget.title),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _showLegalDocument(context),
    );
  }

  Future<void> _showLegalDocument(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _LegalDocumentModal(type: widget.type, title: widget.title),
    );
  }
}

class _LegalDocumentModal extends StatefulWidget {
  const _LegalDocumentModal({required this.type, required this.title});

  final String type;
  final String title;

  @override
  State<_LegalDocumentModal> createState() => _LegalDocumentModalState();
}

class _LegalDocumentModalState extends State<_LegalDocumentModal> {
  LegalDocument? _document;
  bool _loading = true;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadDocument();
    }
  }

  Future<void> _loadDocument() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;

    final result = await di.sl<GetLegalDocumentUseCase>()(
      type: widget.type,
      lang: lang,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (document) => setState(() {
        _document = document;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: Navigator.of(context).pop,
            ),
          ),
          body: _buildBody(scrollController),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
              'Error al cargar el documento',
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
              onPressed: _loadDocument,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_document == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        for (final section in _document!.sections) ...[
          const SizedBox(height: 16),
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

// ---------------------------------------------------------------------------
// App Info section
// ---------------------------------------------------------------------------

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  static const _androidId = 'com.jovelupe.wap';
  static const _iosId = '6759071222';

  Future<void> _openStore(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final uri = isAndroid
        ? Uri.parse('market://details?id=$_androidId')
        : Uri.parse('https://apps.apple.com/app/id$_iosId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final fallback = Uri.parse(
        isAndroid
            ? 'https://play.google.com/store/apps/details?id=$_androidId'
            : 'https://apps.apple.com/app/id$_iosId',
      );
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '…';
        return Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.tag_outlined,
                color: context.colorScheme.primary,
              ),
              title: Text(t.settingsInfoVersion),
              trailing: Text(
                version,
                style: TextStyle(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(
                Icons.star_outline,
                color: context.colorScheme.primary,
              ),
              title: Text(t.settingsInfoRateApp),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openStore(context),
            ),
          ],
        );
      },
    );
  }
}
