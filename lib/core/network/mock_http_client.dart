import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// In-app mock backend for `--dart-define=MOCK_API=true` builds.
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
        'id': 'mock-officer-1',
        'name': 'Demo Field Officer',
        'email': email,
        'role': 'field_officer',
        'jurisdictionState': 'Karnataka',
        'jurisdictionDistrict': 'Bengaluru Rural',
        'jurisdictionTehsil': 'Devanahalli',
        'jurisdictionVillage': null,
        'organizationName': 'Demo Org',
      };

  List<Map<String, dynamic>> _mockCases() => [
        {
          'id': 'case-1',
          'projectId': 'proj-1',
          'parcelId': 'parcel-1',
          'caseNo': 'CASE-001',
          'currentStage': 'field_verification',
          'status': 'active',
        },
        {
          'id': 'case-2',
          'projectId': 'proj-1',
          'parcelId': 'parcel-2',
          'caseNo': 'CASE-002',
          'currentStage': 'field_verification',
          'status': 'active',
        },
      ];

  List<Map<String, dynamic>> _mockParcels() => [
        {
          'id': 'parcel-1',
          'surveyNo': 'S-12/3',
          'village': 'Dodballapur',
          'tehsil': 'Devanahalli',
          'district': 'Bengaluru Rural',
          'state': 'Karnataka',
          'areaHa': '1.25',
          'ownerName': 'Ramesh Kumar',
          'landType': 'agricultural',
          'geometryWkt':
              'POLYGON((77.55 13.20, 77.56 13.20, 77.56 13.21, 77.55 13.21, 77.55 13.20))',
          'centroidLat': '13.205',
          'centroidLng': '77.555',
        },
        {
          'id': 'parcel-2',
          'surveyNo': 'S-44/1',
          'village': 'Devanahalli',
          'tehsil': 'Devanahalli',
          'district': 'Bengaluru Rural',
          'state': 'Karnataka',
          'areaHa': '0.80',
          'ownerName': 'Lakshmi Devi',
          'landType': 'agricultural',
          'geometryWkt':
              'POLYGON((77.70 13.25, 77.71 13.25, 77.71 13.26, 77.70 13.26, 77.70 13.25))',
          'centroidLat': '13.255',
          'centroidLng': '77.705',
        },
      ];
}
