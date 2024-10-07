import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dumping_system/provider/provider.dart';

class AuthProvider extends Provider {
  Future<String> login(String username, String password) async {
    try {
      await dio.get("${apiUrl.dumpingApi}/\$metadata",
          options: Options(
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          ));
      return base64Encode(utf8.encode('$username:$password'));
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
