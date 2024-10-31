import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/provider/scale_provider.dart';

class ScaleRepository {
  final _provider = ScaleProvider();

  Future<ScaleResponse> fetchscale(String plant) {
    return _provider.fetchscale(plant);
  }
}
