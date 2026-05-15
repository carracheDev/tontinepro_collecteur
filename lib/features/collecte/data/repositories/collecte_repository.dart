import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final collecteRepositoryProvider =
    Provider<CollecteRepository>((ref) => CollecteRepository());

class InitierCollecteResult {
  final String operationId;
  final String? transactionId;
  final String message;

  InitierCollecteResult({
    required this.operationId,
    this.transactionId,
    required this.message,
  });
}

class StatutOperation {
  final String id;
  final String statut;
  final int montant;
  final String type;

  StatutOperation({
    required this.id,
    required this.statut,
    required this.montant,
    required this.type,
  });

  factory StatutOperation.fromJson(Map<String, dynamic> j) => StatutOperation(
        id: j['id'] as String? ?? '',
        statut: j['statut'] as String? ?? '',
        montant: (j['montant'] as num?)?.toInt() ?? 0,
        type: j['type'] as String? ?? 'COTISATION',
      );

  bool get estSucces =>
      statut == 'SUCCES' || statut == 'CONFIRME' || statut == 'VALIDE';
  bool get estEchec =>
      statut == 'ECHEC' || statut == 'EXPIREE' || statut == 'ANNULEE';
}

class CollecteRepository {
  final _dio = DioClient.instance;

  Future<InitierCollecteResult> initierCotisation({
    required String clientId,
    required int montant,
    required String operateur,
    String? tontineId,
    String? telephone,
    double? latitude,
    double? longitude,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.initierCotisation,
      data: {
        'clientId': clientId,
        'montant': montant,
        'operateur': operateur,
        if (tontineId != null) 'tontineId': tontineId,
        if (telephone != null) 'telephone': telephone,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    final op = resp.donnees['operation'] as Map<String, dynamic>? ?? resp.donnees;
    return InitierCollecteResult(
      operationId: op['id'] as String? ?? '',
      transactionId: resp.donnees['transactionId'] as String?,
      message: resp.messageApi,
    );
  }

  Future<StatutOperation> statut(String operationId) async {
    final resp = await _dio.get(ApiEndpoints.statutOperation(operationId));
    return StatutOperation.fromJson(resp.donnees);
  }
}
