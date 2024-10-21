import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/provider/materialset_provider.dart';

class MaterialsetRepository {
  final _provider = MaterialsetProvider();

  Future<ResponseMaterialset> fetchmaterialset(
      String routingNo, String activityNo, String operationType) {
    return _provider.fetchmaterialset(routingNo, activityNo, operationType);
  }
}
