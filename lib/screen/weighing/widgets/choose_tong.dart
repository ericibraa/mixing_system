import 'package:dumping_system/bloc/auth_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose weighing"),
        leading: BackButton(
          onPressed: () {
            _weighingCubit.setTab(WeighingStatus.weighing);
          },
        ),
      ),
      body: MultiBlocProvider(
        providers: [BlocProvider.value(value: _weighingCubit)],
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    for (var dataWeighing in weighingState.weighingList) ...[
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
                                dataWeighing.operationDesc ?? '',
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
                            _weighingCubit.setTab(WeighingStatus.scale);
                          },
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
