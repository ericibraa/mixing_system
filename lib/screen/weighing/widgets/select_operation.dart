import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/screen/weighing/bloc/expired_set_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectOperation extends StatefulWidget {
  const SelectOperation({super.key});

  @override
  State<SelectOperation> createState() => _SelectOperationState();
}

class _SelectOperationState extends State<SelectOperation> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  WeighingBloc weighingBloc = WeighingBloc();
  ScaleBloc scaleBloc = ScaleBloc();
  ExpiredSetBloc expiredSetBloc = ExpiredSetBloc();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<WeighingCubit>(create: (context) => _weighingCubit),
          BlocProvider<WeighingBloc>(create: (context) => weighingBloc),
          BlocProvider<ScaleBloc>(create: (context) => scaleBloc),
          BlocProvider<ExpiredSetBloc>(create: (context) => expiredSetBloc),
          BlocProvider<ResultScaleBloc>(create: (context) => resultScaleBloc),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<WeighingBloc, WeighingBlocState>(
                listener: (context, state) {
              if (state is WeighingLoaded) {
                var weighing = state.weighing.d!.resultsTong!;
                if (weighing.length >= 2) {
                  _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                  _weighingCubit.setTab(WeighingStatus.scaleWeighing);
                } else {
                  _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                  if (state.weighing.d!.resultsTong!.isNotEmpty) {
                    _weighingCubit
                        .selectedWeighing(state.weighing.d!.resultsTong![0]);
                  }
                  scaleBloc
                      .add(SendDataScale(plant: _weighingCubit.state.plant));
                  expiredSetBloc.add(GetExpiredSet(
                      orderNo:
                          _weighingCubit.state.selectedOrder.orderNo != null
                              ? _weighingCubit.state.selectedOrder.orderNo!
                              : '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo));
                  resultScaleBloc.add(SendDataResultScale(
                      orderNo: _weighingCubit.state.selectedOrder.orderNo ?? '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo,
                      activityWh:
                          _weighingCubit.state.selectedContainer.activityWh ??
                              ''));

                  _weighingCubit.setTab(WeighingStatus.scale);
                  _weighingCubit.setPrevTab(WeighingStatus.weighing);
                }
              }
            }),
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
                _weighingCubit
                    .setResultScaleList(state.resultScale.d!.results!);
                if (state.resultScale.d!.results!.isNotEmpty) {
                  _weighingCubit.setTotalContainer(
                      state.resultScale.d!.results![0].totalWadah!);
                }
              }
            }),
          ],
          child: BlocBuilder<WeighingCubit, WeighingState>(
              builder: (context, weighingState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Choose Operation No'),
                leading: IconButton(
                    onPressed: () {
                      _weighingCubit.setTab(WeighingStatus.weighing);
                    },
                    icon: const Icon(Icons.chevron_left_rounded)),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please choose an operation number:',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: weighingState.operations.length,
                        itemBuilder: (BuildContext context, int index) {
                          final selectedOperation =
                              weighingState.operations[index];

                          final isSelected =
                              weighingState.selectedOperation.activityNo ==
                                  selectedOperation.activityNo;

                          return Card(
                            elevation:
                                weighingState.operations[index].lastOperation ==
                                        ''
                                    ? 7
                                    : 0,
                            shadowColor: Colors.blueGrey[100],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color:
                                weighingState.operations[index].lastOperation ==
                                        ''
                                    ? isSelected
                                        ? Colors.black
                                        : Colors.grey[100]
                                    : Colors.grey[400],
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
                                            color: weighingState
                                                        .operations[index]
                                                        .lastOperation ==
                                                    ''
                                                ? isSelected
                                                    ? Colors.white
                                                    : Colors.black
                                                : Colors.grey[600],
                                          )),
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
                                                  color: weighingState
                                                              .operations[index]
                                                              .lastOperation ==
                                                          ''
                                                      ? isSelected
                                                          ? Colors.white
                                                          : Colors.black
                                                      : Colors.grey[600],
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedOperation.activityNo,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: weighingState
                                                              .operations[index]
                                                              .lastOperation ==
                                                          ''
                                                      ? isSelected
                                                          ? Colors.white
                                                          : Colors.black
                                                      : Colors.grey[600],
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
                                                  color: weighingState
                                                              .operations[index]
                                                              .lastOperation ==
                                                          ''
                                                      ? isSelected
                                                          ? Colors.white
                                                          : Colors.black
                                                      : Colors.grey[600],
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedOperation.operationApps,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: weighingState
                                                              .operations[index]
                                                              .lastOperation ==
                                                          ''
                                                      ? isSelected
                                                          ? Colors.white
                                                          : Colors.black
                                                      : Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: weighingState
                                          .operations[index].lastOperation ==
                                      ''
                                  ? selectedOperation.operationDesc2!.isEmpty
                                      ? () {
                                          _weighingCubit.setSelectedOperation(
                                              selectedOperation);
                                          weighingBloc.add(SendDataWeighing(
                                              routingNo:
                                                  selectedOperation.routingNo,
                                              internalCntr: selectedOperation
                                                  .internalCntr,
                                              activityNo:
                                                  selectedOperation.activityNo,
                                              operationType:
                                                  weighingState.operationType,
                                              operationApps:
                                                  weighingState.operationApps));
                                        }
                                      : () {
                                          final List<ResultOperation>
                                              operations = [
                                            selectedOperation,
                                            selectedOperation.copyWith(
                                                operationDesc: selectedOperation
                                                    .operationDesc2)
                                          ];
                                          _weighingCubit
                                              .setChooseOperations(operations);
                                          _weighingCubit.setTab(
                                              WeighingStatus.chooseOperation);
                                        }
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ));
  }
}
