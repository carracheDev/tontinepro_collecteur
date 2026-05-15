import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/storage/secure_storage.dart';

final sessionRoleProvider = FutureProvider<RoleCollecteur?>((ref) async {
  final role = await SecureStorage.lireUserRole();
  return RoleCollecteur.depuisApi(role);
});

final sessionNomProvider = FutureProvider<String>((ref) async {
  return await SecureStorage.lireUserName() ?? 'Collecteur';
});
