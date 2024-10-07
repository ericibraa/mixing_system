import 'package:dumping_system/core/config/config.dart';
import 'package:dumping_system/core/config/dev_config.dart';
import 'package:dumping_system/core/config/prod_config.dart';

class Environment {
  factory Environment() {
    return _singleton;
  }

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  static const String dev = 'DEV';
  static const String staging = 'STAGING';
  static const String prod = 'PROD';

  late BaseConfig config;

  initConfig(String environment) {
    config = _getConfig(environment);
  }

  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.prod:
        return ProdConfig();
      default:
        return DevConfig();
    }
  }
}
