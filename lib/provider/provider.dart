import 'package:dio/dio.dart';

import '../core/config/environment.dart';
import '../core/dio/dio_client.dart';

abstract class Provider {
  // final Dio _dio = createDio();

  // static Dio createDio() {
  //   var dio = Dio(BaseOptions(
  //       receiveTimeout: Duration(minutes: 1),
  //       connectTimeout: Duration(minutes: 1),
  //       sendTimeout: Duration(minutes: 30)));
  //   dio.interceptors.addAll({
  //     AppInterceptors(),
  //   });

  //   return dio;
  // }

  final Dio dio = DioClient().dio;
  final apiUrl = Environment().config;
}
