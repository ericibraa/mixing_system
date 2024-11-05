import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/provider.dart';

class WeighingProvider extends Provider {
  Future<TongResponse> fetchweighing(String routingNo, String internalCntr,
      String activityNo, String operationType, String operationApps) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/WeighingActSet",
          queryParameters: {
            "\$filter":
                " RoutingNo eq '$routingNo' and InternalCntr eq '$internalCntr' and ActivityNo eq '$activityNo' and OperationType eq '$operationType' and OperationApps eq '$operationApps'",
            "\$format": 'json'
          });
      return TongResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
