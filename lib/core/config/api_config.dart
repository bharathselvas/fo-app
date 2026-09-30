import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API configuration. Base URL is overridable for physical-device LAN testing.
class ApiConfig {
  /// When true (the default; disable with `--dart-define=MOCK_API=false`),
  /// all HTTP calls are served in-app by [MockHttpClient] — no backend required.
  static const bool mockMode = bool.fromEnvironment('MOCK_API', defaultValue: true);

  static const String defaultBaseUrl = 'http://10.0.2.2:3002/api';
  static const String prefBaseUrl = 'api_base_url';
  static const String prefDevOffline = 'dev_force_offline';

  static String _baseUrl = defaultBaseUrl;
  static bool _devForceOffline = false;

  static String get baseUrl => _baseUrl;
  static bool get devForceOffline => _devForceOffline;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(prefBaseUrl) ?? defaultBaseUrl;
    _devForceOffline = kDebugMode && (prefs.getBool(prefDevOffline) ?? false);
  }

  static Future<void> setBaseUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    _baseUrl = trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefBaseUrl, _baseUrl);
  }

  static Future<void> setDevForceOffline(bool value) async {
    _devForceOffline = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefDevOffline, value);
  }

  static Uri uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$p');
  }
}
