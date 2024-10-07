import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/provider/material_provider.dart';

class MaterialRepository {
  final _provider = MaterialProvider();

  Future<MaterialResponse> fetchmaterial(String plant) {
    return _provider.fetchmaterial(plant);
  }
}
