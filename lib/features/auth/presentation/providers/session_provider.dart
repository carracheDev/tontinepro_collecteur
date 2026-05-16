import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/storage/secure_storage.dart';

// Providers autoDispose = ils se recrééent proprement à chaque invalidation
final sessionRoleProvider = FutureProvider.autoDispose<RoleCollecteur?>((ref) async {
  final role = await SecureStorage.lireUserRole();
  return RoleCollecteur.depuisApi(role);
});

final sessionNomProvider = FutureProvider.autoDispose<String>((ref) async {
  return await SecureStorage.lireUserName() ?? 'Collecteur';
});

final sessionTelephoneProvider = FutureProvider.autoDispose<String>((ref) async {
  return await SecureStorage.lireUserPhone() ?? '';
});

/// À appeler dans un widget après connexion/inscription.
/// Passe ref.invalidate directement pour éviter les conflits WidgetRef/Ref.
void rafraichirSession(void Function(ProviderOrFamily) invalidate) {
  invalidate(sessionRoleProvider);
  invalidate(sessionNomProvider);
  invalidate(sessionTelephoneProvider);
}
