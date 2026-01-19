import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/provider/provider.dart';

class ResultScaleProvider extends Provider {
  Future<ResultScaleListResponse> fetchresultscale(String orderNo,
      String activityNo, String activityWh, String operationType) async {
    try {
      var filter = "OrderNo eq '$orderNo' and ActivityNo eq '$activityNo'";
      if (activityWh != '' && operationType != 'DECOCT') {
        filter += " and ActivityWh eq '$activityWh'";
      }
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/HasilTimbangSet",
          queryParameters: {"\$filter": filter, "\$format": 'json'});
      return ResultScaleListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
