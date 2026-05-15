import 'dart:io';

abstract class ApiConfig {
  /// URL de l'API — ordre de priorité :
  ///  1. --dart-define=API_BASE_URL=http://192.168.X.X:3000  (bash run.sh)
  ///  2. Émulateur Android   → http://10.0.2.2:3000
  ///  3. Production Render   → https://tontinepro-backend.onrender.com
  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'https://tontinepro-backend.onrender.com';
  }

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
}
