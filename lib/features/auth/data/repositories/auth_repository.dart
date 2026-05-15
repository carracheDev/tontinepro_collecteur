import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

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
    final otpTest = donnees['otpTest'];
    return {
      'otpId': donnees['otpId']?.toString(),
      'otpTest': otpTest?.toString(),
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
    final tempDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.timeoutRequete),
        receiveTimeout: const Duration(seconds: AppConstants.timeoutRequete),
      ),
    );
    final resp = await tempDio.post(
      ApiEndpoints.creerPin,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
      data: {'pin': pin},
    );
    final donnees = resp.data['donnees'] as Map<String, dynamic>;
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
    final resp = await _dio.post(
      ApiEndpoints.connexion,
      data: {'telephone': telephone, 'pin': pin},
    );
    final donnees = resp.data['donnees'] as Map<String, dynamic>;
    await SecureStorage.sauvegarderTokens(
      accessToken: donnees['accessToken'] as String,
      refreshToken: donnees['refreshToken'] as String,
    );
    await _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final resp = await _dio.get(ApiEndpoints.profil);
    final u = resp.donnees;
    await SecureStorage.sauvegarderUtilisateur(
      id: u['id']?.toString() ?? '',
      telephone: u['telephone']?.toString() ?? '',
      nom: u['nom']?.toString() ?? 'Collecteur',
      role: u['role']?.toString() ?? 'AGENT',
    );
  }

  Future<void> deconnexion() async {
    try {
      await _dio.post(ApiEndpoints.deconnexion);
    } catch (_) {}
    await SecureStorage.effacerSession();
  }
}
