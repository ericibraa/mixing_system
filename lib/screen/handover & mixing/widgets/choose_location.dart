import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/wadah_set_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  AuthBloc authBloc = AuthBloc();
  HandoverCubit _handoverCubit = HandoverCubit();
  WadahSetBloc wadahSetBloc = WadahSetBloc();
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
          BlocProvider<WadahSetBloc>(
              create: (BuildContext context) => wadahSetBloc),
          BlocProvider<TongBloc>(create: (BuildContext context) => tongBloc)
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<WadahSetBloc, WadahSetState>(
              listener: (context, state) {
                if (state is WadahSetLoaded) {
                  _handoverCubit.setResultTong(state.wadahSet.d!.resultsTong!);
                  List<ResultsFullPack> fullpacks = [];
                  for (var fullpack in state.wadahSet.d!.resultsTong!) {
                    if (fullpack.wadToMatNav!.resultsFullPack != null) {
                      fullpacks.addAll(fullpack.wadToMatNav!.resultsFullPack!);
                    }
                  }
                  _handoverCubit.setFullpack(fullpacks);
                  _handoverCubit.setTab(HandoverStatus.scanTongResultsWeighing);
                  _handoverCubit.setPrevTab(HandoverStatus.chooseLocation);
                }
              },
            ),
            BlocListener<TongBloc, TongState>(listener: (context, state) {
              if (state is TongLoaded) {
                _handoverCubit.setResultTong(state.tong.d!.resultsTong!);
                List<ResultsFullPack> fullpacks = [];
                for (var fullpack in state.tong.d!.resultsTong!) {
                  if (fullpack.wadToMatNav!.resultsFullPack != null) {
                    fullpacks.addAll(fullpack.wadToMatNav!.resultsFullPack!);
                  }
                  _handoverCubit.setFullpack(fullpacks);
                }
                print(_handoverCubit.state.isMixing);
                var opApps = _handoverCubit.state.locationSets
                    .any((item) => item.operationApps == '0010' || item.operationApps == '0020' );
                if (opApps) {
                  if (!_handoverCubit.state.isMixing) {
                    _handoverCubit.setTab(HandoverStatus.scantong);
                    _handoverCubit.setPrevTab(HandoverStatus.chooseLocation);
                  } else {
                    _handoverCubit.setPrevTab(HandoverStatus.chooseLocation);
                    _handoverCubit.setTab(HandoverStatus.scantongmaterial);
                    _handoverCubit.SetMixing(false);
                  }
                }
              }
            }),
          ],
          child: BlocBuilder<HandoverCubit, HandoverState>(
              builder: (context, handoverState) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Choose Location"),
                  leading: IconButton(
                    onPressed: () {
                      _handoverCubit.setTab(HandoverStatus.chooseOperation);
                    },
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
                body: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: handoverState.locationSets.length,
                            itemBuilder: (BuildContext context, int index) {
                              final selectedLocation =
                                  handoverState.locationSets[index];

                              final isSelected = handoverState
                                      .selectedLocationSet.activityNo ==
                                  selectedLocation.activityNo;

                              return Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${selectedLocation.operationDesc!} (Handover)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black),
                                        ),
                                        const SizedBox(height: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Line",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              selectedLocation.line!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      _handoverCubit.setSelectedLocationSet(
                                          selectedLocation);
                                      if (int.parse(selectedLocation
                                              .operationApps!) >=
                                          31) {
                                        wadahSetBloc.add(GetWadahSet(
                                            selectedLocation.routingNo!,
                                            selectedLocation.activityNo!,
                                            handoverState.operationType));
                                      } else {
                                        _handoverCubit.SetMixing(false);
                                        tongBloc.add(SendDataTong(
                                            routingNo:
                                                selectedLocation.routingNo!,
                                            activityNo:
                                                selectedLocation.activityNo!,
                                            controlRecipe: handoverState
                                                .selectedOperation
                                                .controlRecipe,
                                            operationType: handoverState
                                                .selectedOrder.operationType!));
                                      }
                                    },
                                  ));
                            }),
                      ],
                    )),
                bottomNavigationBar: handoverState.locationSets.isNotEmpty &&
                        int.parse(
                                handoverState.selectedOperation.operationApps) >
                            20
                    ? BottomAppBar(
                        elevation: 10,
                        color: Colors.transparent,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: TextButton(
                                    onPressed: () {
                                      _handoverCubit.SetMixing(true);
                                      tongBloc.add(SendDataTong(
                                          routingNo: handoverState
                                              .locationSets[0].routingNo!,
                                          activityNo: handoverState
                                              .locationSets[0].activityNo!,
                                          controlRecipe: handoverState
                                              .selectedOperation.controlRecipe,
                                          operationType: handoverState
                                              .selectedOrder.operationType!));
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Next Process (Mixing)",
                                        style:
                                            TextStyle(color: Colors.white))))))
                    : null);
          }),
        ));
  }
}
