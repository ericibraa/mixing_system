import 'package:dumping_system/models/request/handover_flag.dart';
import 'package:dumping_system/provider/handoverFlag_provider.dart';

class HandoverFlagRepository {
  final _provider = HandoverflagProvider();

  Future<String> fetchHandoverFlag(HandoverFlag handoverFlag) async {
    return _provider.fetchHandoverFlag(handoverFlag);
  }
}
