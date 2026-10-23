import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/provider/provider.dart';

class MaterialsetProvider extends Provider {
  Future<MaterialSetResult> fetchmaterialset(
      String routingNo, String activityNo, String operationType) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/MaterialSet",
          queryParameters: {
            "\$filter":
                "RoutingNo eq '$routingNo' and ActivityNo eq '$activityNo' and OperationType eq '${operationType.toUpperCase()}'",
            "\$format": 'json'
          });
      String? message;

      final sapMessageHeader = response.headers.value('sap-message');
      if (sapMessageHeader != null && sapMessageHeader.isNotEmpty) {
        final sapMessage = jsonDecode(sapMessageHeader);
        message = sapMessage['message'];
      }
      return MaterialSetResult(
        data: ResponseMaterialset.fromJson(response.data),
        message: message,
      );
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
