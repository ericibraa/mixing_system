import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/provider.dart';

class OperationProvider extends Provider {
  Future<OperationResponse> fetchoperation(
      String routingNo, String operationType, String operationApps) async {
    try {
      Response response =
          await dio.get("${apiUrl.orderApi}/OperationSet", queryParameters: {
        "\$filter":
            " RoutingNo eq '$routingNo' and OperationType eq '$operationType' and OperationApps $operationApps",
        "\$format": 'json'
      });
      return OperationResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
