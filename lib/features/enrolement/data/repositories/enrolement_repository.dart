import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final enrolementRepositoryProvider =
    Provider<EnrolementRepository>((ref) => EnrolementRepository());

class EnrolementResult {
  final String clientId;
  final String nom;
  final String? codeQr;
  final String? identifiantTerrain;

  EnrolementResult({
    required this.clientId,
    required this.nom,
    this.codeQr,
    this.identifiantTerrain,
  });
}

class EnrolementRepository {
  final _dio = DioClient.instance;

  Future<EnrolementResult> enroler(Map<String, dynamic> payload) async {
    final resp = await _dio.post(
      ApiEndpoints.enrolerClientSansSmartphone,
      data: payload,
    );
    final d = resp.donnees;
    final client = d['client'] as Map<String, dynamic>? ?? d;
    final qr = d['qr'] as Map<String, dynamic>?;
    final profile = d['profile'] as Map<String, dynamic>?;
    return EnrolementResult(
      clientId: client['id'] as String? ?? '',
      nom: client['nom'] as String? ?? '',
      codeQr: qr?['code'] as String?,
      identifiantTerrain: profile?['identifiantTerrain'] as String?,
    );
  }
}
