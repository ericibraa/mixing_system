import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:dumping_system/screen/weighing/widgets/choose_operations.dart';
import 'package:dumping_system/screen/weighing/widgets/choose_tong.dart';
import 'package:dumping_system/screen/weighing/widgets/scale_weighing.dart';
import 'package:dumping_system/screen/weighing/widgets/weighing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeighingMainPage extends StatelessWidget {
  const WeighingMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeighingCubit(),
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
  WeighingCubit weighingCubit = WeighingCubit();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();

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
            create: (context) => weighingCubit,
          ),
          BlocProvider<ResultScaleBloc>(
            create: (context) => resultScaleBloc,
          ),
        ],
        child: BlocListener<WeighingCubit, WeighingState>(
          listener: (context, state) {},
          child: BlocBuilder<WeighingCubit, WeighingState>(
            builder: (context, state) {
              return IndexedStack(
                index: state.tab.index,
                children: const [
                  WeighingScreen(),
                  ChooseTongScreen(),
                  ScaleWeighingScreen(),
                  ChooseOperations(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
