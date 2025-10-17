import 'package:dumping_system/models/response/volume.dart';
import 'package:dumping_system/provider/volume_provider.dart';

class VolumeRepository {
  final _provider = VolumeProvider();

  Future<Volume> fetchVolume(String plant) {
    return _provider.fetchVolume(plant);
  }
}
