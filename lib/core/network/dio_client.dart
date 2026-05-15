import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

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
        connectTimeout: Duration(seconds: AppConstants.timeoutRequete),
        receiveTimeout: Duration(seconds: AppConstants.timeoutRequete),
        sendTimeout: Duration(seconds: AppConstants.timeoutRequete),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio));
    if (!kReleaseMode) dio.interceptors.add(_LogInterceptor());
    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this.dio);

  final Dio dio;
  bool _refreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.lireAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRefreshCall = err.requestOptions.path == ApiEndpoints.refresh;
    if (err.response?.statusCode != 401 || isRefreshCall || _refreshing) {
      handler.next(err);
      return;
    }

    _refreshing = true;
    try {
      final refreshToken = await SecureStorage.lireRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await SecureStorage.effacerSession();
        handler.next(err);
        return;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['donnees'] as Map<String, dynamic>? ?? {};
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String? ?? refreshToken;
      if (newAccess == null) {
        await SecureStorage.effacerSession();
        handler.next(err);
        return;
      }
      await SecureStorage.sauvegarderTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retry = await DioClient.instance.fetch(retryOptions);
      handler.resolve(retry);
    } catch (_) {
      await SecureStorage.effacerSession();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('[API ERR] ${err.response?.statusCode} ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}

extension DioResponseX on Response {
  Map<String, dynamic> get donnees =>
      (data['donnees'] as Map<String, dynamic>?) ?? {};

  String get messageApi => (data['message'] as String?) ?? 'Erreur inconnue';
}
