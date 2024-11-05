import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/label.dart';
import 'package:dumping_system/provider/provider.dart';

class LabelProvider extends Provider {
  Future<LabelResponse> fetchlabel(String orderNo, String activityNo) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/ExpiredSet",
          queryParameters: {
            "\$filter":
                " OrderNo eq '$orderNo' and ActivityNo eq '$activityNo'",
            "\$format": "json"
          });
      return LabelResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
