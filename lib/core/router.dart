import 'package:dumping_system/screen/handover%20&%20mixing/handover_mixing.dart';
import 'package:dumping_system/screen/login/login.dart';
import 'package:dumping_system/screen/main/home.dart';
import 'package:dumping_system/screen/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static Widget errorWidget(BuildContext context, GoRouterState state) =>
      const Text("Not found");

  static final GoRouter _router = GoRouter(
      initialLocation: "/home",
      routes: [
        GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
        GoRoute(
            path: "/validation",
            builder: (context, state) => const ValidationScreen()),
        GoRoute(
            path: "/login", builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: "/handover-mixing",
          builder: (context, state) => const HandoverMixingScreen(),
        )
      ],
      errorBuilder: errorWidget);

  static GoRouter get router => _router;
}
