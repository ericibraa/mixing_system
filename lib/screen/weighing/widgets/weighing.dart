import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/widgets/handover_mixing.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class WeighingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const WeighingScreen({Key? key}) : super(key: key);

  @override
  State<WeighingScreen> createState() => _WeighingScreenState();
}

class _WeighingScreenState extends State<WeighingScreen> {
  AuthBloc authBloc = AuthBloc();
  MaterialsBloc materialBloc = MaterialsBloc();
  String materialValue = optionsMaterial.first;
  List<ResultsMaterial> listMaterials = List.empty();
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  WeighingCubit weighingCubit = WeighingCubit();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    weighingCubit = BlocProvider.of<WeighingCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant.text = data.weerks;
    }
    materialBloc.add(SendPlant(plant: plant.text));
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<MaterialsBloc>(
            create: (BuildContext context) => materialBloc,
          ),
          BlocProvider<WeighingCubit>(
              create: (BuildContext context) => weighingCubit)
        ],
        child: BlocListener<MaterialsBloc, MaterialsState>(
            listener: (context, state) {
          if (state is MaterialsLoaded) {
            setState(() {
              listMaterials = state.material.d!.results!;
            });
          }
        }, child: BlocBuilder<WeighingCubit, WeighingState>(
                builder: (context, weighingState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Weighing"),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Form(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                              controller: plant,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Plant',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: RawAutocomplete<ResultsMaterial>(
                              displayStringForOption: _displayStringForOption,
                              fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Material Code',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                  ),
                                );
                              },
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) async {
                                materialBloc.add(SendPlant(
                                  plant: plant.text,
                                  search: textEditingValue.text,
                                ));
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<
                                      ResultsMaterial>.empty();
                                }
                                return listMaterials
                                    .where((ResultsMaterial material) {
                                  return material.material!
                                      .toLowerCase()
                                      .contains(
                                          textEditingValue.text.toLowerCase());
                                }).toList();
                              },
                              optionsViewBuilder: (
                                BuildContext context,
                                AutocompleteOnSelected<ResultsMaterial>
                                    onSelected,
                                Iterable<ResultsMaterial> options,
                              ) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    color: Colors.white,
                                    child: SizedBox(
                                      height: 200.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.93,
                                      child: ListView.builder(
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final ResultsMaterial option =
                                              options.elementAt(index);
                                          return ListTile(
                                            onTap: () {
                                              onSelected(option);
                                              setState(() {
                                                productCode.text =
                                                    option.material!;
                                              });
                                            },
                                            title: Text(
                                              _displayStringForOption(option),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: const Icon(Icons.calendar_today),
                                labelText: 'Select Date',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                        ]))
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 10,
              color: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      weighingCubit.setTab(WeighingStatus.scaleWeighing);
                    },
                    style: TextButton.styleFrom(
                      // backgroundColor: plant.text.isNotEmpty &&
                      //         materialValue.isNotEmpty &&
                      //         productCode.text.isNotEmpty &&
                      //         _dateController.text.isNotEmpty
                      //     ? Colors.black
                      //     : Colors.grey[500],
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Show Weighing List",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          );
        })));
  }
}
