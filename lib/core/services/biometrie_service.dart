import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometrieService {
  BiometrieService._();

  static final _auth = LocalAuthentication();
  static const _cleActivee = 'bio_collecteur_activee';

  static Future<bool> estDisponible() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authentifier({
    String raison =
        'Confirmez votre identité pour accéder à TontinePro Collecteur',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: raison,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException {
      return false;
    }
  }

  static Future<void> activer(bool valeur) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleActivee, valeur);
  }

  static Future<bool> estActivee() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleActivee) ?? false;
  }
}
