import 'package:dumping_system/core/dio/dio_client.dart';
import 'package:dumping_system/provider/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final _provider = AuthProvider();

  final FlutterSecureStorage storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      synchronizable: false,
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<String> login(String username, String password) async {
    try {
      final token = await _provider.login(username, password);
      return token;
    } catch (error) {
      print("Login failed: $error");
      throw Exception("Login failed: $error");
    }
  }

  Future<String> hasToken() async {
    var token = await storage.read(key: "token");
    return token ?? '';
  }

  Future<String> hasOperation() async {
    var nrpOperator = await storage.read(key: "nrpOperator");
    return nrpOperator ?? '';
  }

  Future<String> hasPengawas() async {
    var nrpPengawas = await storage.read(key: "nrpPengawas");
    return nrpPengawas ?? '';
  }

  Future<String> hasWeerks() async {
    var weerks = await storage.read(key: "weerks");
    return weerks ?? '';
  }

  Future<void> persistToken(String token) async {
    await DioClient().setBasicAuth(token);
    await storage.write(key: "token", value: token);
  }

  Future<void> persistUser(
      String nrpOperator, String nrpPengawas, String weerks) async {
    await storage.write(key: "nrpOperator", value: nrpOperator);
    await storage.write(key: "nrpPengawas", value: nrpPengawas);
    await storage.write(key: "weerks", value: weerks);
  }

  Future<void> deleteUserData() async {
    await storage.delete(key: "nrpOperator");
    await storage.delete(key: "nrpPengawas");
    await storage.delete(key: "weerks");
  }
}
