// lib/core/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits [true] when the device has at least one usable network interface
  /// (WiFi, mobile data, or ethernet) and [false] when offline.
  ///
  /// Note: having a network interface ≠ having real internet access (e.g. captive
  /// portals). HTTP requests remain the ground truth for actual reachability.
  Stream<bool> get isConnected => _connectivity.onConnectivityChanged.map(
    (results) => results.any(_isReachable),
  );

  /// Returns the current connectivity state as a one-shot check.
  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(_isReachable);
  }

  static bool _isReachable(ConnectivityResult result) =>
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet;
}
