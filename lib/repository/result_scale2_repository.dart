import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/provider/result_scale2_provider.dart';

class ResultScale2Repository {
  final _provider = ResultScale2Provider();

  Future<ResultScaleListResponse> fetchresultscale2(
      String orderNo, String activityNo, String activityWh, String objectName, String operationType) {
    return _provider.fetchresultscale2(
        orderNo, activityNo, activityWh, objectName, operationType);
  }
}
