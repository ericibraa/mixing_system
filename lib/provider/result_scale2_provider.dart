import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/provider/provider.dart';

class ResultScale2Provider extends Provider {
  Future<ResultScaleListResponse> fetchresultscale2(String orderNo,
      String activityNo, String activityWh, String objectName) async {
    try {
      var filter =
          "OrderNo eq '$orderNo' and ActivityNo eq '$activityNo' and ObjectName eq '$objectName'";
      if (activityWh != '') {
        filter += " and ActivityWh eq '$activityWh'";
      }
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/HasilTimbang2Set",
          queryParameters: {"\$filter": filter, "\$format": 'json'});
      return ResultScaleListResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
