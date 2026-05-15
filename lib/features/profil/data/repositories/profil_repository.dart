import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/repositories/auth_repository.dart';

final profilRepositoryProvider =
    Provider<ProfilRepository>((ref) => ProfilRepository());

class ProfilRepository {
  final _dio = DioClient.instance;
  final _auth = AuthRepository();

  Future<Map<String, dynamic>> profil() async {
    final resp = await _dio.get(ApiEndpoints.profil);
    return resp.donnees;
  }

  Future<Map<String, dynamic>> monQrCode() async {
    final resp = await _dio.get(ApiEndpoints.monCodeQr);
    return resp.donnees;
  }

  Future<void> deconnexion() => _auth.deconnexion();
}
