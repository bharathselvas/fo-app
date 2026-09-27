import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.jurisdictionState,
    this.jurisdictionDistrict,
    this.jurisdictionTehsil,
    this.jurisdictionVillage,
    this.organizationName,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? jurisdictionState;
  final String? jurisdictionDistrict;
  final String? jurisdictionTehsil;
  final String? jurisdictionVillage;
  final String? organizationName;

  bool get isFieldOfficer => role == 'field_officer';

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        role: j['role'] as String? ?? '',
        jurisdictionState: j['jurisdictionState'] as String?,
        jurisdictionDistrict: j['jurisdictionDistrict'] as String?,
        jurisdictionTehsil: j['jurisdictionTehsil'] as String?,
        jurisdictionVillage: j['jurisdictionVillage'] as String?,
        organizationName: j['organizationName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'jurisdictionState': jurisdictionState,
        'jurisdictionDistrict': jurisdictionDistrict,
        'jurisdictionTehsil': jurisdictionTehsil,
        'jurisdictionVillage': jurisdictionVillage,
        'organizationName': organizationName,
      };
}

/// Session: token in secure storage; user mirrored for offline open.
/// Passwords are never persisted.
class SessionService {
  SessionService(this._db, this._api) : _secure = const FlutterSecureStorage();

  final AppDatabase _db;
  final ApiClient _api;
  final FlutterSecureStorage _secure;

  static const _keyToken = 'bs_fo_token';
  static const _keyUser = 'bs_fo_user';

  Future<({String token, AppUser user})?> restore() async {
    final token = await _secure.read(key: _keyToken);
    final userJson = await _secure.read(key: _keyUser);
    if (token == null || userJson == null) {
      final rows = await _db.select(_db.sessions).get();
      if (rows.isEmpty) return null;
      try {
        final user = AppUser.fromJson(jsonDecode(rows.first.userJson) as Map<String, dynamic>);
        _api.setToken(rows.first.token);
        return (token: rows.first.token, user: user);
      } catch (_) {
        return null;
      }
    }
    try {
      final user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      _api.setToken(token);
      return (token: token, user: user);
    } catch (_) {
      return null;
    }
  }

  Future<({String token, AppUser user})> login(String email, String password) async {
    final res = await _api.post('/auth/login', body: {'email': email, 'password': password});
    final token = res['token'] as String;
    final userJson = res['user'] as Map<String, dynamic>;
    final user = AppUser.fromJson(userJson);
    if (!user.isFieldOfficer) {
      throw StateError('This app is only for Field Officer accounts.');
    }
    _api.setToken(token);
    await _secure.write(key: _keyToken, value: token);
    await _secure.write(key: _keyUser, value: jsonEncode(user.toJson()));
    await _db.delete(_db.sessions).go();
    await _db.into(_db.sessions).insert(
          SessionsCompanion.insert(
            id: 'current',
            token: token,
            userJson: jsonEncode(user.toJson()),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return (token: token, user: user);
  }

  Future<AppUser?> refreshMe() async {
    try {
      final res = await _api.get('/auth/me');
      final user = AppUser.fromJson(res['user'] as Map<String, dynamic>);
      await _secure.write(key: _keyUser, value: jsonEncode(user.toJson()));
      await (_db.update(_db.sessions)..where((t) => t.id.equals('current'))).write(
        SessionsCompanion(
          userJson: Value(jsonEncode(user.toJson())),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secure.delete(key: _keyToken);
    await _secure.delete(key: _keyUser);
    await _db.delete(_db.sessions).go();
    _api.setToken(null);
  }
}
