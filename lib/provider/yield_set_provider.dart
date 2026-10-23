import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/yield_set.dart';
import 'package:dumping_system/provider/provider.dart';

class YieldSetProvider extends Provider {
  Future<YieldSetResponse> fetchYieldSet(
      String routingNo, String internalCntr, String activityNo) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_POST_WEIGHT_SRV/YieldSet",
          queryParameters: {
            "\$filter":
                " RoutingNo eq '$routingNo' and InternalCntr eq '$internalCntr' and ActivityNo eq '$activityNo'",
            "\$format": 'json'
          });
      return YieldSetResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
