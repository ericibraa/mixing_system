import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/provider/order_provider.dart';

class OrderRepository {
  final _provider = OrderProvider();

  Future<OrderResponse> fetchorder(String startDate, String materialCode,
      String plant, String operationType, String batchFG) {
    return _provider.fetchorder(
        startDate, materialCode, plant, operationType, batchFG);
  }
}
