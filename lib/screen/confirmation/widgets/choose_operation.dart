import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/confirmation/bloc/yield_set_bloc.dart';
import 'package:dumping_system/screen/confirmation/cubit/confirmation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseOperation extends StatefulWidget {
  const ChooseOperation({super.key});

  @override
  State<ChooseOperation> createState() => _ChooseOperationState();
}

class _ChooseOperationState extends State<ChooseOperation> {
  AuthBloc authBloc = AuthBloc();
  ConfirmationCubit _confirmationCubit = ConfirmationCubit();
  YieldSetBloc yieldSetBloc = YieldSetBloc();

  @override
  void initState() {
    super.initState();
    _confirmationCubit = BlocProvider.of<ConfirmationCubit>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ConfirmationCubit>(
              create: (context) => _confirmationCubit),
          BlocProvider<YieldSetBloc>(create: (context) => yieldSetBloc)
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<YieldSetBloc, YieldSetState>(
                listener: (context, state) {
              if (state is YieldSetSuccess) {
                for (var yieldSet in state.yieldSet.d!.results!) {
                  _confirmationCubit.setYieldSet(yieldSet);
                }
                _confirmationCubit.setTab(ConfirmationStatus.formConfirmation);
              }
            })
          ],
          child: BlocBuilder<ConfirmationCubit, ConfirmationState>(
              builder: (context, confirmationState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Choose Operation No'),
                leading: IconButton(
                    onPressed: () {
                      _confirmationCubit
                          .setTab(ConfirmationStatus.confirmation);
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
                        itemCount: confirmationState.operations.length,
                        itemBuilder: (BuildContext context, int index) {
                          final selectedOperation =
                              confirmationState.operations[index];

                          final isSelected =
                              confirmationState.selectedOperation.activityNo ==
                                  selectedOperation.activityNo;

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: isSelected ? Colors.black : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedOperation.operationDesc,
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedOperation.activityNo,
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedOperation.operationApps,
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
                                ],
                              ),
                              onTap: () {
                                _confirmationCubit
                                    .setSelectedOperation(selectedOperation);
                                yieldSetBloc.add(GetYieldSet(
                                    selectedOperation.routingNo,
                                    selectedOperation.internalCntr,
                                    selectedOperation.activityNo));
                              },
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
