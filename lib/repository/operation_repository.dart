import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/operation_provider.dart';

class OperationRepository {
  final _provider = OperationProvider();

  Future<OperationResponse> fetchoperation(
      String routingNo, String operationType, String operationApps) {
    return _provider.fetchoperation(routingNo, operationType, operationApps);
  }
}
