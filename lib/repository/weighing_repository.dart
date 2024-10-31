import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/weighing_provider.dart';

class WeighingRepository {
  final _provider = WeighingProvider();

  Future<TongResponse> fetchweighing(
    String routingNo,
    String internalCntr,
    String activityNo,
    String operationType,
    String operationApps,
  ) {
    return _provider.fetchweighing(
        routingNo, internalCntr, activityNo, operationType, operationApps);
  }
}
