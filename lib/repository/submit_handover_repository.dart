import 'package:dumping_system/models/request/submit_handover.dart';
import 'package:dumping_system/provider/submit_handover_provider.dart';

class SubmitHandoverRepository {
  final _provider = SubmitHandoverProvider();

  Future<String> submitHandover(SubmitHandoverRequest handoverData) async {
    return _provider.submitHandover(handoverData);
  }
}
