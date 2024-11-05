import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/provider/provider.dart';

class MaterialProvider extends Provider {
  Future<MaterialResponse> fetchmaterial(String plant) async {
    try {
      Response response = await dio.get(
          "${apiUrl.dumpingApi}/ZDMP_GET_MATERIAL_SRV/FImp_Material?Plant='$plant'&\$format=json");
      return MaterialResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
