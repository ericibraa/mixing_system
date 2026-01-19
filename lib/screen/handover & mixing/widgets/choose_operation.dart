import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/location_set_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseOperation extends StatefulWidget {
  const ChooseOperation({super.key});

  @override
  State<ChooseOperation> createState() => _ChooseOperationState();
}

class _ChooseOperationState extends State<ChooseOperation> {
  AuthBloc authBloc = AuthBloc();
  HandoverCubit _handoverCubit = HandoverCubit();
  LocationSetBloc locationSetBloc = LocationSetBloc();
  TongBloc tongBloc = TongBloc();

  @override
  void initState() {
    super.initState();
    _handoverCubit = BlocProvider.of<HandoverCubit>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HandoverCubit>(
              create: (BuildContext context) => _handoverCubit),
          BlocProvider<LocationSetBloc>(create: (context) => locationSetBloc),
          BlocProvider<TongBloc>(create: (context) => tongBloc),
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<LocationSetBloc, LocationSetState>(
                  listener: (context, state) {
                if (state is LocationSetLoaded) {
                  if (state.locationSet.d!.locationSet!.isEmpty) {
                    tongBloc.add(SendDataTong(
                        routingNo:
                            _handoverCubit.state.selectedOperation.routingNo,
                        activityNo:
                            _handoverCubit.state.selectedOperation.activityNo,
                        controlRecipe: _handoverCubit
                            .state.selectedOperation.controlRecipe,
                        operationType: _handoverCubit.state.operationType));
                    if (int.parse(_handoverCubit
                            .state.selectedOperation.operationApps) >
                        20) {
                      _handoverCubit.setTab(HandoverStatus.scantongmaterial);
                      _handoverCubit.setPrevTab(HandoverStatus.handover);
                    } else {
                      _handoverCubit.setTab(HandoverStatus.scantong);
                      _handoverCubit.setPrevTab(HandoverStatus.handover);
                    }
                  } else {
                    _handoverCubit
                        .setLocationSet(state.locationSet.d!.locationSet!);
                    _handoverCubit.setTab(HandoverStatus.chooseLocation);
                    _handoverCubit.setPrevTab(HandoverStatus.handover);
                  }
                } else if (state is LocationSetError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ));
                }
              }),
              BlocListener<TongBloc, TongState>(listener: (context, state) {
                if (state is TongLoaded) {
                  _handoverCubit.setResultTong(state.tong.d!.resultsTong!);
                  for (var fullpack in state.tong.d!.resultsTong!) {
                    _handoverCubit
                        .setFullpack(fullpack.wadToMatNav!.resultsFullPack!);
                  }
                } else if (state is TongError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ));
                }
              }),
            ],
            child: BlocBuilder<HandoverCubit, HandoverState>(
                builder: (context, handoverState) {
              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: 100,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Choose Operation"),
                      Text(
                        "Operator: ${handoverState.operator}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "Pengawas: ${handoverState.pengawas}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                  leading: IconButton(
                      onPressed: () {
                        _handoverCubit.setTab(HandoverStatus.handover);
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
                          itemCount: handoverState.operations.length,
                          itemBuilder: (BuildContext context, int index) {
                            final selectedOperation =
                                handoverState.operations[index];

                            final isSelected =
                                handoverState.selectedOperation.activityNo ==
                                    selectedOperation.activityNo;

                            return Card(
                              elevation: handoverState
                                          .operations[index].lastOperation ==
                                      ''
                                  ? 7
                                  : 0,
                              shadowColor: Colors.blueGrey[100],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: handoverState
                                          .operations[index].lastOperation ==
                                      ''
                                  ? isSelected
                                      ? Colors.black
                                      : Colors.grey[100]
                                  : Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedOperation.operationDesc,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: handoverState
                                                          .operations[index]
                                                          .lastOperation ==
                                                      ''
                                                  ? isSelected
                                                      ? Colors.white
                                                      : Colors.black
                                                  : Colors.grey[600],
                                            ),
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
                                                      color: handoverState
                                                                  .operations[
                                                                      index]
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
                                                      color: handoverState
                                                                  .operations[
                                                                      index]
                                                                  .lastOperation ==
                                                              ''
                                                          ? isSelected
                                                              ? Colors.white
                                                              : Colors.black
                                                          : Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      color: handoverState
                                                                  .operations[
                                                                      index]
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
                                                      color: handoverState
                                                                  .operations[
                                                                      index]
                                                                  .lastOperation ==
                                                              ''
                                                          ? isSelected
                                                              ? Colors.white
                                                              : Colors.black
                                                          : Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: handoverState
                                            .operations[index].lastOperation ==
                                        ''
                                    ? () {
                                        _handoverCubit
                                            .setOperation(selectedOperation);
                                        locationSetBloc.add(GetLocationSet(
                                            selectedOperation.routingNo,
                                            selectedOperation.internalCntr,
                                            selectedOperation.activityNo));
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
            })));
  }
}
