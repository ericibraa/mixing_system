import 'package:dumping_system/screen/confirmation/confirmation_main.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/handover_mixing_main.dart';
import 'package:dumping_system/screen/handover/handover_main.dart';
import 'package:dumping_system/screen/login/login.dart';
import 'package:dumping_system/screen/main/home.dart';
import 'package:dumping_system/screen/weighing/weighing_main.dart';
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
            path: "/login", builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: "/handover",
          builder: (context, state) => const HandoverMainPage(),
        ),
        GoRoute(
          path: "/handover-mixing",
          builder: (context, state) => const HandoverMixingMainPage(),
        ),
        GoRoute(
          path: "/weighing",
          builder: (context, state) => const WeighingMainPage(),
        ),
        GoRoute(
          path: "/confirmation",
          builder: (context, state) => const ConfirmationMainPage(),
        )
      ],
      errorBuilder: errorWidget);

  static GoRouter get router => _router;
}
