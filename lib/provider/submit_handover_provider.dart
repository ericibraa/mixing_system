import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dumping_system/models/request/submit_handover.dart';
import 'package:dumping_system/provider/auth_provider.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage storage = const FlutterSecureStorage(
  iOptions: IOSOptions(
    synchronizable: false,
    accessibility: KeychainAccessibility.first_unlock,
  ),
);

class SubmitHandoverProvider extends Provider {
  Future<String> submitHandover(SubmitHandoverRequest submitHandover) async {
    try {
      String? token = await storage.read(key: 'token');
      var authReturn = await AuthProvider().loginWithToken(token!);
      Response response = await dio.post("${apiUrl.postOrderApi}/OrderSet",
          data: jsonEncode(submitHandover),
          options: Options(
            headers: {
              'x-csrf-token': authReturn['csrfToken'],
              'Cookie': authReturn['cookie'],
              'Content-Type': 'application/json',
            },
          ));
      if (response.statusCode == 201) {
        return 'success';
      } else {
        return 'error';
      }
      // return Handover.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
