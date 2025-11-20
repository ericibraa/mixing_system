import 'dart:io';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
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
  receiveTimeout: const Duration(milliseconds: 5000),
  connectTimeout: const Duration(milliseconds: 5000),
  sendTimeout: const Duration(milliseconds: 5000),  
);


  Future<void> initDio() async {
    dio = Dio(options);

    dio.interceptors.addAll({
      AppInterceptors(),
      AwesomeDioInterceptor()
    });
  }

  Future<void> setBasicAuth(String token) async {
    dio.options.headers[HttpHeaders.authorizationHeader] = "Basic $token";
  }

  DioClient._internal();
}
