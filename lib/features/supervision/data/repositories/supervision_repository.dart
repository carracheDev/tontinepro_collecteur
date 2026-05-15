import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final supervisionRepositoryProvider =
    Provider<SupervisionRepository>((ref) => SupervisionRepository());

class SupervisionRepository {
  final _dio = DioClient.instance;

  Future<Map<String, dynamic>> kpis() async {
    final resp = await _dio.get(ApiEndpoints.analyticsKpis);
    return resp.donnees;
  }

  Future<List<Map<String, dynamic>>> performanceCollecteurs() async {
    final resp = await _dio.get(ApiEndpoints.performanceCollecteurs);
    final list = resp.donnees['collecteurs'] as List? ??
        resp.donnees as List? ??
        [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> litigesEnCours() async {
    final resp = await _dio.get(ApiEndpoints.litigesEnCours);
    final list = resp.donnees['litiges'] as List? ??
        resp.donnees as List? ??
        [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> scoresParZone() async {
    final resp = await _dio.get(ApiEndpoints.scoresParZone);
    final list = resp.donnees['zones'] as List? ?? resp.donnees as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
