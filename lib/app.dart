import 'package:dumping_system/core/router.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  final bool isDev;
  const App({super.key, this.isDev = false});

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
            buttonColor: Color(0xFFF04482), textTheme: ButtonTextTheme.primary),
        colorSchemeSeed: const Color.fromARGB(255, 30, 41, 110),
      ),
      // builder dipake supaya Banner berada DI DALAM MaterialApp (mendapat Directionality)
      builder: (context, child) {
        final Widget effectiveChild = child ?? const SizedBox.shrink();
        print('App build - isDev: ${widget.isDev}');
        if (widget.isDev) {
          return Banner(
            message: 'DEV',
            location: BannerLocation.topStart,
            color: Colors.redAccent,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.white,
            ),
            child: effectiveChild,
          );
        }
        return effectiveChild;
      },
    );
  }
}
