import 'dart:io';

abstract class ApiConfig {
  /// URL de l'API — ordre de priorité :
  ///  1. --dart-define=API_BASE_URL=http://192.168.X.X:3000  (bash run.sh)
  ///  2. Émulateur Android   → http://10.0.2.2:3000
  ///  3. Production Koyeb   → par défaut
  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;
    if (Platform.isAndroid && _isEmulateur) return 'http://10.0.2.2:3000';
    return 'https://difficult-marley-carrachedevpro-a2bb029d.koyeb.app';
  }

  // Détecte si on tourne sur un émulateur Android (IP 10.0.2.15 = émulateur Google)
  static bool get _isEmulateur {
    try {
      return Platform.isAndroid &&
          const bool.fromEnvironment('EMULATOR', defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  static bool get isProduction => environment == 'production';
}
