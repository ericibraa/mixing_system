import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/wadah_set_provider.dart';

class WadahSetRepository {
  final _provider = WadahSetProvider();

  Future<TongResponse> fetchWadahSet(
      String routingNo, String activityNo, String operationType) {
    var tong = _provider.fetchWadahSet(routingNo, activityNo, operationType);
    return tong;
  }
}
