import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorage {
  SecureStorage._();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> lireAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  static Future<String?> lireRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  static Future<String?> lireUserRole() =>
      _storage.read(key: AppConstants.keyUserRole);

  static Future<String?> lireUserPhone() =>
      _storage.read(key: AppConstants.keyUserPhone);

  static Future<void> sauvegarderTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
    ]);
  }

  static Future<void> sauvegarderUtilisateur({
    required String id,
    required String telephone,
    required String nom,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyUserId, value: id),
      _storage.write(key: AppConstants.keyUserPhone, value: telephone),
      _storage.write(key: AppConstants.keyUserName, value: nom),
      _storage.write(key: AppConstants.keyUserRole, value: role),
    ]);
  }

  static Future<void> sauvegarderSessionDemo({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String telephone,
  }) async {
    await sauvegarderTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await sauvegarderUtilisateur(
      id: 'demo-collecteur',
      telephone: telephone,
      nom: 'Collecteur terrain',
      role: role,
    );
  }

  static Future<bool> estConnecte() async {
    final token = await lireAccessToken();
    if (token == null || token.isEmpty) return false;
    final parts = token.split('.');
    if (parts.length != 3) return true;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  static Future<void> effacerSession() => _storage.deleteAll();
}
