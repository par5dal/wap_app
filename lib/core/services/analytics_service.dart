// lib/core/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:wap_app/core/utils/app_logger.dart';

/// Wrapper sobre FirebaseAnalytics que centraliza todos los eventos de la app.
/// Todos los métodos son fire-and-forget y capturan errores silenciosamente.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── Auth ────────────────────────────────────────────────────────────────

  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      AppLogger.warning('Analytics logLogin error: $e');
    }
  }

  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      AppLogger.warning('Analytics logSignUp error: $e');
    }
  }

  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      AppLogger.warning('Analytics logLogout error: $e');
    }
  }

  // ─── Eventos ─────────────────────────────────────────────────────────────

  Future<void> logViewEvent({
    required String eventId,
    required String eventName,
  }) async {
    try {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: eventId,
            itemName: eventName,
            itemCategory: 'event',
          ),
        ],
      );
    } catch (e) {
      AppLogger.warning('Analytics logViewEvent error: $e');
    }
  }

  Future<void> logFavoriteEvent({
    required String eventId,
    required String eventName,
    required bool added,
  }) async {
    try {
      if (added) {
        await _analytics.logEvent(
          name: 'add_to_favorites',
          parameters: {'event_id': eventId, 'event_name': eventName},
        );
      } else {
        await _analytics.logEvent(
          name: 'remove_from_favorites',
          parameters: {'event_id': eventId, 'event_name': eventName},
        );
      }
    } catch (e) {
      AppLogger.warning('Analytics logFavoriteEvent error: $e');
    }
  }

  Future<void> logShareEvent({
    required String eventId,
    required String eventName,
  }) async {
    try {
      await _analytics.logShare(
        contentType: 'event',
        itemId: eventId,
        method: 'native_share_sheet',
      );
    } catch (e) {
      AppLogger.warning('Analytics logShareEvent error: $e');
    }
  }

  // ─── Notificaciones ──────────────────────────────────────────────────────

  Future<void> logNotificationTap({required String type}) async {
    try {
      await _analytics.logEvent(
        name: 'notification_tap',
        parameters: {'notification_type': type},
      );
    } catch (e) {
      AppLogger.warning('Analytics logNotificationTap error: $e');
    }
  }
}
