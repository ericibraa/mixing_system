import 'package:dumping_system/models/request/flag_materials.dart';
import 'package:dumping_system/provider/flag_scan_provider.dart';

class FlagScanRepository {
  final _provider = FlagScanProvider();

  Future<String> fetchSubmitFlag(FlagMaterials flagMaterials) async {
    return _provider.fetchSubmitFlag(flagMaterials);
  }
}
