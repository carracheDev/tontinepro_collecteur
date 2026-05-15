import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_models.dart';

final clientsRepositoryProvider =
    Provider<ClientsRepository>((ref) => ClientsRepository());

class ClientsRepository {
  final _dio = DioClient.instance;

  Future<ClientsDuJourResult> clientsDuJour() async {
    final resp = await _dio.get(ApiEndpoints.clientsDuJour);
    final d = resp.donnees;
    final list = (d['clients'] as List?) ?? [];
    return ClientsDuJourResult(
      clients: list
          .map((e) => ClientResume.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: ClientsDuJourStats.fromJson(
        (d['stats'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Future<FicheTerrain> ficheTerrain(String clientId) async {
    final resp = await _dio.get(ApiEndpoints.ficheTerrain(clientId));
    return FicheTerrain.fromJson(resp.donnees);
  }

  Future<void> checkIn({
    required String clientId,
    required double latitude,
    required double longitude,
  }) async {
    await _dio.post(
      ApiEndpoints.checkIn,
      data: {
        'clientId': clientId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<String> lienWhatsApp(String clientId) async {
    final resp = await _dio.get(ApiEndpoints.contactWhatsApp(clientId));
    return resp.donnees['lienWhatsApp'] as String? ?? '';
  }
}
