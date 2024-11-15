import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_type_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/screen/confirmation/bloc/operation_confirmation_bloc.dart';
import 'package:dumping_system/screen/confirmation/bloc/yield_set_bloc.dart';
import 'package:dumping_system/screen/confirmation/cubit/confirmation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  AuthBloc authBloc = AuthBloc();
  ConfirmationCubit _confirmationCubit = ConfirmationCubit();
  MaterialsBloc materialBloc = MaterialsBloc();
  OrderBloc orderBloc = OrderBloc();
  OperationTypeBloc operationTypeBloc = OperationTypeBloc();
  OperationConfirmationBloc operationConfirmationBloc =
      OperationConfirmationBloc();
  YieldSetBloc yieldSetBloc = YieldSetBloc();
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  String? materialValue;

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _confirmationCubit = BlocProvider.of<ConfirmationCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      _confirmationCubit.setOperator(data.nameOperator);
      _confirmationCubit.setPengawas(data.namePengawas);
      plant.text = data.weerks;
    }
    materialBloc.add(SendPlant(plant: plant.text));
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    super.initState();
  }

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
      operationTypeBloc.add(SendDataOperationType(
          startDate: _dateController.text,
          materialCode: productCode.text,
          plant: plant.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<MaterialsBloc>(
            create: (BuildContext context) => materialBloc,
          ),
          BlocProvider<OperationTypeBloc>(
              create: (BuildContext context) => operationTypeBloc),
          BlocProvider<OrderBloc>(create: (BuildContext context) => orderBloc),
          BlocProvider<OperationConfirmationBloc>(
              create: (BuildContext context) => operationConfirmationBloc),
          BlocProvider<YieldSetBloc>(
              create: (BuildContext contex) => yieldSetBloc)
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<MaterialsBloc, MaterialsState>(
                  listener: (context, state) {
                if (state is MaterialsLoaded) {
                  _confirmationCubit.setMaterials(state.material.d!.results!);
                }
              }),
              BlocListener<OperationTypeBloc, OperationTypeState>(
                  listener: (context, state) {
                if (state is OperationTypeLoaded) {
                  for (var operationType in state.operationType.d!.results!) {
                    _confirmationCubit.setOperationTypes(
                        operationType.oprTypToDescNav!.resultsOprType!);
                  }
                }
              }),
              BlocListener<OrderBloc, OrderState>(listener: (context, state) {
                if (state is OrderLoaded) {
                  var order = state.order.d!.results!;
                  _confirmationCubit.setOrders(order);
                }
              }),
              BlocListener<OperationConfirmationBloc,
                  OperationConfirmationState>(listener: (context, state) {
                if (state is OperationConfirmationSuccess) {
                  _confirmationCubit.setOperations(
                      state.operationConfirmation.d!.resultsOperationNo!);
                }
              }),
              BlocListener<YieldSetBloc, YieldSetState>(
                  listener: (context, state) {
                if (state is YieldSetSuccess) {
                  for (var yieldSet in state.yieldSet.d!.results!) {
                    _confirmationCubit.setYieldSet(yieldSet);
                  }
                  _confirmationCubit
                      .setTab(ConfirmationStatus.formConfirmation);
                  _confirmationCubit.setStartDate();
                }
              })
            ],
            child: BlocBuilder<ConfirmationCubit, ConfirmationState>(
                builder: (context, confirmationState) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Confirmation"),
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
                                    return confirmationState.materials
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
                                                  _confirmationCubit
                                                      .setProductiSupervisor(option
                                                          .productiSupervisor!);
                                                  operationTypeBloc.add(
                                                      SendDataOperationType(
                                                          startDate:
                                                              _dateController
                                                                  .text,
                                                          materialCode:
                                                              productCode.text,
                                                          plant: plant.text));
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
                              if (confirmationState
                                  .operationTypes.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: DropdownButtonFormField(
                                    value: materialValue,
                                    items: confirmationState.operationTypes
                                        .map<DropdownMenuItem<String>>(
                                            (ResultsOprType item) {
                                      return DropdownMenuItem<String>(
                                        value: item.operationType,
                                        child: Text(item.operationType!),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        materialValue = newValue!;
                                        _confirmationCubit.setOrders([]);
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
                              ],
                              if (confirmationState.orders.isNotEmpty)
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
                                    if (confirmationState
                                        .orders.isNotEmpty) ...[
                                      for (var dataOrder
                                          in confirmationState.orders)
                                        _orderList(context, dataOrder,
                                            confirmationState),
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
                        onPressed: () {
                          orderBloc.add(SendDataOrder(
                              plant: plant.text,
                              materialCode: productCode.text,
                              operationType: materialValue!,
                              startDate: _dateController.text));
                          _confirmationCubit.setDataOrder(
                              plant.text,
                              productCode.text,
                              _dateController.text,
                              materialValue!);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: plant.text.isNotEmpty &&
                                  materialValue != null &&
                                  productCode.text.isNotEmpty &&
                                  _dateController.text.isNotEmpty
                              ? Colors.black
                              : Colors.grey[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Show Confirmation List",
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

  Widget _orderList(BuildContext context, ResultsOrder order,
      ConfirmationState confirmationState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              _confirmationCubit.setSelectedOrder(order);
              operationConfirmationBloc.add(GetOperationConfirmation(
                  order.routingNo!,
                  order.operationType!,
                  "eq '${confirmationState.operationApps}'"));
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
                  '(${order.material!}) ${order.materialDesc}',
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
                          order.orderNo!,
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
                          order.batchFG!,
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
        BlocProvider.value(value: _confirmationCubit),
        BlocProvider.value(value: yieldSetBloc)
      ],
      child: BlocBuilder<ConfirmationCubit, ConfirmationState>(
        builder: (context, confirmationState) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: Scaffold(
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
                                    selectedOperation.operationDesc ?? '',
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
                                            selectedOperation.activityNo ?? '',
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
                                            selectedOperation.operationApps ??
                                                '',
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
                                    selectedOperation.routingNo!,
                                    selectedOperation.internalCntr!,
                                    selectedOperation.activityNo!));
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
            ),
          );
        },
      ),
    );
  }
}
