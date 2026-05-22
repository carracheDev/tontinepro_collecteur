import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _creer();
    return _instance!;
  }

  static Dio _creer() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.timeoutRequete),
        receiveTimeout: const Duration(seconds: AppConstants.timeoutRequete),
        sendTimeout: const Duration(seconds: AppConstants.timeoutRequete),
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true'},
      ),
    );

    dio.interceptors.add(_AuthIntercepteur(dio));
    if (!kReleaseMode) {
      dio.interceptors.add(_LogIntercepteur());
    }
    return dio;
  }
}

class _AuthIntercepteur extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  _AuthIntercepteur(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.lireAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRefresh =
        err.requestOptions.path.contains('/auth/rafraichir-token');
    if (err.response?.statusCode == 401 && !isRefresh) {
      try {
        await _refreshTokenSiNecessaire();
        final newToken = await SecureStorage.lireAccessToken();
        if (newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retente = await dio.fetch(err.requestOptions);
          return handler.resolve(retente);
        }
      } catch (_) {
        await SecureStorage.effacerSession();
      }
    }
    handler.next(err);
  }

  Future<void> _refreshTokenSiNecessaire() async {
    if (_isRefreshing) {
      await _refreshCompleter!.future;
      return;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    try {
      final refreshToken = await SecureStorage.lireRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/rafraichir-token'),
        );
      }
      final resp = await Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout:
              const Duration(seconds: AppConstants.timeoutRequete),
        ),
      ).post('/auth/rafraichir-token', data: {'refreshToken': refreshToken});

      final donnees = (resp.data['donnees'] as Map).cast<String, dynamic>();
      await SecureStorage.sauvegarderTokens(
        accessToken: donnees['accessToken'] as String,
        refreshToken: donnees['refreshToken'] as String,
      );
      _refreshCompleter!.complete();
    } catch (e) {
      await SecureStorage.effacerSession();
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}

class _LogIntercepteur extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('[API] ${options.method} ${options.path}');
    }
    handler.next(options);
  }
}

extension DioResponseX on Response {
  Map<String, dynamic> get donnees =>
      (data['donnees'] as Map<String, dynamic>?) ?? {};

  String get messageApi => (data['message'] as String?) ?? 'Erreur inconnue';

  String? get codeMetier => data['code'] as String?;
}

String extraireMessageErreur(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Votre session a expiré. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé pour votre rôle.';
      case 429:
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 500:
        return 'Erreur serveur. Réessayez plus tard.';
    }
    if (e.type == DioExceptionType.connectionError) {
      final url = e.requestOptions.baseUrl;
      return 'Serveur injoignable ($url).\n'
          'Vérifie que le backend tourne sur port 3000\n'
          'et lance l\'app avec : bash run.sh';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      final url = e.requestOptions.baseUrl;
      return 'Délai dépassé ($url).\n'
          '→ Émulateur : backend sur localhost:3000 ?\n'
          '→ Device réel : lance "bash run.sh" dans le dossier collecteur';
    }
  }
  return 'Une erreur inattendue est survenue.';
}
