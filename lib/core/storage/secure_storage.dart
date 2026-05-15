import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> sauvegarderTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
    ]);
  }

  static Future<String?> lireAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  static Future<String?> lireRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  static Future<void> sauvegarderTokenOnboarding(String token) =>
      _storage.write(key: AppConstants.keyOnboardingToken, value: token);

  static Future<String?> lireTokenOnboarding() =>
      _storage.read(key: AppConstants.keyOnboardingToken);

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

  static Future<String?> lireUserId() =>
      _storage.read(key: AppConstants.keyUserId);

  static Future<String?> lireUserRole() =>
      _storage.read(key: AppConstants.keyUserRole);

  static Future<String?> lireUserName() =>
      _storage.read(key: AppConstants.keyUserName);

  static Future<String?> lireUserPhone() =>
      _storage.read(key: AppConstants.keyUserPhone);

  static Future<bool> estConnecte() async {
    final token = await lireAccessToken();
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  static Future<void> marquerOnboardingVu() =>
      _storage.write(key: AppConstants.keyOnboardingVu, value: 'true');

  static Future<bool> onboardingVu() async =>
      (await _storage.read(key: AppConstants.keyOnboardingVu)) == 'true';

  static Future<void> effacerSession() async {
    final onboarding = await _storage.read(key: AppConstants.keyOnboardingVu);
    await _storage.deleteAll();
    if (onboarding != null) {
      await _storage.write(key: AppConstants.keyOnboardingVu, value: onboarding);
    }
  }
}
