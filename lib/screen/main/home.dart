import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/login/login.dart';
import 'package:dumping_system/screen/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthBloc authBloc = AuthBloc();
  String plant = '';
  String nameOperator = '';
  String nrpOperator = '';

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          plant = state.weerks;
          nameOperator = state.nameOperator;
          nrpOperator = state.nrpOperator;
          if (state.token.isNotEmpty &&
              state.nrpOperator.isNotEmpty &&
              state.nrpPengawas.isNotEmpty &&
              state.weerks.isNotEmpty) {
            return bodyHome(context);
          } else if (state.token.isNotEmpty &&
              state.nrpOperator.isEmpty &&
              state.nrpPengawas.isEmpty &&
              state.weerks.isEmpty) {
            return const ValidationScreen();
          } else if (state.token.isNotEmpty &&
              state.nrpOperator.isNotEmpty &&
              state.nrpPengawas.isEmpty &&
              state.weerks.isNotEmpty) {
            return const ValidationScreen();
          } else if (state.token.isNotEmpty &&
              state.nrpOperator.isEmpty &&
              state.nrpPengawas.isNotEmpty &&
              state.weerks.isEmpty) {
            return const ValidationScreen();
          }
        }
        return const LoginScreen();
      },
    );
  }

  Widget bodyHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/logo/dumping_system.png",
          fit: BoxFit.cover,
          width: 150,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(DeleteUserEvent());
              },
              child: Row(
                children: [
                  Text('$nameOperator ($nrpOperator)'),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.logout_outlined,
                    size: 20,
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.only(top: 100, bottom: 100),
                child: Text(
                  "What do you want to do ?",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .merge(const TextStyle(fontWeight: FontWeight.bold)),
                  textAlign: TextAlign.center,
                ),
              ),
              if (plant == '0101') ...[
                GestureDetector(
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: const DecorationImage(
                              image: AssetImage(
                                  "assets/images/bg_image/bg_mixing.jpg"),
                              fit: BoxFit.cover,
                              opacity: .4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Handover",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .merge(const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ) // button text
                        ),
                    onTap: () {
                      context.push("/handover");
                    }),
              ],
              GestureDetector(
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: const DecorationImage(
                            image: AssetImage(
                                "assets/images/bg_image/bg_mixing.jpg"),
                            fit: BoxFit.cover,
                            opacity: .4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Handover & Mixing",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .merge(const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ) // button text
                      ),
                  onTap: () {
                    context.push("/handover-mixing");
                  }),
              GestureDetector(
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      alignment: Alignment.center,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: const DecorationImage(
                            image: AssetImage(
                                "assets/images/bg_image/bg_weighing.jpg"),
                            fit: BoxFit.cover,
                            opacity: .4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Weighing",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .merge(const TextStyle(color: Colors.white)),
                      )),
                  onTap: () {
                    context.push("/weighing");
                  }),
              GestureDetector(
                  child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: const DecorationImage(
                            image: AssetImage(
                                "assets/images/bg_image/bg_confirmation 1.png"),
                            fit: BoxFit.cover,
                            opacity: .4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Confirmation",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .merge(const TextStyle(color: Colors.white)),
                      ) // button text
                      ),
                  onTap: () {
                    context.push("/confirmation");
                  })
            ],
          ),
        ),
      ),
    );
  }
}
