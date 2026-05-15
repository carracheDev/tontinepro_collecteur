import 'api_config.dart';

abstract class AppConstants {
  static String get baseUrl => ApiConfig.baseUrl;

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserName = 'user_name';
  static const String keyOnboardingToken = 'onboarding_token';
  static const String keyOnboardingVu = 'onboarding_vu';

  static const String formatMonnaie = 'FCFA';
  static const String indicatifBenin = '+229';

  static const int longueurPin = 4;
  static const int longueurOtp = 6;
  static const int timeoutRequete = 30;
  static const int limitePage = 20;
}
