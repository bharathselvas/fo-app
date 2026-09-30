import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import 'mock_http_client.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.code, this.message, [this.details]);

  final int statusCode;
  final String code;
  final String message;
  final List<dynamic>? details;

  bool get isConflict => statusCode == 409;
  bool get isServerDataChanged =>
      details != null &&
      details!.any((d) => d is Map && d['code'] == 'SERVER_DATA_CHANGED');

  @override
  String toString() => message;
}

/// Thin HTTP client for the Terranex backend.
class ApiClient {
  ApiClient({http.Client? httpClient})
      : _http = httpClient ??
            (ApiConfig.mockMode ? MockHttpClient() : http.Client());

  final http.Client _http;
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{
      if (json) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    return h;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _http.get(ApiConfig.uri(path), headers: _headers(json: false));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final res = await _http.post(
      ApiConfig.uri(path),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filename,
    Uint8List? bytes,
    String? contentType,
  }) async {
    final req = http.MultipartRequest('POST', ApiConfig.uri(path));
    if (_token != null) req.headers['Authorization'] = 'Bearer $_token';
    req.fields.addAll(fields);
    if (fileField != null && bytes != null) {
      req.files.add(http.MultipartFile.fromBytes(
        fileField,
        bytes,
        filename: filename ?? 'upload.bin',
        contentType: contentType != null
            ? MediaType.parse(contentType)
            : MediaType('application', 'octet-stream'),
      ));
    }
    final streamed = await _http.send(req);
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else {
        json = {};
      }
    } catch (_) {
      json = {};
    }
    if (res.statusCode >= 400) {
      final err = json['error'] as Map<String, dynamic>?;
      throw ApiException(
        res.statusCode,
        err?['code'] as String? ?? 'ERROR',
        err?['message'] as String? ?? 'Request failed (${res.statusCode})',
        err?['details'] as List<dynamic>?,
      );
    }
    return json;
  }
}
