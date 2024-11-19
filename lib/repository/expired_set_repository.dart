import 'package:dumping_system/models/response/expired_set.dart';
import 'package:dumping_system/provider/expired_set_provider.dart';

class ExpiredSetRepository {
  final _provider = ExpiredSetProvider();

  Future<ExpiredsetResponse> fetchExpiredSet(
      String orderNo, String activityNo) {
    return _provider.fetchExpiredSet(orderNo, activityNo);
  }
}
