import 'package:dumping_system/app.dart';
import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/core/config/environment.dart';
import 'package:dumping_system/core/dio/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final AuthBloc authBloc = AuthBloc();

/// Override-able at build/run time:
/// flutter run --dart-define=IS_DEV=true
/// flutter build apk --dart-define=IS_DEV=true
const bool isDev = bool.fromEnvironment('IS_DEV', defaultValue: !kReleaseMode);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // pilih environment berdasarkan flag IS_DEV (dart-define) atau release mode
  if (isDev) {
    Environment().initConfig(Environment.dev);
  } else {
    Environment().initConfig(Environment.prod);
  }

  await DioClient().initDio();

  authBloc.add(InitAuth());

  // optional delay (bisa dihapus jika ga perlu)
  await Future.delayed(const Duration(seconds: 1));

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (BuildContext context) => authBloc),
      ],
      child: App(isDev: isDev), // pass flag ke App
    ),
  );
}
