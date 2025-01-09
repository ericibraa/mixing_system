import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/expired_set.dart';
import 'package:dumping_system/screen/weighing/bloc/expired_set_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseTongScreen extends StatefulWidget {
  const ChooseTongScreen({super.key});

  @override
  State<ChooseTongScreen> createState() => _ChooseTongScreenState();
}

class _ChooseTongScreenState extends State<ChooseTongScreen> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  ExpiredSetBloc expiredSetBloc = ExpiredSetBloc();
  ResultsExpiredSet expiredSet = const ResultsExpiredSet();
  ScaleBloc scaleBloc = ScaleBloc();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    resultScaleBloc = BlocProvider.of<ResultScaleBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose weighing"),
        leading: IconButton(
          onPressed: () {
            _weighingCubit.setTab(WeighingStatus.weighing);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _weighingCubit),
          BlocProvider.value(value: expiredSetBloc),
          BlocProvider.value(value: scaleBloc),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<ExpiredSetBloc, ExpiredSetState>(
              listener: (context, state) {
                if (state is ExpiredSetLoaded) {
                  for (var data in state.expiredSet.d!.resultsExpiredSet!) {
                    expiredSet = data;
                  }
                  _weighingCubit.setExpired(expiredSet);
                }
              },
            ),
            BlocListener<ResultScaleBloc, ResultScaleState>(
              listener: (context, state) {
                if (state is ResultScaleLoaded) {
                  _weighingCubit
                      .setResultScaleList(state.resultScale.d!.results!);
                  _weighingCubit.setContainerCounter(
                      state.resultScale.d!.results!.length + 1);
                  _weighingCubit.setTotalContainer(
                      state.resultScale.d!.results![0].totalWadah!);
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
          ],
          child: BlocBuilder<WeighingCubit, WeighingState>(
            builder: (context, weighingState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (var dataWeighing in weighingState.containers) ...[
                        if (dataWeighing.operationDesc!.isNotEmpty) ...[
                          Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dataWeighing.activityWh} - ${dataWeighing.operationDesc}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            dataWeighing.activityNo ?? '',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            dataWeighing.operationApps ?? '',
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
                                _weighingCubit.selectedWeighing(dataWeighing);
                                _weighingCubit
                                    .setTab(WeighingStatus.scaleWeighing);

                                scaleBloc.add(
                                    SendDataScale(plant: weighingState.plant));
                                expiredSetBloc.add(GetExpiredSet(
                                    orderNo:
                                        weighingState.selectedOrder.orderNo!,
                                    activityNo: weighingState
                                        .selectedOperation.activityNo));
                                resultScaleBloc.add(SendDataResultScale(
                                    orderNo: weighingState
                                                .selectedOrder.orderNo !=
                                            null
                                        ? weighingState.selectedOrder.orderNo!
                                        : '',
                                    activityNo: dataWeighing.activityNo != null
                                        ? dataWeighing.activityNo!
                                        : '',
                                    activityWh:
                                        _weighingCubit.state.operationType ==
                                                'DECOCT'
                                            ? ''
                                            : dataWeighing.activityWh != null
                                                ? dataWeighing.activityWh!
                                                : '',
                                    operationType: _weighingCubit.state.operationType));
                                _weighingCubit.setTab(WeighingStatus.scale);
                                _weighingCubit
                                    .setPrevTab(WeighingStatus.chooseOperation);
                              },
                            ),
                          )
                        ]
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
