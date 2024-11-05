import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/provider/provider.dart';

class ResultScaleProvider extends Provider {
  Future<ResultScaleListResponse> fetchresultscale(
      String orderNo, String activityNo, String activityWh) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/HasilTimbangSet",
          queryParameters: {
            "\$filter":
                "OrderNo eq '$orderNo' and ActivityNo eq '$activityNo' and ActivityWh eq '$activityWh'",
            "\$format": 'json'
          });
      return ResultScaleListResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
