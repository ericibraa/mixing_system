import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/provider.dart';

class TongProvider extends Provider {
  Future<TongResponse> fetchtong(String routingNo, String activityNo,
      String controlRecipe, String operationType) async {
    try {
      Response response =
          await dio.get("${apiUrl.orderApi}/wadahSet", queryParameters: {
        "\$expand": 'WadToMatNav',
        "\$filter":
            " RoutingNo eq '$routingNo' and ActivityNo eq '$activityNo' and ControlRecipe eq '$controlRecipe' and OperationType eq '$operationType'",
        "\$format": 'json'
      });
      return TongResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
