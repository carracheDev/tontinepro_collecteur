import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final tontinesRepositoryProvider = Provider((ref) => TontinesRepository());

class TontinesRepository {
  final _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> mesTontines() async {
    final resp = await _dio.get(ApiEndpoints.mesTontines);
    final list =
        resp.donnees['tontines'] as List? ?? resp.donnees as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> creerGroupe(Map<String, dynamic> data) async {
    final resp = await _dio.post('/tontines/creer', data: data);
    return resp.donnees;
  }
}
