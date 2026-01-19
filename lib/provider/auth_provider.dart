import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dumping_system/provider/provider.dart';

class AuthProvider extends Provider {
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      Response response =
          await dio.get("${apiUrl.dumpingApi}/ZDMP_GET_MATERIAL_SRV/\$metadata",
              options: Options(
                headers: {
                  'Authorization':
                      'Basic ${base64Encode(utf8.encode('$username:$password'))}',
                  'x-csrf-token': 'fetch'
                },
              ));

      String? csrfToken = response.headers['x-csrf-token']?.first;

      return {
        'token': base64Encode(utf8.encode('$username:$password')),
        'csrfToken': csrfToken ?? 'No CSRF token found',
        'username' : username
      };
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }

  Future<Map<String, dynamic>> loginWithToken(String token) async {
    try {
      Response response =
          await dio.get("${apiUrl.dumpingApi}/ZDMP_GET_MATERIAL_SRV/\$metadata",
              options: Options(
                headers: {
                  'Authorization': 'Basic $token',
                  'x-csrf-token': 'fetch',
                },
              ));

      String? csrfToken = response.headers['x-csrf-token']?.first;
      String? cookie =
          "${response.headers['set-cookie']![0]} ${response.headers['set-cookie']![2]}"
              .replaceAll("path=/", "");
      return {
        'token': token,
        'csrfToken': csrfToken ?? 'No CSRF token found',
        'cookie': cookie
      };
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
