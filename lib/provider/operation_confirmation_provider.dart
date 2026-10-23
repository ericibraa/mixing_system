import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/provider.dart';

class OperationConfirmationProvider extends Provider {
  Future<OperationResponse> fetchOperationConfirmation(
      String routingNo, String operationType, String operationApps) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_ORDER_SRV/OprConfSet",
          queryParameters: {
            "\$filter":
                " RoutingNo eq '$routingNo' and OperationType eq '$operationType' and OperationApps $operationApps",
            "\$format": 'json'
          });
      return OperationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorResponse.fromJson(e.response!.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
