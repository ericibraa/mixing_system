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

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final token = await _provider.login(username, password);
      await persistPlantUsername(username);
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

  Future<String> hasNameOperator() async {
    var nameOperator = await storage.read(key: 'nameOperator');
    return nameOperator ?? '';
  }

  Future<String> hasNamePengawas() async {
    var namePengawas = await storage.read(key: 'namePengawas');
    return namePengawas ?? '';
  }

  Future<String> hasWeerks() async {
    var weerks = await storage.read(key: "weerks");
    return weerks ?? '';
  }

  Future<String> hasCsrfToken() async {
    var csrfToken = await storage.read(key: "csrf-token");
    return csrfToken ?? '';
  }

  Future<String> hasPlantUsername() async {
    var plantUsername = await storage.read(key: "plant-username");
    return plantUsername ?? '';
  }

  Future<void> persistToken(String token) async {
    await DioClient().setBasicAuth(token);
    await storage.write(key: "token", value: token);
  }

  Future<void> persistCsrfToken(String csrfToken) async {
    await storage.write(key: 'csrf-token', value: csrfToken);
  }

  Future<void> persistPlantUsername(String username) async {
    final value = username == '0102' || username.toLowerCase().contains('ckr')
        ? '0102'
        : '0101';
    await storage.write(key: 'plant-username', value: value);
  }

  Future<void> persistUser(
    String nrpOperator,
    String nrpPengawas,
    String nameOperator,
    String namePengawas,
    String weerks,
  ) async {
    await storage.write(key: "nrpOperator", value: nrpOperator);
    await storage.write(key: "nrpPengawas", value: nrpPengawas);
    await storage.write(key: "nameOperator", value: nameOperator);
    await storage.write(key: "namePengawas", value: namePengawas);
    await storage.write(key: "weerks", value: weerks);
  }

  Future<void> deleteUserData() async {
    await storage.delete(key: "nrpOperator");
    await storage.delete(key: "nrpPengawas");
    await storage.delete(key: "weerks");
    await storage.delete(key: 'nameOperator');
    await storage.delete(key: 'namePengawas');
  }
}
