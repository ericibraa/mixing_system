import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:intl/intl.dart';

class OrderProvider extends Provider {
  Future<OrderResponse> fetchorder(String startDate, String materialCode,
      String plant, String operationType, String batchFG) async {
    String filter =
        "Material eq '$materialCode' and Plant eq '$plant' and OperationType eq '${operationType.toUpperCase()}' and BatchFG eq '$batchFG'";
    if (startDate != '') {
      var date = DateFormat('yyyyMMdd')
          .format(DateFormat('dd-MM-yyyy').parse(startDate));
      filter += "and StartDate eq '$date'";
    }
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/OrderSet",
          queryParameters: {"\$filter": filter, "\$format": 'json'});
      return OrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
