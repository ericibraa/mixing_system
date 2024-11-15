import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:intl/intl.dart';

class OperationTypeProvider extends Provider {
  Future<OperationTypeResponse> fetchoperationtype(
      String startDate, String materialCode, String plant) async {
    var date = DateFormat('yyyyMMdd')
        .format(DateFormat('dd-MM-yyyy').parse(startDate));
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/OperationTypeSet",
          queryParameters: {
            "\$expand": 'OprTypToDescNav',
            "\$filter":
                "StartDate eq '$date' and Material eq '$materialCode' and Plant eq '$plant'",
            "\$format": 'json'
          });
      return OperationTypeResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
