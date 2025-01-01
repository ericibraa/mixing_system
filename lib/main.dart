import 'package:dumping_system/app.dart';
import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/core/config/environment.dart';
import 'package:dumping_system/core/dio/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final AuthBloc authBloc = AuthBloc();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    Environment().initConfig(Environment.prod);
  } else {
    Environment().initConfig(Environment.dev);
  } 

  await DioClient().initDio();

  authBloc.add(InitAuth());

  await Future.delayed(const Duration(seconds: 1));
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthBloc>(create: (BuildContext context) => authBloc)
  ], child: const App()));
}
