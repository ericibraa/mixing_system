import 'package:dio/dio.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    print(options.headers);
    print(options.data);
    print(options.queryParameters);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print(response.data.toString());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log the error details
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Error Response Data: ${err.response?.data}');
    print('Error Type: ${err.type}');
    print('Error Message: ${err.message}');
    print('Underlying Error: ${err.error}');

    if (err.response?.statusCode == 401) {
      print('Unauthorized access - 401');
    } else if (err.response?.statusCode == 500) {
      // Handle server errors (500)
      print('Internal Server Error - 500');
    }
    super.onError(err, handler);
  }
}
