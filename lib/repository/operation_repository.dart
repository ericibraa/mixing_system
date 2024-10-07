import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/provider/operation_provider.dart';

class OperationalRepository {
  final _provider = OperationProvider();

  Future<OperationResponse> fetchoperation(String startDate,
      String materialCode, String plant, String operationType) {
    return _provider.fetchoperation(
        startDate, materialCode, plant, operationType);
  }
}
