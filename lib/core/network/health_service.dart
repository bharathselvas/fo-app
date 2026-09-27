import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'mock_http_client.dart';

/// Backend reachability check — not just connectivity_plus.
class HealthService {
  HealthService({http.Client? client})
      : _client = client ??
            (ApiConfig.mockMode ? MockHttpClient() : http.Client());

  final http.Client _client;

  Future<bool> isBackendReachable({Duration timeout = const Duration(seconds: 4)}) async {
    if (ApiConfig.devForceOffline) return false;
    try {
      final res = await _client
          .get(ApiConfig.uri('/health'))
          .timeout(timeout);
      if (res.statusCode != 200) return false;
      return res.body.contains('"ok"');
    } catch (_) {
      return false;
    }
  }
}
