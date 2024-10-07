import 'package:dumping_system/models/response/validation.dart';
import 'package:dumping_system/provider/validation_provider.dart';

class ValidationRepository {
  final _provider = ValidationProvider();

  Future<ValidationResponse> validation(String nrp, String title) {
    return _provider.validation(nrp, title);
  }
}
