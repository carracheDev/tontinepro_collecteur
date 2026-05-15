import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage.dart';

enum AppRole { agent, independant, superviseur }

extension AppRoleLabel on AppRole {
  String get apiValue => switch (this) {
        AppRole.agent => 'AGENT',
        AppRole.independant => 'INDEPENDANT',
        AppRole.superviseur => 'SUPERVISEUR',
      };

  String get label => switch (this) {
        AppRole.agent => 'Agent',
        AppRole.independant => 'Independant',
        AppRole.superviseur => 'Superviseur',
      };

  static AppRole fromApi(String? value) => switch (value) {
        'INDEPENDANT' => AppRole.independant,
        'SUPERVISEUR' => AppRole.superviseur,
        _ => AppRole.agent,
      };
}

class SessionState {
  const SessionState({
    this.role = AppRole.agent,
    this.telephone = '',
    this.authenticated = false,
  });

  final AppRole role;
  final String telephone;
  final bool authenticated;

  SessionState copyWith({
    AppRole? role,
    String? telephone,
    bool? authenticated,
  }) =>
      SessionState(
        role: role ?? this.role,
        telephone: telephone ?? this.telephone,
        authenticated: authenticated ?? this.authenticated,
      );
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState());

  Future<void> chargerSession() async {
    final role = await SecureStorage.lireUserRole();
    final phone = await SecureStorage.lireUserPhone();
    final connected = await SecureStorage.estConnecte();
    state = state.copyWith(
      role: AppRoleLabel.fromApi(role),
      telephone: phone ?? '',
      authenticated: connected,
    );
  }

  void definirBrouillon({required String telephone, required AppRole role}) {
    state = state.copyWith(telephone: telephone, role: role);
  }

  Future<void> connexionDemo() async {
    await SecureStorage.sauvegarderSessionDemo(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
      role: state.role.apiValue,
      telephone: state.telephone,
    );
    state = state.copyWith(authenticated: true);
  }

  Future<void> deconnexion() async {
    await SecureStorage.effacerSession();
    state = const SessionState();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(),
);
