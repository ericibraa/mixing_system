import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/repository/auth_repository.dart';
import 'package:dumping_system/screen/login/login.dart';
import 'package:dumping_system/screen/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthBloc authBloc = AuthBloc();
  AuthRepository authRepository = AuthRepository();
  String plant = '';
  String nameOperator = '';
  String nrpOperator = '';
  String plantUsername = '';

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    authRepository.hasPlantUsername();
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
          plantUsername = state.plantUsername;
          if (state.token.isNotEmpty) {
            return bodyHome(context);
          } else {
            return const LoginScreen();
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
          "assets/images/logo/mixing_system.png",
          fit: BoxFit.cover,
          width: 100,
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20),
        //     child: GestureDetector(
        //       onTap: () {
        //         context.read<AuthBloc>().add(DeleteUserEvent());
        //       },
        //       child: const Row(
        //         children: [
        //           Text('Log Out'),
        //           SizedBox(width: 10),
        //           Icon(
        //             Icons.logout_outlined,
        //             size: 20,
        //           )
        //         ],
        //       ),
        //     ),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.only(top: 80, bottom: 100),
                child: Text(
                  "What do you want to do ?",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .merge(const TextStyle(fontWeight: FontWeight.bold)),
                  textAlign: TextAlign.center,
                ),
              ),
              if (plantUsername == '0101') ...[
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
                      context.read<AuthBloc>().add(DeleteUserEvent());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ValidationScreen(
                            to: "/handover",
                          ),
                        ),
                      );
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
                    context.read<AuthBloc>().add(DeleteUserEvent());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValidationScreen(
                          to: "/handover-mixing",
                        ),
                      ),
                    );
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
                    context.read<AuthBloc>().add(DeleteUserEvent());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValidationScreen(
                          to: "/weighing",
                        ),
                      ),
                    );
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
                    context.read<AuthBloc>().add(DeleteUserEvent());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValidationScreen(
                          to: "/confirmation",
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
