import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/provider/result_scale_provider.dart';

class ResultScaleRepository {
  final _provider = ResultScaleProvider();

  Future<ResultScaleListResponse> fetchresultscale(
      String orderNo, String activityNo, String activityWh) {
    return _provider.fetchresultscale(orderNo, activityNo, activityWh);
  }
}
