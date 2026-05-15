import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

final scannerRepositoryProvider =
    Provider<ScannerRepository>((ref) => ScannerRepository());

class ScannerRepository {
  final _dio = DioClient.instance;

  Future<Map<String, dynamic>> scannerCode(String code) async {
    final resp = await _dio.post(ApiEndpoints.scannerQrCode(code));
    return resp.donnees;
  }
}
