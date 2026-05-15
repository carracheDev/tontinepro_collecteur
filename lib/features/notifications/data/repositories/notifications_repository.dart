import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepository());

class NotificationItem {
  final String id;
  final String titre;
  final String type;
  final DateTime date;
  final bool lu;
  final bool estSmsClient;

  NotificationItem({
    required this.id,
    required this.titre,
    required this.type,
    required this.date,
    required this.lu,
    this.estSmsClient = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) {
    final canal = j['canal'] as String? ?? '';
    final type = j['type'] as String? ?? j['categorie'] as String? ?? '';
    return NotificationItem(
      id: j['id'] as String? ?? '',
      titre: j['titre'] as String? ?? j['message'] as String? ?? type,
      type: type,
      date: DateTime.tryParse(j['creeLe']?.toString() ?? '') ?? DateTime.now(),
      lu: j['lu'] as bool? ?? j['estLu'] as bool? ?? false,
      estSmsClient: canal == 'SMS' || type.contains('SMS'),
    );
  }
}

class NotificationsRepository {
  final _dio = DioClient.instance;

  Future<List<NotificationItem>> lister() async {
    final resp = await _dio.get(ApiEndpoints.notifications);
    final list = resp.donnees['notifications'] as List? ??
        resp.donnees as List? ??
        [];
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> compterNonLues() async {
    final resp = await _dio.get(ApiEndpoints.notificationsNonLues);
    return (resp.donnees['count'] as num?)?.toInt() ??
        (resp.donnees['nonLues'] as num?)?.toInt() ??
        0;
  }
}
