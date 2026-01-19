import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/provider.dart';

class TongProvider extends Provider {
  Future<TongResponse> fetchtong(String routingNo, String activityNo,
      String controlRecipe, String operationType) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/wadahSet",
          queryParameters: {
            "\$expand": 'WadToMatNav',
            "\$filter":
                " RoutingNo eq '$routingNo' and ActivityNo eq '$activityNo' and ControlRecipe eq '$controlRecipe' and OperationType eq '$operationType'",
            "\$format": 'json'
          });
      return TongResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
