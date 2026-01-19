import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/locationset.dart';
import 'package:dumping_system/provider/provider.dart';

class LocationSetProvider extends Provider {
  Future<LocationSetResponse> fetchLocationSet(
      String routingNo, String internalCntr, String activityNo) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/LocationSet",
          queryParameters: {
            "\$filter":
                "RoutingNo eq '$routingNo' and InternalCntr eq '$internalCntr' and ActivityNo eq '$activityNo'",
            "\$format": 'json'
          });
      return LocationSetResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
