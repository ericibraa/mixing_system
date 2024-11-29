import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/provider/operation_type.dart';

class OperationTypeRepository {
  final _provider = OperationTypeProvider();

  Future<OperationTypeResponse> fetchoperationtype(
      String startDate, String materialCode, String plant, String batchFG) {
    return _provider.fetchoperationtype(
        startDate, materialCode, plant, batchFG);
  }
}
