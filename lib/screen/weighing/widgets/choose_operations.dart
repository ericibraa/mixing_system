import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/expired_set_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_2_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseOperations extends StatefulWidget {
  const ChooseOperations({super.key});

  @override
  State<ChooseOperations> createState() => _ChooseOperationsState();
}

class _ChooseOperationsState extends State<ChooseOperations> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  WeighingBloc weighingBloc = WeighingBloc();
  ScaleBloc scaleBloc = ScaleBloc();
  ExpiredSetBloc expiredSetBloc = ExpiredSetBloc();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();
  ResultScale2Bloc resultScale2Bloc = ResultScale2Bloc();

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeighingCubit>(
          create: (context) => _weighingCubit,
        ),
        BlocProvider<WeighingBloc>(create: (context) => weighingBloc),
        BlocProvider<ScaleBloc>(create: (context) => scaleBloc),
        BlocProvider<ExpiredSetBloc>(create: (context) => expiredSetBloc),
        BlocProvider<ResultScaleBloc>(create: (context) => resultScaleBloc),
        BlocProvider<ResultScale2Bloc>(create: (context) => resultScale2Bloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WeighingBloc, WeighingBlocState>(
            listener: (context, state) {
              if (state is WeighingLoaded) {
                scaleBloc.add(SendDataScale(plant: _weighingCubit.state.plant));
                expiredSetBloc.add(GetExpiredSet(
                    orderNo: _weighingCubit.state.selectedOrder.orderNo != null
                        ? _weighingCubit.state.selectedOrder.orderNo!
                        : '',
                    activityNo:
                        _weighingCubit.state.selectedOperation.activityNo));
                if (_weighingCubit.state.selectedOperation.operationDesc !=
                    _weighingCubit.state.selectedOperation.operationDesc2) {
                  _weighingCubit.setIsclone(false);
                  resultScaleBloc.add(SendDataResultScale(
                      orderNo: _weighingCubit.state.selectedOrder.orderNo ?? '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo,
                      activityWh:
                          _weighingCubit.state.selectedContainer.activityWh ??
                              ''));
                } else {
                  _weighingCubit.setIsclone(true);
                  resultScale2Bloc.add(SendDataResultScale2(
                      orderNo:
                          _weighingCubit.state.selectedOrder.orderNo != null
                              ? _weighingCubit.state.selectedOrder.orderNo!
                              : '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo,
                      activityWh: _weighingCubit.state.operationType == 'DECOCT'
                          ? ''
                          : _weighingCubit.state.selectedContainer.activityWh !=
                                  null
                              ? _weighingCubit
                                  .state.selectedContainer.activityWh!
                              : '',
                      objectName:
                          _weighingCubit.state.selectedOperation.objectName!));
                }
                _weighingCubit.setTab(WeighingStatus.scale);
                _weighingCubit.setPrevTab(WeighingStatus.chooseOperation);
                _weighingCubit.resetResultScale();
                _weighingCubit.resetScaleWeighing();
              }
            },
          ),
          BlocListener<ScaleBloc, ScaleState>(
            listener: (context, state) {
              if (state is ScaleLoaded) {
                _weighingCubit.setEquipments(state.scale.d!.results!);
              }
            },
          ),
          BlocListener<ExpiredSetBloc, ExpiredSetState>(
              listener: (context, state) {
            if (state is ExpiredSetLoaded) {
              for (var expiredSet in state.expiredSet.d!.resultsExpiredSet!) {
                _weighingCubit.setExpired(expiredSet);
              }
            }
          }),
          BlocListener<ResultScaleBloc, ResultScaleState>(
              listener: (context, state) {
            if (state is ResultScaleLoaded) {
              _weighingCubit.setResultScaleList(state.resultScale.d!.results!);
            }
          }),
          BlocListener<ResultScale2Bloc, ResultScale2State>(
              listener: (context, state) {
            if (state is ResultScale2Loaded) {
              _weighingCubit.setResultScales2(state.resultScale2.d!.results!);
            }
          }),
        ],
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Choose Operation"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: weighingState.chooseOperations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final selectedOperation =
                        weighingState.chooseOperations[index];

                    return Card(
                      elevation:
                          weighingState.chooseOperations[index].lastOperation ==
                                  ''
                              ? 7
                              : 0,
                      shadowColor: Colors.blueGrey[100],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedOperation.operationDesc,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    )),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Operation number",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.black,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedOperation.activityNo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Operation Apps",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.black,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedOperation.operationApps,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          _weighingCubit
                              .setSelectedOperation(selectedOperation);
                          weighingBloc.add(SendDataWeighing(
                              routingNo: selectedOperation.routingNo,
                              internalCntr: selectedOperation.internalCntr,
                              activityNo: selectedOperation.activityNo,
                              operationType: weighingState.operationType,
                              operationApps: weighingState.operationApps));
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
