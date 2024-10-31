import 'package:dumping_system/provider/submit_handover_mixing_provider.dart';

import '../models/request/submit_handover_mixing_request.dart';

class SubmitHandoverMixingRepository {
  final _provider = SubmitHandoverMixingProvider();

  Future<String> submitHandoverMixing(
      SubmitHandoverMixingRequest handoverMixingData) async {
    return _provider.submitHandoverMixing(handoverMixingData);
  }
}
