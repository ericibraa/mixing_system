import 'package:dumping_system/models/response/yield_set.dart';
import 'package:dumping_system/provider/yield_set_provider.dart';

class YieldSetRepository {
  final _provider = YieldSetProvider();

  Future<YieldSetResponse> fetchYieldSet(
      String routingNo, String internalCntr, String activityNo) {
    return _provider.fetchYieldSet(routingNo, internalCntr, activityNo);
  }
}
