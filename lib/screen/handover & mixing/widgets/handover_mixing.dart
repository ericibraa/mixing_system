import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/operation_type_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/location_set_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/wadah_set_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HandoverMixingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HandoverMixingScreen({Key? key}) : super(key: key);

  @override
  State<HandoverMixingScreen> createState() => _HandoverMixingScreenState();
}

class _HandoverMixingScreenState extends State<HandoverMixingScreen> {
  AuthBloc authBloc = AuthBloc();
  MaterialsBloc materialBloc = MaterialsBloc();
  OrderBloc orderBloc = OrderBloc();
  OperationBloc operationBloc = OperationBloc();
  OperationTypeBloc operationTypeBloc = OperationTypeBloc();
  LocationSetBloc locationSetBloc = LocationSetBloc();
  WadahSetBloc wadahSetBloc = WadahSetBloc();
  TongBloc tongBloc = TongBloc();
  String? materialValue;
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  final batch = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  HandoverCubit _handoverCubit = HandoverCubit();
  String title = '';

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
        BlocProvider.value(value: _handoverCubit),
        BlocProvider.value(value: tongBloc),
        BlocProvider.value(value: wadahSetBloc),
        BlocProvider<OperationTypeBloc>(
            create: (BuildContext context) => operationTypeBloc),
        BlocProvider<LocationSetBloc>(
            create: (BuildContext context) => locationSetBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MaterialsBloc, MaterialsState>(
            listener: (context, state) {
              if (state is MaterialsLoaded) {
                _handoverCubit.setMaterials(state.material.d!.results!);
              } else if (state is MaterialsError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
              }
            },
          ),
          BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderLoaded) {
                _handoverCubit.setOrders(state.order.d!.results!);
              } else if (state is OrderError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
              }
            },
          ),
          BlocListener<OperationBloc, OperationState>(
              listener: (context, state) {
            if (state is OperationLoaded) {
              _handoverCubit
                  .setOperations(state.operation.d!.resultsOperationNo!);
              _handoverCubit.setTab(HandoverStatus.chooseOperation);
            } else if (state is OperationError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ));
            }
          }),
          BlocListener<OperationTypeBloc, OperationTypeState>(
              listener: (context, state) {
            if (state is OperationTypeLoaded) {
              var oprType = state.operationType.d!.results!;
              for (var data in oprType) {
                _handoverCubit
                    .setOperationType(data.oprTypToDescNav!.resultsOprType!);
              }
            } else if (state is OperationTypeError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ));
            }
          }),
        ],
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 100,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Handover & Mixing"),
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
                      context.go("/home");
                    },
                    icon: const Icon(Icons.chevron_left_rounded)),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        labelText: 'Material Code',
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        suffixIcon: IconButton(
                                            onPressed:
                                                textEditingController.clear,
                                            icon: const Icon(Icons.close))),
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
                                  return handoverState.materials
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
                                                operationTypeBloc.add(
                                                    SendDataOperationType(
                                                        startDate:
                                                            _dateController
                                                                .text,
                                                        materialCode:
                                                            productCode.text,
                                                        plant: plant.text,
                                                        batchFG: batch.text));
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
                                controller: batch,
                                onChanged: (value) {
                                  setState(() {
                                    batch.text = value;
                                  });
                                  if (value.length > 5) {
                                    operationTypeBloc.add(SendDataOperationType(
                                        startDate: _dateController.text,
                                        materialCode: productCode.text,
                                        plant: plant.text,
                                        batchFG: value));
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: 'Batch',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            if (handoverState.operationTypeList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: DropdownButtonFormField(
                                  value: materialValue,
                                  items: handoverState.operationTypeList
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
                                      switch (materialValue) {
                                        case 'DECOCT':
                                          title = '31';
                                          break;
                                        case 'CB':
                                          title = '32';
                                          break;
                                        case 'CK':
                                          title = '33';
                                          break;
                                        case 'LIQUID MIXING':
                                          title = '34';
                                          break;
                                        case 'SEMI SOLID MIXING':
                                          title = '45';
                                          break;
                                      }
                                      _handoverCubit.setOperationApps(title);
                                      _handoverCubit.setOrders([]);
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
                            if (handoverState.orders.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Orders",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              if (handoverState.orders.isNotEmpty) ...[
                                _orderList(context, handoverState),
                              ] else ...[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/bg_image/not_found.png",
                                          height: 250,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
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
                            ]
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
                              materialValue != null &&
                              productCode.text.isNotEmpty &&
                              batch.text.isNotEmpty
                          ? () {
                              orderBloc.add(SendDataOrder(
                                  plant: plant.text,
                                  materialCode: productCode.text,
                                  operationType: materialValue!,
                                  startDate: _dateController.text,
                                  batchFG: batch.text));
                              _handoverCubit.setDataOrder(
                                  plant.text,
                                  productCode.text,
                                  _dateController.text,
                                  materialValue!);
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: plant.text.isNotEmpty &&
                                materialValue != null &&
                                productCode.text.isNotEmpty &&
                                batch.text.isNotEmpty
                            ? Colors.black
                            : Colors.grey[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Show Orders",
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

  Widget _orderList(BuildContext context, HandoverState handoverState) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          itemCount: handoverState.orders.length,
          itemBuilder: (BuildContext context, int index) {
            final selectedOrder = handoverState.orders[index];

            return Card(
                elevation: 7,
                shadowColor: Colors.blueGrey[100],
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '(${selectedOrder.material}) ${selectedOrder.materialDesc}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Process order",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedOrder.orderNo ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedOrder.batchFG ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
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
                  onTap: () {
                    _handoverCubit.setSelectedOrder(selectedOrder);
                    operationBloc.add(SendDataOperation(
                        operationType: selectedOrder.operationType ?? '',
                        routingNo: selectedOrder.routingNo ?? '',
                        operationApps: "ge '20'"));
                  },
                ));
          }),
    );
  }
}
