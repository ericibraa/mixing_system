import 'package:dumping_system/core/router.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: Colors.white,
              buttonTheme: const ButtonThemeData(
                  buttonColor: Color(0xFFF04482),
                  textTheme: ButtonTextTheme.primary),
              colorSchemeSeed: const Color.fromARGB(255, 30, 41, 110)));
  }
}
