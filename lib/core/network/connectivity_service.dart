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
///
/// [refresh] always completes *after* the status has been re-evaluated, and
/// concurrent evaluations are coalesced into a single in-flight probe. This
/// keeps `SyncEngine` (which awaits `refresh()` before deciding whether to
/// run) from ever observing a stale status.
class ConnectivityService {
  ConnectivityService(this._health, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final HealthService _health;
  final Connectivity _connectivity;
  final _controller = StreamController<ConnectionStatus>.broadcast();
  ConnectionStatus _status = ConnectionStatus.offline;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Future<void>? _inflight;

  Stream<ConnectionStatus> get statusStream => _controller.stream;
  ConnectionStatus get status => _status;

  Future<void> start() async {
    // The platform event channel is absent under `flutter test` and in some
    // stripped builds, where `listen` throws instead of returning an erroring
    // stream. Treat that as "no push updates" — `refresh()` still re-probes
    // and falls back to OFFLINE — rather than letting it escape.
    try {
      _sub ??= _connectivity.onConnectivityChanged.listen(
        (_) {
          unawaited(refresh());
        },
        onError: (Object _) {},
      );
    } catch (_) {
      _sub ??= null;
    }
    await refresh();
  }

  /// Re-probes network + backend health. Completes once the new status has
  /// been emitted.
  Future<void> refresh() {
    final running = _inflight;
    if (running != null) return running;
    final probe = _evaluate();
    _inflight = probe;
    probe.whenComplete(() {
      if (identical(_inflight, probe)) _inflight = null;
    });
    return probe;
  }

  Future<void> _evaluate() async {
    if (ApiConfig.devForceOffline) {
      _emit(ConnectionStatus.offline);
      return;
    }
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.every((r) => r == ConnectivityResult.none)) {
        _emit(ConnectionStatus.offline);
        return;
      }
      final ok = await _health.isBackendReachable();
      _emit(ok ? ConnectionStatus.online : ConnectionStatus.serverUnavailable);
    } catch (_) {
      _emit(ConnectionStatus.offline);
    }
  }

  void markSyncing() => _emit(ConnectionStatus.syncing);

  void _emit(ConnectionStatus s) {
    if (_status == s) return;
    if (_controller.isClosed) return;
    _status = s;
    _controller.add(s);
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
