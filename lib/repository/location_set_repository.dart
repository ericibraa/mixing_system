import 'package:dumping_system/models/response/locationset.dart';
import 'package:dumping_system/provider/locationset_provider.dart';

class LocationSetRepository {
  final _provider = LocationSetProvider();

  Future<LocationSetResponse> fetchLocationSet(
      String routingNo, String internalCntr, String activityNo) {
    return _provider.fetchLocationSet(routingNo, internalCntr, activityNo);
  }
}
