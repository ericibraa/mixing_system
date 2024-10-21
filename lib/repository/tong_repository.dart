import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/provider/tong_provider.dart';

class TongRepository {
  final _provider = TongProvider();

  Future<TongResponse> fetchtong(String routingNo, String activityNo,
      String controlRecipe, String operationType) {
    var tong = _provider.fetchtong(
        routingNo, activityNo, controlRecipe, operationType);
    return tong;
  }
}
