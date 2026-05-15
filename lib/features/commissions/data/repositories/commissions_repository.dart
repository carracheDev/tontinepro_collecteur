import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final commissionsRepositoryProvider =
    Provider<CommissionsRepository>((ref) => CommissionsRepository());

class SoldeCommission {
  final int soldeDisponible;
  final int totalMois;
  final int nbTransactions;

  SoldeCommission({
    required this.soldeDisponible,
    required this.totalMois,
    required this.nbTransactions,
  });

  factory SoldeCommission.fromJson(Map<String, dynamic> j) => SoldeCommission(
        soldeDisponible:
            (j['soldeDisponible'] as num?)?.toInt() ??
            (j['soldeCommissionFcfa'] as num?)?.toInt() ??
            0,
        totalMois: (j['totalMois'] as num?)?.toInt() ?? 0,
        nbTransactions: (j['nbTransactions'] as num?)?.toInt() ?? 0,
      );
}

class LigneCommission {
  final String id;
  final int montant;
  final String type;
  final DateTime date;

  LigneCommission({
    required this.id,
    required this.montant,
    required this.type,
    required this.date,
  });

  factory LigneCommission.fromJson(Map<String, dynamic> j) => LigneCommission(
        id: j['id'] as String? ?? '',
        montant: (j['montantFcfa'] as num?)?.toInt() ?? 0,
        type: j['type'] as String? ?? '',
        date: DateTime.tryParse(j['creeLe']?.toString() ?? '') ?? DateTime.now(),
      );
}

class CommissionsRepository {
  final _dio = DioClient.instance;

  Future<SoldeCommission> monSolde() async {
    final resp = await _dio.get(ApiEndpoints.soldeCommission);
    return SoldeCommission.fromJson(resp.donnees);
  }

  Future<List<LigneCommission>> historique() async {
    final resp = await _dio.get(ApiEndpoints.historiqueCommissions);
    final list = resp.donnees['commissions'] as List? ??
        resp.donnees['historique'] as List? ??
        (resp.donnees is List ? resp.donnees as List : []);
    return list
        .map((e) => LigneCommission.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> dashboardIndependant() async {
    final resp = await _dio.get(ApiEndpoints.dashboardIndependant);
    return resp.donnees;
  }
}
