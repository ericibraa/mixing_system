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
    receiveTimeout: const Duration(minutes: 1),
    connectTimeout: const Duration(minutes: 1),
    sendTimeout: const Duration(minutes: 30),
  );

  Future<void> initDio() async {
    dio = Dio(options);

    dio.interceptors.addAll({
      AppInterceptors(),
    });
  }

  Future<void> setBasicAuth(String token) async {
    dio.options.headers[HttpHeaders.authorizationHeader] = "Basic $token";
  }

  DioClient._internal();
}
