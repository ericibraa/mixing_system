import 'package:dumping_system/models/request/submit_weighing.dart';
import 'package:dumping_system/provider/submit_weighing.dart';

class SubmitWeighingRepository {
  final _provider = SubmitWeighingProvider();

  Future<ResponseSubmitWeighing> submitweighing(
      SubmitWeighing weighingData) async {
    return _provider.submitweighing(weighingData);
  }
}
