import 'package:dumping_system/models/response/label.dart';
import 'package:dumping_system/provider/label_provider.dart';

class LabelRepository {
  final _provider = LabelProvider();

  Future<LabelResponse> fetchlabel(String orderNo, String activityNo) {
    return _provider.fetchlabel(orderNo, activityNo);
  }
}
