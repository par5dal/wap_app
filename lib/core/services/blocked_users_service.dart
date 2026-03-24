// lib/core/services/blocked_users_service.dart

import 'package:flutter/foundation.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';

/// Servicio global que mantiene en memoria el conjunto de IDs de usuarios
/// bloqueados por el usuario autenticado.
///
/// Se carga desde el backend al iniciar sesión y se limpia al cerrar sesión.
class BlockedUsersService extends ChangeNotifier {
  final UserActionsRemoteDataSource _dataSource;

  final Set<String> _blockedIds = {};

  BlockedUsersService({required UserActionsRemoteDataSource dataSource})
    : _dataSource = dataSource;

  /// IDs de usuarios actualmente bloqueados.
  Set<String> get blockedIds => Set.unmodifiable(_blockedIds);

  /// Devuelve true si el usuario con [userId] está bloqueado.
  bool isBlocked(String userId) => _blockedIds.contains(userId);

  /// Carga la lista de usuarios bloqueados desde el backend.
  /// Llamar al autenticar; los fallos se registran pero no lanzan excepción.
  Future<void> loadFromRemote() async {
    try {
      final ids = await _dataSource.getBlockedUsers();
      _blockedIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    } catch (e) {
      AppLogger.warning('⚠️ BlockedUsersService.loadFromRemote failed: $e');
    }
  }

  /// Añade el usuario [userId] al conjunto local y notifica cambios.
  void addBlocked(String userId) {
    if (_blockedIds.add(userId)) {
      notifyListeners();
    }
  }

  /// Elimina el usuario [userId] del conjunto local y notifica cambios.
  void removeBlocked(String userId) {
    if (_blockedIds.remove(userId)) {
      notifyListeners();
    }
  }

  /// Limpia todos los IDs bloqueados (llamar al cerrar sesión).
  void clear() {
    if (_blockedIds.isNotEmpty) {
      _blockedIds.clear();
      notifyListeners();
    }
  }
}
