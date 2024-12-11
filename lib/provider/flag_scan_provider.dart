import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dumping_system/models/request/flag_materials.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/provider/auth_provider.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage storage = const FlutterSecureStorage(
  iOptions: IOSOptions(
    synchronizable: false,
    accessibility: KeychainAccessibility.first_unlock,
  ),
);

class FlagScanProvider extends Provider {
  Future<String> fetchSubmitFlag(FlagMaterials flagMaterials) async {
    try {
      String? token = await storage.read(key: 'token');
      var authReturn = await AuthProvider().loginWithToken(token!);
      Response response = await dio.post(
          "${apiUrl.dumpingApi}/ZDMP_POST_ORDER_SRV/MaterialFlagSet",
          data: jsonEncode(flagMaterials),
          options: Options(
            headers: {
              'x-csrf-token': authReturn['csrfToken'],
              'Cookie': authReturn['cookie'],
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
          ));
      if (response.statusCode == 201) {
        return 'success';
      } else {
        return 'error';
      }
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
