import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/provider.dart';

class WadahSetProvider extends Provider {
  Future<TongResponse> fetchWadahSet(
      String routingNo, String activityNo, String operationType) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER2_SRV/wadahSet",
          queryParameters: {
            "\$expand": 'WadToMatNav',
            "\$filter":
                " RoutingNo eq '$routingNo' and ActivityNo eq '$activityNo' and OperationType eq '$operationType'",
            "\$format": 'json'
          });
      return TongResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
