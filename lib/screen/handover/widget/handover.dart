import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const List<String> optionsMaterial = <String>['DECOCT', 'CB', 'CK'];

class HandoverScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HandoverScreen({Key? key}) : super(key: key);

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  AuthBloc authBloc = AuthBloc();
  MaterialsBloc materialBloc = MaterialsBloc();
  OrderBloc orderBloc = OrderBloc();
  OperationBloc operationBloc = OperationBloc();
  List<ResultsMaterial> listMaterials = List.empty();
  List<ResultsOrder> listOrder = List.empty();
  List<ResultOperation> listOperation = List.empty();
  String materialValue = optionsMaterial.first;
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  HandoverCubit _handoverCubit = HandoverCubit();

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
    _handoverCubit = BlocProvider.of<HandoverCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant.text = data.weerks;
      _handoverCubit.setOperator(data.nameOperator);
      _handoverCubit.setPengawas(data.namePengawas);
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
        BlocProvider<OperationBloc>(
          create: (BuildContext context) => operationBloc,
        ),
        BlocProvider<OrderBloc>(
          create: (BuildContext context) => orderBloc,
        ),
        BlocProvider<HandoverCubit>(
            create: (BuildContext context) => _handoverCubit)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MaterialsBloc, MaterialsState>(
            listener: (context, state) {
              if (state is MaterialsLoaded) {
                setState(() {
                  listMaterials = state.material.d!.results!;
                });
              }
            },
          ),
          BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderLoaded) {
                setState(() {
                  listOrder = state.order.d!.results!;
                });
              }
            },
          ),
          BlocListener<OperationBloc, OperationState>(
              listener: (context, state) {
            if (state is OperationLoaded) {}
          }),
        ],
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Handover"),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        .contains(textEditingValue.text
                                            .toLowerCase());
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.93,
                                        child: ListView.builder(
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: DropdownButtonFormField(
                                value: materialValue,
                                items: optionsMaterial
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    materialValue = value!;
                                  });
                                },
                                iconEnabledColor: Colors.black,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: 'Operation Type',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                if (state is OrderLoaded) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "Operation List",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                      if (state
                                          .order.d!.results!.isNotEmpty) ...[
                                        for (var dataOrder
                                            in state.order.d!.results!)
                                          _orderList(context, dataOrder),
                                      ] else ...[
                                        Center(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  "assets/images/bg_image/not_found.png",
                                                  height: 250,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Text(
                                                    "No operation list data",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ]
                                    ],
                                  );
                                }
                                return const Center();
                              },
                            ),
                          ],
                        ),
                      ),
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
                      onPressed: plant.text.isNotEmpty &&
                              materialValue.isNotEmpty &&
                              productCode.text.isNotEmpty &&
                              _dateController.text.isNotEmpty
                          ? () {
                              orderBloc.add(SendDataOrder(
                                  plant: plant.text,
                                  materialCode: productCode.text,
                                  operationType: materialValue,
                                  startDate: _dateController.text));
                              _handoverCubit.setDataOrder(
                                  plant.text,
                                  productCode.text,
                                  _dateController.text,
                                  materialValue);
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: plant.text.isNotEmpty &&
                                materialValue.isNotEmpty &&
                                productCode.text.isNotEmpty &&
                                _dateController.text.isNotEmpty
                            ? Colors.black
                            : Colors.grey[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Show Operation List",
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
          },
        ),
      ),
    );
  }

  Widget _orderList(BuildContext context, ResultsOrder listOrder) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              _handoverCubit.setOrderList(listOrder);
              operationBloc.add(SendDataOperation(
                  operationType: listOrder.operationType!,
                  routingNo: listOrder.routingNo!,
                  operationApps: "eq '1'"));
              return _showOperationNo(context);
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '(${listOrder.material!}) ${listOrder.materialDesc}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Process order",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listOrder.orderNo!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Batch",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listOrder.batchFG!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.black87,
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
        ),
      ),
    );
  }

  Widget _showOperationNo(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _handoverCubit),
        BlocProvider.value(value: operationBloc)
      ],
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return BlocBuilder<OperationBloc, OperationState>(
              builder: (context, state) {
                if (state is OperationLoading) {
                  return const Loading();
                }
                if (state is OperationLoaded) {
                  listOperation = state.operation.d!.resultsOperationNo!;
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Choose Operation No'),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please choose an operation number:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: listOperation.length,
                              itemBuilder: (BuildContext context, int index) {
                                final operationNo = listOperation[index];

                                final isSelected = handoverState
                                        .selectedOperationNumber.activityNo ==
                                    operationNo.activityNo;

                                return Card(
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                          operationNo.operationDesc ?? '',
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
                                                  operationNo.activityNo ?? '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black,
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
                                    onTap: () {
                                      _handoverCubit.setOperation(operationNo);
                                      _handoverCubit.setOperationApps('2');
                                      _handoverCubit
                                          .setTab(HandoverStatus.scantong);
                                      Navigator.of(context).pop();
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
                } else {
                  return const Center();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
