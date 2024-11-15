import 'package:dumping_system/models/request/submit_confirmation.dart';
import 'package:dumping_system/provider/submit_confirmation.dart';

class SubmitConfirmationRepository {
  final _provider = SubmitConfirmationProvider();

  Future<String> submitConfirmation(
      SubmitConfirmationRequest confirmationData) async {
    return _provider.submitConfirmation(confirmationData);
  }
}
