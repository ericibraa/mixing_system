import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/expired_set.dart';
import 'package:dumping_system/provider/provider.dart';

class ExpiredSetProvider extends Provider {
  Future<ExpiredsetResponse> fetchExpiredSet(
      String orderNo, String activityNo) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/ExpiredSet",
          queryParameters: {
            "\$filter":
                " OrderNo eq '$orderNo' and ActivityNo eq '$activityNo'",
            "\$format": "json"
          });
      return ExpiredsetResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
