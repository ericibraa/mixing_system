import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChooseWeighing extends StatefulWidget {
  const ChooseWeighing({super.key});

  @override
  State<ChooseWeighing> createState() => _ChooseWeighingState();
}

class _ChooseWeighingState extends State<ChooseWeighing> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  ScaleBloc scaleBloc = ScaleBloc();
  var plant = '';

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant = data.weerks;
    }
    super.initState();
  }

  final List<Map<String, dynamic>> chooseWeighing = [
    {"id": "1", "title": "Print Tara", "next": WeighingStatus.printTara},
    {"id": "2", "title": "Weighing", "next": WeighingStatus.weighing}
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<ScaleBloc>(create: (context) => scaleBloc)],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ScaleBloc, ScaleState>(
            listener: (context, state) {
              if (state is ScaleLoaded) {
                print("ddfjgdfgfd");
                _weighingCubit.setEquipments(state.scale.d!.results!);
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
              title: const Text("Choose Weighing"),
              leading: IconButton(
                  onPressed: () {
                    context.go("/home");
                  },
                  icon: const Icon(Icons.chevron_left_rounded))),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: chooseWeighing.length,
              itemBuilder: (BuildContext context, int index) {
                final selectedWeighing = chooseWeighing[index];
                return Card(
                  elevation: 7,
                  shadowColor: Colors.blueGrey[100],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        selectedWeighing["title"]!,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    onTap: () {
                      scaleBloc.add(SendDataScale(plant: plant));
                      _weighingCubit.setTab(selectedWeighing['next']);
                      _weighingCubit.setPrevTab(WeighingStatus.chooseWeighing);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
