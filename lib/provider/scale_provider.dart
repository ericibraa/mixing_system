import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/provider/provider.dart';

class ScaleProvider extends Provider {
  Future<ScaleResponse> fetchscale(String plant) async {
    try {
      Response response = await dio.get("${apiUrl.scaleApi}/EquipmentSet",
          queryParameters: {
            "\$filter": " Plant eq '0101'",
            "\$format": 'json'
          });
      return ScaleResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
