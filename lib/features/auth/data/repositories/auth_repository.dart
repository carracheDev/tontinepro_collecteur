import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepository {
  Dio get _dio => DioClient.instance;

  // Dio propre sans intercepteur auth — pour les appels sensibles (creerPin, connexion)
  Dio get _cleanDio => Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: AppConstants.timeoutRequete),
    receiveTimeout: const Duration(seconds: AppConstants.timeoutRequete),
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
  ));

  Future<Map<String, String?>> renvoyerOtpInscription({
    required String telephone,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.renvoyerOtpInscription,
      data: {'telephone': telephone},
    );
    final donnees = resp.donnees;
    return {
      'otpId': donnees['otpId']?.toString(),
      'otpTest': donnees['otpTest']?.toString(),
      'nom': donnees['nom']?.toString(),
      'role': donnees['role']?.toString(),
      'reprise': donnees['reprise']?.toString(),
    };
  }

  Future<Map<String, String?>> inscription({
    required String telephone,
    required String nom,
    required String role,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.inscription,
      data: {'telephone': telephone, 'nom': nom, 'role': role},
    );
    final donnees = resp.donnees;
    return {
      'otpId': donnees['otpId']?.toString(),
      'otpTest': donnees['otpTest']?.toString(),
    };
  }

  Future<void> verifierOtp({
    required String telephone,
    required String code,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.verifierOtp,
      data: {'telephone': telephone, 'code': code},
    );
    final token = resp.data['donnees']['tokenTemporaire'] as String;
    await SecureStorage.sauvegarderTokenOnboarding(token);
  }

  Future<void> creerPin({required String pin}) async {
    final token = await SecureStorage.lireTokenOnboarding();
    final resp = await _cleanDio.post(
      ApiEndpoints.creerPin,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {'pin': pin},
    );
    final donnees = resp.data['donnees'] as Map<String, dynamic>;
    // Reset DioClient pour tuer tout refresh en cours
    DioClient.reset();
    await SecureStorage.sauvegarderTokens(
      accessToken: donnees['accessToken'] as String,
      refreshToken: donnees['refreshToken'] as String,
    );
    await _chargerProfil();
  }

  Future<void> connexion({
    required String telephone,
    required String pin,
  }) async {
    final resp = await _cleanDio.post(
      ApiEndpoints.connexion,
      data: {'telephone': telephone, 'pin': pin},
    );
    final donnees = resp.data['donnees'] as Map<String, dynamic>;
    // Reset DioClient pour tuer tout refresh en cours
    DioClient.reset();
    await SecureStorage.sauvegarderTokens(
      accessToken: donnees['accessToken'] as String,
      refreshToken: donnees['refreshToken'] as String,
    );
    await _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    try {
      final resp = await _dio.get(ApiEndpoints.profil);
      final u = resp.donnees;
      await SecureStorage.sauvegarderUtilisateur(
        id: u['id']?.toString() ?? '',
        telephone: u['telephone']?.toString() ?? '',
        nom: u['nom']?.toString() ?? 'Collecteur',
        role: u['role']?.toString() ?? 'AGENT',
      );
    } catch (_) {}
  }

  Future<void> deconnexion() async {
    try {
      await _dio.post(ApiEndpoints.deconnexion);
    } catch (_) {}
    DioClient.reset();
    await SecureStorage.effacerSession();
  }
}
