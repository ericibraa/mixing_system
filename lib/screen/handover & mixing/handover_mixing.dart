import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/material_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/operation_bloc.dart';
import 'package:dumping_system/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const List<String> optionsMaterial = <String>['DECOCT', 'CB', 'CK'];

class HandoverMixingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HandoverMixingScreen({Key? key}) : super(key: key);

  @override
  State<HandoverMixingScreen> createState() => _HandoverMixingScreenState();
}

class _HandoverMixingScreenState extends State<HandoverMixingScreen> {
  AuthBloc authBloc = AuthBloc();
  MaterialsBloc materialBloc = MaterialsBloc();
  OperationBloc operationBloc = OperationBloc();
  List<ResultsMaterial> listMaterials = List.empty();
  List<ResultsOperation> listOperation = List.empty();
  String materialValue = optionsMaterial.first;
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      option.material!;

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
        BlocProvider(
          create: (context) => materialBloc,
        ),
        BlocProvider(
          create: (context) => operationBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MaterialsBloc, MaterialsState>(
            listener: (context, state) {
              if (state is MaterialsLoaded) {
                listMaterials = state.material.d!.results!;
              }
            },
          ),
          BlocListener<OperationBloc, OperationState>(
            listener: (context, state) {
              if (state is OperationLoaded) {
                listOperation = state.operation.d!.results!;
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Handover & Mixing"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: TextFormField(
                            controller: plant,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelText: 'Plant'),
                            readOnly: true,
                          ),
                        ),
                        RawAutocomplete<ResultsMaterial>(
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
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                labelText: 'Material Code',
                              ),
                            );
                          },
                          optionsBuilder:
                              (TextEditingValue textEditingValue) async {
                            materialBloc.add(SendPlant(
                                plant: plant.text,
                                search: textEditingValue.text));
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<ResultsMaterial>.empty();
                            }
                            return listMaterials
                                .where((ResultsMaterial material) {
                              return material.material!.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            }).toList();
                          },
                          optionsViewBuilder: (BuildContext context,
                              AutocompleteOnSelected<ResultsMaterial>
                                  onSelected,
                              Iterable<ResultsMaterial> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  height: 200.0,
                                  width: 560,
                                  child: ListView.builder(
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final ResultsMaterial option =
                                          options.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(option);
                                          setState(() {
                                            productCode.text = option.material!;
                                          });
                                        },
                                        child: ListTile(
                                          title: Text(
                                              _displayStringForOption(option)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                              labelText: 'Select Date',
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                        DropdownButtonFormField(
                          value: materialValue,
                          items: optionsMaterial
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {},
                          iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                          dropdownColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              labelText: 'Operation Type'),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("Operation List"),
                        ),
                        BlocBuilder<OperationBloc, OperationState>(
                            builder: (context, state) {
                          if (state is OperationInitial) {
                            return const Loading();
                          } else if (state is OperationLoading) {
                            return const Loading();
                          } else if (state is OperationLoaded) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var dataOperation
                                      in state.operation.d!.results!)
                                    _operationList(context, dataOperation)
                                ],
                              ),
                            );
                          }
                          return const Center();
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: TextButton(
              onPressed: plant.text.isNotEmpty &&
                      materialValue.isNotEmpty &&
                      productCode.text.isNotEmpty &&
                      _dateController.text.isNotEmpty
                  ? () {
                      operationBloc.add(SendDataOperation(
                          plant: plant.text,
                          materialCode: productCode.text,
                          operationType: materialValue,
                          startDate: _dateController.text));
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: plant.text.isNotEmpty &&
                        materialValue.isNotEmpty &&
                        productCode.text.isNotEmpty &&
                        _dateController.text.isNotEmpty
                    ? Colors.black
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "Show operation list",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .merge(const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _operationList(BuildContext context, ResultsOperation listOperation) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF708BB2).withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                "Process order",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                listOperation.orderNo!,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          )
        ],
      ),
    );
  }
}
