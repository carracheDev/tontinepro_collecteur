import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/role_collecteur.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authTelephoneProvider = StateProvider<String>((ref) => '');

/// Rôle pour inscription (AGENT ou INDEPENDANT uniquement côté API).
final inscriptionRoleProvider =
    StateProvider<RoleCollecteur>((ref) => RoleCollecteur.agent);

final authRoleDemoProvider =
    StateProvider<RoleCollecteur>((ref) => RoleCollecteur.agent);

class AuthState {
  final bool loading;
  final String? erreur;
  final bool succes;
  final String? otpTest;

  const AuthState({
    this.loading = false,
    this.erreur,
    this.succes = false,
    this.otpTest,
  });

  AuthState copyWith({
    bool? loading,
    String? erreur,
    bool? succes,
    String? otpTest,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      erreur: erreur,
      succes: succes ?? this.succes,
      otpTest: otpTest ?? this.otpTest,
    );
  }
}

class InscriptionNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  InscriptionNotifier(this._repo) : super(const AuthState());

  Future<bool> inscrire({
    required String telephone,
    required String nom,
    required String role,
  }) async {
    state = state.copyWith(loading: true, erreur: null);
    try {
      final result = await _repo.inscription(
        telephone: telephone,
        nom: nom,
        role: role,
      );
      state = AuthState(
        loading: false,
        succes: true,
        otpTest: result['otpTest'],
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, erreur: extraireMessageErreur(e));
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, erreur: 'Erreur inattendue.');
      return false;
    }
  }
}

final inscriptionProvider =
    StateNotifierProvider.autoDispose<InscriptionNotifier, AuthState>((ref) {
  return InscriptionNotifier(ref.watch(authRepositoryProvider));
});

class RenvoyerOtpNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  RenvoyerOtpNotifier(this._repo) : super(const AuthState());

  Future<Map<String, String?>?> renvoyer({required String telephone}) async {
    state = state.copyWith(loading: true, erreur: null);
    try {
      final result = await _repo.renvoyerOtpInscription(telephone: telephone);
      state = AuthState(
        loading: false,
        succes: true,
        otpTest: result['otpTest'],
      );
      return result;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, erreur: extraireMessageErreur(e));
      return null;
    } catch (_) {
      state = state.copyWith(loading: false, erreur: 'Erreur inattendue.');
      return null;
    }
  }
}

final renvoyerOtpProvider =
    StateNotifierProvider.autoDispose<RenvoyerOtpNotifier, AuthState>((ref) {
  return RenvoyerOtpNotifier(ref.watch(authRepositoryProvider));
});

class OtpNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  OtpNotifier(this._repo) : super(const AuthState());

  Future<bool> verifier({
    required String telephone,
    required String code,
  }) async {
    state = state.copyWith(loading: true, erreur: null);
    try {
      await _repo.verifierOtp(telephone: telephone, code: code);
      state = state.copyWith(loading: false, succes: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, erreur: extraireMessageErreur(e));
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, erreur: 'Erreur inattendue.');
      return false;
    }
  }
}

final otpProvider =
    StateNotifierProvider.autoDispose<OtpNotifier, AuthState>((ref) {
  return OtpNotifier(ref.watch(authRepositoryProvider));
});

class CreerPinNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  CreerPinNotifier(this._repo) : super(const AuthState());

  Future<bool> creer({required String pin}) async {
    state = state.copyWith(loading: true, erreur: null);
    try {
      await _repo.creerPin(pin: pin);
      state = state.copyWith(loading: false, succes: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, erreur: extraireMessageErreur(e));
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, erreur: 'Erreur inattendue.');
      return false;
    }
  }
}

final creerPinProvider =
    StateNotifierProvider.autoDispose<CreerPinNotifier, AuthState>((ref) {
  return CreerPinNotifier(ref.watch(authRepositoryProvider));
});

class ConnexionNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  ConnexionNotifier(this._repo) : super(const AuthState());

  Future<bool> connecter({
    required String telephone,
    required String pin,
  }) async {
    state = state.copyWith(loading: true, erreur: null);
    try {
      await _repo.connexion(telephone: telephone, pin: pin);
      state = state.copyWith(loading: false, succes: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, erreur: extraireMessageErreur(e));
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, erreur: 'Erreur inattendue.');
      return false;
    }
  }

  void reinitialiser() => state = const AuthState();
}

final connexionProvider =
    StateNotifierProvider.autoDispose<ConnexionNotifier, AuthState>((ref) {
  return ConnexionNotifier(ref.watch(authRepositoryProvider));
});
