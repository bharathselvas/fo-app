import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'health_service.dart';

enum ConnectionStatus { online, offline, syncing, serverUnavailable }

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(HealthService());
  ref.onDispose(service.dispose);
  return service;
});

/// Combines connectivity_plus with an actual backend health probe.
class ConnectivityService {
  ConnectivityService(this._health, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final HealthService _health;
  final Connectivity _connectivity;
  final _controller = StreamController<ConnectionStatus>.broadcast();
  ConnectionStatus _status = ConnectionStatus.offline;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _debounce;

  Stream<ConnectionStatus> get statusStream => _controller.stream;
  ConnectionStatus get status => _status;

  Future<void> start() async {
    _sub ??= _connectivity.onConnectivityChanged.listen((_) => _evaluate());
    await _evaluate();
  }

  Future<void> refresh() => _evaluate();

  /// Dev simulator forces offline without changing architecture.
  Future<void> _evaluate() async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (ApiConfig.devForceOffline) {
        _emit(ConnectionStatus.offline);
        return;
      }
      final results = await _connectivity.checkConnectivity();
      final none = results.every((r) => r == ConnectivityResult.none);
      if (none) {
        _emit(ConnectionStatus.offline);
        return;
      }
      final ok = await _health.isBackendReachable();
      _emit(ok ? ConnectionStatus.online : ConnectionStatus.serverUnavailable);
    });
  }

  void markSyncing() => _emit(ConnectionStatus.syncing);

  void _emit(ConnectionStatus s) {
    if (_status == s) return;
    _status = s;
    if (!_controller.isClosed) _controller.add(s);
  }

  void dispose() {
    _sub?.cancel();
    _debounce?.cancel();
    _controller.close();
  }
}
