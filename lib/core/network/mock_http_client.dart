import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// In-app mock backend (default; disable with `--dart-define=MOCK_API=false`).
///
/// Serves every endpoint the FO app calls so a physical device can run the
/// release APK with no server at all.
class MockHttpClient extends http.BaseClient {
  MockHttpClient();

  final Map<String, String> _idsByClientId = {};
  int _seq = 0;

  String _idFor(String kind, String clientId) =>
      _idsByClientId.putIfAbsent(clientId, () {
        _seq += 1;
        return 'mock-$kind-$_seq';
      });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final method = request.method.toUpperCase();
    final path = request.url.path;
    final apiPath = path.replaceFirst(RegExp(r'^/api'), '');
    final body = await _readBody(request);
    final json = _route(method, apiPath, body, request);
    final bytes = utf8.encode(jsonEncode(json));
    return http.StreamedResponse(
      Stream.fromIterable([bytes]),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Map<String, dynamic>> _readBody(http.BaseRequest request) async {
    if (request is http.MultipartRequest) {
      // Multipart bodies are only used as fields on upload endpoints.
      return Map<String, dynamic>.from(request.fields);
    }
    if (request is http.Request) {
      final raw = request.body;
      if (raw.isEmpty) return <String, dynamic>{};
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _route(
    String method,
    String path,
    Map<String, dynamic> body,
    http.BaseRequest request,
  ) {
    // GET /health
    if (method == 'GET' && path == '/health') {
      return {'status': 'ok'};
    }

    // POST /auth/login
    if (method == 'POST' && path == '/auth/login') {
      return {
        'token': 'mock-token',
        'user': _mockUser(body['email'] as String? ?? 'officer@demo.local'),
      };
    }

    // GET /auth/me
    if (method == 'GET' && path == '/auth/me') {
      return {'user': _mockUser('officer@demo.local')};
    }

    // GET /cases
    if (method == 'GET' && path == '/cases') {
      return {'cases': _mockCases()};
    }

    // GET /projects/{projectId}/parcels
    final projectParcels = RegExp(r'^/projects/([^/]+)/parcels$').firstMatch(path);
    if (method == 'GET' && projectParcels != null) {
      return {'parcels': _mockParcels()};
    }

    // POST /parcels/{parcelId}/field-verifications  (create)
    final createVerification =
        RegExp(r'^/parcels/([^/]+)/field-verifications$').firstMatch(path);
    if (method == 'POST' && createVerification != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'verification': {'id': _idFor('verification', clientId)},
      };
    }

    // POST /parcels/{parcelId}/field-verification  (submit, singular)
    final submitVerification =
        RegExp(r'^/parcels/([^/]+)/field-verification$').firstMatch(path);
    if (method == 'POST' && submitVerification != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'verification': {'id': _idFor('submit', clientId)},
      };
    }

    // POST /field-verifications/{id}/structures
    final structures =
        RegExp(r'^/field-verifications/([^/]+)/structures$').firstMatch(path);
    if (method == 'POST' && structures != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'structure': {'id': _idFor('structure', clientId)},
      };
    }

    // POST /field-verifications/{id}/vegetation
    final vegetation =
        RegExp(r'^/field-verifications/([^/]+)/vegetation$').firstMatch(path);
    if (method == 'POST' && vegetation != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'vegetation': {'id': _idFor('vegetation', clientId)},
      };
    }

    // POST /field-verifications/{id}/evidence  (multipart)
    final evidence =
        RegExp(r'^/field-verifications/([^/]+)/evidence$').firstMatch(path);
    if (method == 'POST' && evidence != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'evidence': {'id': _idFor('evidence', clientId)},
      };
    }

    // POST /cases/{caseId}/documents  (multipart)
    final documents = RegExp(r'^/cases/([^/]+)/documents$').firstMatch(path);
    if (method == 'POST' && documents != null) {
      final clientId = body['clientId'] as String? ?? path;
      return {
        'document': {'id': _idFor('document', clientId)},
      };
    }

    // Fallback: unknown endpoint succeeds with empty object.
    return <String, dynamic>{};
  }

  Map<String, dynamic> _mockUser(String email) => {
        'id': 'FO-TN-CBE-0247',
        'name': 'Arun Kumar',
        'email': email,
        'role': 'field_officer',
        'jurisdictionState': 'Tamil Nadu',
        'jurisdictionDistrict': 'Coimbatore',
        'jurisdictionTehsil': 'Sulur',
        'jurisdictionVillage': null,
        'organizationName': 'District Land Acquisition Office',
      };

  List<Map<String, dynamic>> _mockCases() => [
        {
          'id': 'case-0142',
          'projectId': 'PRJ-WRR-2026',
          'parcelId': 'PAR-CBE-0142',
          'caseNo': 'LA-TN-CBE-2026-0142',
          'currentStage': 'field_verification',
          'status': 'active',
        },
        {
          'id': 'case-0138',
          'projectId': 'PRJ-CMRL-P2',
          'parcelId': 'PAR-CBE-0138',
          'caseNo': 'LA-TN-CBE-2026-0138',
          'currentStage': 'field_verification',
          'status': 'active',
        },
      ];

  List<Map<String, dynamic>> _mockParcels() => [
        {
          'id': 'PAR-CBE-0142',
          'surveyNo': '142/3A',
          'village': 'Kittampalayam',
          'tehsil': 'Sulur',
          'district': 'Coimbatore',
          'state': 'Tamil Nadu',
          'areaHa': '0.74',
          'ownerName': 'R. Subramanian',
          'landType': 'agricultural',
          'geometryWkt':
              'POLYGON((77.12 11.04, 77.13 11.04, 77.13 11.05, 77.12 11.05, 77.12 11.04))',
          'centroidLat': '11.0456',
          'centroidLng': '77.1234',
        },
        {
          'id': 'PAR-CBE-0138',
          'surveyNo': '88/2',
          'village': 'Koundanpalayam',
          'tehsil': 'Coimbatore North',
          'district': 'Coimbatore',
          'state': 'Tamil Nadu',
          'areaHa': '0.93',
          'ownerName': 'Kavitha Ramesh',
          'landType': 'agricultural',
          'geometryWkt':
              'POLYGON((77.10 11.03, 77.11 11.03, 77.11 11.04, 77.10 11.04, 77.10 11.03))',
          'centroidLat': '11.0356',
          'centroidLng': '77.1034',
        },
      ];
}
