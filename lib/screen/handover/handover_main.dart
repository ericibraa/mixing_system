import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover/widget/handover.dart';
import 'package:dumping_system/screen/handover/widget/scantong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HandoverMainPage extends StatelessWidget {
  const HandoverMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HandoverCubit(),
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
  MaterialsBloc materialBloc = MaterialsBloc();
  OperationBloc operationBloc = OperationBloc();
  OrderBloc orderBloc = OrderBloc();
  HandoverCubit handoverCubit = HandoverCubit();

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => handoverCubit,
        child: BlocListener<HandoverCubit, HandoverState>(
          listener: (context, state) {},
          child: BlocBuilder<HandoverCubit, HandoverState>(
            builder: (context, state) {
              return IndexedStack(
                index: state.tab.index,
                children: const [HandoverScreen(), ScanTongScreen()],
              );
            },
          ),
        ),
      ),
    );
  }
}
