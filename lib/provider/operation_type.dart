import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:intl/intl.dart';

class OperationTypeProvider extends Provider {
  Future<OperationTypeResponse> fetchoperationtype(String startDate,
      String materialCode, String plant, String batchFG) async {
    String filter =
        "Material eq '$materialCode' and Plant eq '$plant' and BatchFG eq '$batchFG'";
    if (startDate != "") {
      var date = DateFormat('yyyyMMdd')
          .format(DateFormat('dd-MM-yyyy').parse(startDate));
      filter += "and StartDate eq '$date'";
    }
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/OperationTypeSet",
          queryParameters: {
            "\$expand": 'OprTypToDescNav',
            "\$filter": filter,
            "\$format": 'json'
          });
      return OperationTypeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
