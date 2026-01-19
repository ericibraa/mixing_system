import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
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
  TongBloc tongBloc = TongBloc();
  bool isSelected = false;

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
          BlocProvider<TongBloc>(create: (context) => tongBloc),
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
                    isSelected = false;
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

                        isSelected =
                            handoverState.selectedOperation.activityNo ==
                                selectedOperation.activityNo;
                        return Card(
                          elevation:
                              handoverState.operations[index].lastOperation ==
                                      ''
                                  ? 7
                                  : 0,
                          shadowColor: Colors.blueGrey[100],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color:
                              handoverState.operations[index].lastOperation ==
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
                                          color: handoverState.operations.any(
                                                  (element) =>
                                                      element.lastOperation ==
                                                      '')
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
                                                  color: handoverState
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
                            ),
                            onTap:
                                handoverState.operations[index].lastOperation ==
                                        ''
                                    ? () {
                                        _handoverCubit
                                            .setOperation(selectedOperation);
                                        _handoverCubit.setOperationApps('20');
                                        _handoverCubit
                                            .setTab(HandoverStatus.scantong);
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
        }));
  }
}
