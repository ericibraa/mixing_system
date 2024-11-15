import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/confirmation/cubit/confirmation_cubit.dart';
import 'package:dumping_system/screen/confirmation/widgets/confirmation.dart';
import 'package:dumping_system/screen/confirmation/widgets/form_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmationMainPage extends StatelessWidget {
  const ConfirmationMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfirmationCubit(),
      child: const MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  AuthBloc authBloc = AuthBloc();
  ConfirmationCubit confirmationCubit = ConfirmationCubit();

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => confirmationCubit,
          )
        ],
        child: BlocListener<ConfirmationCubit, ConfirmationState>(
          listener: (context, state) {},
          child: BlocBuilder<ConfirmationCubit, ConfirmationState>(
            builder: (context, state) {
              return IndexedStack(
                index: state.tab.index,
                children: const [
                  ConfirmationScreen(),
                  FormConfirmationScreen()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
