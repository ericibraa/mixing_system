import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/operation_confirmation_provider.dart';

class OperationConfirmationRepository {
  final _provider = OperationConfirmationProvider();

  Future<OperationResponse> fetchOperationConfirmation(
      String routingNo, String operationType, String operationApps) {
    return _provider.fetchOperationConfirmation(
        routingNo, operationType, operationApps);
  }
}
