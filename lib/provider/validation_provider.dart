import 'package:dio/dio.dart';
import 'package:dumping_system/models/response/validation.dart';
import 'package:dumping_system/provider/provider.dart';

class ValidationProvider extends Provider {
  Future<ValidationResponse> validation(String nrp, String title) async {
    try {
      // Response response = await dio.get(
      //     "${apiUrl.dumpingApi}/FImp_User?Nrp='$nrp'&Title='$title'&\$format=json");
      Response response = await dio.get("${apiUrl.dumpingApi}/FImp_User",
          queryParameters: {
            'Nrp': "'$nrp'",
            'Title': "'$title'",
            '\$format': "json"
          });
      return ValidationResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      throw Exception("Exception occurred: $error stackTrace: $stacktrace");
    }
  }
}
