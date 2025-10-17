import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/volume.dart';
import 'package:dumping_system/provider/provider.dart';

class VolumeProvider extends Provider {
  Future<Volume> fetchVolume(String plant) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_MATERIAL_SRV/FImp_Volume",
          queryParameters: {
            'Plant': "'$plant'",
            "\$format": 'json'
          });
      return Volume.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}