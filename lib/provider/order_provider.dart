import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/provider/provider.dart';
import 'package:intl/intl.dart';

class OrderProvider extends Provider {
  Future<OrderResponse> fetchorder(String startDate, String materialCode,
      String plant, String operationType) async {
    var date = DateFormat('yyyyMMdd')
        .format(DateFormat('dd-MM-yyyy').parse(startDate));
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/OrderSet",
          queryParameters: {
            "\$filter":
                "StartDate eq '$date' and Material eq '$materialCode' and Plant eq '$plant' and OperationType eq '${operationType.toUpperCase()}'",
            "\$format": 'json'
          });
      return OrderResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
