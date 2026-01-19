import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/operation_type_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/screen/weighing/bloc/expired_set_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zsdk/zsdk.dart';

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
  ScaleBloc scaleBloc = ScaleBloc();
  OperationTypeBloc operationTypeBloc = OperationTypeBloc();
  ExpiredSetBloc expiredSetBloc = ExpiredSetBloc();
  ResultOperation operation = const ResultOperation();
  String? materialValue;
  final plant = TextEditingController();
  final _dateController = TextEditingController();
  final productCode = TextEditingController();
  final batch = TextEditingController();
  static String _displayStringForOption(ResultsMaterial option) =>
      "${option.material!} - ${option.materialDesc}";
  String selectedOperation = '';
  WeighingCubit _weighingCubit = WeighingCubit();
  String title = '';
  final zsdk = ZSDK();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();

  void showSapNotification(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    resultScaleBloc = BlocProvider.of<ResultScaleBloc>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      _weighingCubit.setOperator(data.nameOperator);
      _weighingCubit.setPengawas(data.namePengawas);
      plant.text = data.weerks;
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
          BlocProvider<WeighingCubit>(
              create: (BuildContext context) => _weighingCubit),
          BlocProvider.value(value: orderBloc),
          BlocProvider<WeighingBloc>(
              create: (BuildContext context) => weighingBloc),
          BlocProvider<ScaleBloc>(create: (BuildContext context) => scaleBloc),
          BlocProvider<OperationTypeBloc>(
              create: (BuildContext context) => operationTypeBloc),
          BlocProvider<ExpiredSetBloc>(
              create: (BuildContext context) => expiredSetBloc),
          BlocProvider<OperationBloc>(
              create: (BuildContext context) => operationBloc)
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<MaterialsBloc, MaterialsState>(
                  listener: (context, state) {
                if (state is MaterialsLoaded) {
                  _weighingCubit.setMaterials(state.material.d!.results!);
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
              }),
              BlocListener<OrderBloc, OrderState>(listener: (context, state) {
                if (state is OrderLoaded) {
                  var order = state.order.d!.results!;
                  _weighingCubit.setOrders(order);
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
              }),
              BlocListener<OperationTypeBloc, OperationTypeState>(
                  listener: (context, state) {
                if (state is OperationTypeLoaded) {
                  var oprType = state.operationType.d!.results!;
                  for (var data in oprType) {
                    _weighingCubit.setMaterialsFull(data);
                    _weighingCubit.setOperationTypeList(
                        data.oprTypToDescNav!.resultsOprType!);
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
              BlocListener<OperationBloc, OperationState>(
                  listener: (context, state) {
                if (state is OperationLoaded) {
                  _weighingCubit
                      .setOperations(state.operation.d!.resultsOperationNo!);
                  _weighingCubit.setTab(WeighingStatus.selectOperation);
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
            ],
            child: BlocBuilder<WeighingCubit, WeighingState>(
                builder: (context, weighingState) {
              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: 100,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Weighing"),
                      Text(
                        "Operator: ${weighingState.operator}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "Pengawas: ${weighingState.pengawas}",
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
                                          suffixIcon: IconButton(
                                              onPressed:
                                                  textEditingController.clear,
                                              icon: const Icon(Icons.close))),
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
                                    return weighingState.materials
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
                                                  _weighingCubit
                                                      .setProductiSupervisor(option
                                                          .productiSupervisor!);
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
                                  controller: batch,
                                  onChanged: (value) {
                                    setState(() {
                                      batch.text = value;
                                    });
                                    if (value.length > 5) {
                                      operationTypeBloc.add(
                                          SendDataOperationType(
                                              startDate: _dateController.text,
                                              materialCode: productCode.text,
                                              plant: plant.text,
                                              batchFG: batch.text));
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
                              if (weighingState.operationTypes.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: DropdownButtonFormField(
                                    value: materialValue,
                                    items: weighingState.operationTypes
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
                              ],
                              if (weighingState.orders.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Orders",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    if (weighingState.orders.isNotEmpty) ...[
                                      _orderList(context, weighingState),
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
                                _weighingCubit.setDataOrder(
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

  Widget _orderList(BuildContext context, WeighingState weighingState) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          itemCount: weighingState.orders.length,
          itemBuilder: (BuildContext context, int index) {
            final selectedOrder = weighingState.orders[index];

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
                                  selectedOrder.orderNo!,
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
                                  selectedOrder.batchFG!,
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
                    _weighingCubit.setSelectedOrder(selectedOrder);
                    operationBloc.add(SendDataOperation(
                        operationType: selectedOrder.operationType!,
                        routingNo: selectedOrder.routingNo!,
                        operationApps: "eq '${weighingState.operationApps}'"));
                  },
                ));
          }),
    );
  }
}
