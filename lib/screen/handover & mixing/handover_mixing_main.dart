import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/wadah_set_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/choose_location.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/handover_mixing.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/scan_tong.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/scan_tong_material.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/scan_tong_results_weighing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HandoverMixingMainPage extends StatelessWidget {
  const HandoverMixingMainPage({Key? key}) : super(key: key);

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
  TongBloc tongBloc = TongBloc();
  WadahSetBloc wadahSetBloc = WadahSetBloc();

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
                children: const [
                  HandoverMixingScreen(),
                  ScanTongMaterialScreen(),
                  ScanTongMaterialSetScreen(),
                  ScanTongResultsWeighing(),
                  ChooseLocation()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
