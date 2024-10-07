import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:intl/intl.dart';

class OperationProvider extends Provider {
  Future<OperationResponse> fetchoperation(String startDate,
      String materialCode, String plant, String operationType) async {
    var date = DateFormat('yyyymmdd')
        .format(DateFormat('dd-MM-yyyy').parse(startDate));
    try {
      Response response =
          await dio.get("${apiUrl.orderApi}/OrderSet", queryParameters: {
        "\$expand": 'OrdToOprNav',
        "\$filter":
            "StartDate eq '$date' and Material eq '$materialCode' and Plant eq '$plant' and OperationType eq '${operationType.toUpperCase()}'",
        "\$format": 'json'
      });
      return OperationResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
