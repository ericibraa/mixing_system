import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/provider/provider.dart';

class ScaleProvider extends Provider {
  Future<ScaleResponse> fetchscale(String plant) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_WEIGHT_SRV/EquipmentSet",
          queryParameters: {
            "\$filter": " Plant eq '$plant'",
            "\$format": 'json'
          });
      return ScaleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
