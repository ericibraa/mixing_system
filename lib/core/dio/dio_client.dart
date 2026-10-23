import 'dart:io';
import 'package:dio/dio.dart';
import 'interceptors.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  final BaseOptions options = BaseOptions(
    receiveTimeout: const Duration(seconds: 10),
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  );

  Future<void> initDio() async {
    dio = Dio(options);

    dio.interceptors.addAll([
      AppInterceptors(),
    ]);
  }

  Future<void> setBasicAuth(String token) async {
    dio.options.headers[HttpHeaders.authorizationHeader] = "Basic $token";
  }

  DioClient._internal();
}
