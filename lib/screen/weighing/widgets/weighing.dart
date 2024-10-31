import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/screen/weighing/bloc/weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:dumping_system/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

List<Map<String, String>> optionsMaterial = [
  {'id': '3', 'title': 'DECOCT'},
  {'id': '4', 'title': 'CB'},
  {'id': '5', 'title': 'CK'}
];

class WeighingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const WeighingScreen({Key? key}) : super(key: key);

  @override
  State<WeighingScreen> createState() => _WeighingScreenState();
}

class _WeighingScreenState extends State<WeighingScreen> {
  AuthBloc authBloc = AuthBloc();
  MaterialsBloc materialBloc = MaterialsBloc();
  OrderBloc orderBloc = OrderBloc();
  OperationBloc operationBloc = OperationBloc();
  WeighingBloc weighingBloc = WeighingBloc();
  List<ResultOperation> listOperation = List.empty();
  ResultOperation operation = const ResultOperation();
  String? materialValue = optionsMaterial[0]['id'];
  List<ResultsMaterial> listMaterials = List.empty();
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  WeighingCubit _weighingCubit = WeighingCubit();
  String title = '';

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
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
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
              create: (BuildContext context) => _weighingCubit),
          BlocProvider.value(value: orderBloc),
          BlocProvider<WeighingBloc>(
              create: (BuildContext context) => weighingBloc),
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
              }),
              BlocListener<WeighingBloc, WeighingBlocState>(
                  listener: (context, state) {
                if (state is WeighingLoaded) {
                  var weighing = state.weighing.d!.resultsTong!;
                  if (weighing.length > 1) {
                    _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                    _weighingCubit.setTab(WeighingStatus.scaleWeighing);
                  } else {
                    _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                    _weighingCubit.setTab(WeighingStatus.scale);
                  }
                }
              }),
              BlocListener<OrderBloc, OrderState>(listener: (context, state) {
                if (state is OrderLoaded) {
                  var order = state.order.d!.results!;
                  _weighingCubit.setOrders(order);
                }
              })
            ],
            child: BlocBuilder<WeighingCubit, WeighingState>(
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
                                  displayStringForOption:
                                      _displayStringForOption,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        labelText: 'Material Code',
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                      ),
                                    );
                                  },
                                  optionsBuilder: (TextEditingValue
                                      textEditingValue) async {
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                  _displayStringForOption(
                                                      option),
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
                                    suffixIcon:
                                        const Icon(Icons.calendar_today),
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
                                          (Map<String, String> item) {
                                    return DropdownMenuItem<String>(
                                      value: item['id'],
                                      child: Text(item['title']!),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      materialValue = newValue!;
                                      switch (materialValue) {
                                        case '3':
                                          title = 'DECOCT';
                                          break;
                                        case '4':
                                          title = 'CB';
                                          break;
                                        case '5':
                                          title = 'CK';
                                          break;
                                      }
                                      _weighingCubit.setOrders([]);
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
                              if (weighingState.orders.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Order List",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    if (weighingState.orders.isNotEmpty) ...[
                                      for (var dataOrder
                                          in weighingState.orders)
                                        _orderList(
                                            context, dataOrder, weighingState),
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
                                                padding: const EdgeInsets.only(
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
                                )
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
                        onPressed: plant.text.isNotEmpty &&
                                materialValue!.isNotEmpty &&
                                productCode.text.isNotEmpty &&
                                _dateController.text.isNotEmpty
                            ? () {
                                orderBloc.add(SendDataOrder(
                                    plant: plant.text,
                                    materialCode: productCode.text,
                                    operationType: title,
                                    startDate: _dateController.text));
                                _weighingCubit.setDataOrder(
                                    plant.text,
                                    productCode.text,
                                    _dateController.text,
                                    materialValue!,
                                    title);
                              }
                            : null,
                        style: TextButton.styleFrom(
                          backgroundColor: plant.text.isNotEmpty &&
                                  materialValue!.isNotEmpty &&
                                  productCode.text.isNotEmpty &&
                                  _dateController.text.isNotEmpty
                              ? Colors.black
                              : Colors.grey[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Show Weighing List",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _orderList(BuildContext context, ResultsOrder listOrder,
      WeighingState weighingState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              _weighingCubit.setOrderList(listOrder);
              operationBloc.add(SendDataOperation(
                  operationType: listOrder.operationType!,
                  routingNo: listOrder.routingNo!,
                  operationApps: "eq '${weighingState.operationApps}'"));
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
        BlocProvider.value(value: _weighingCubit),
        BlocProvider.value(value: operationBloc),
        BlocProvider.value(value: weighingBloc)
      ],
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return BlocBuilder<OperationBloc, OperationState>(
              builder: (context, state) {
                if (state is OperationLoading) {
                  return const Loading();
                }
                if (state is OperationLoaded) {
                  for (var operations
                      in state.operation.d!.resultsOperationNo!) {
                    operation = operations;
                  }
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

                                final isSelected =
                                    weighingState.operationList.activityNo ==
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
                                                  operationNo.operationApps ??
                                                      '',
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
                                      _weighingCubit
                                          .setOperationList(operation);
                                      weighingBloc.add(SendDataWeighing(
                                          routingNo: operationNo.routingNo!,
                                          internalCntr:
                                              operationNo.internalCntr!,
                                          activityNo: operationNo.activityNo!,
                                          operationType:
                                              weighingState.operationType,
                                          operationApps:
                                              weighingState.operationApps));
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
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
