import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/provider/provider.dart';

class MaterialsetProvider extends Provider {
  Future<ResponseMaterialset> fetchmaterialset(
      String routingNo, String activityNo, String operationType) async {
    try {
      Response response =
          await dio.get("${apiUrl.orderApi}/MaterialSet", queryParameters: {
        "\$filter":
            "RoutingNo eq '$routingNo' and ActivityNo eq '$activityNo' and OperationType eq '${operationType.toUpperCase()}'",
        "\$format": 'json'
      });
      return ResponseMaterialset.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
