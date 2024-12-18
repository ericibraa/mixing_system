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
import 'package:intl/intl.dart';
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
          plant: plant.text,
          batchFG: batch.text));
    }
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
                }
              }),
              BlocListener<WeighingBloc, WeighingBlocState>(
                  listener: (context, state) {
                if (state is WeighingLoaded) {
                  var weighing = state.weighing.d!.resultsTong!;
                  if (weighing.length >= 2) {
                    _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                    _weighingCubit.setTab(WeighingStatus.scaleWeighing);
                  } else {
                    _weighingCubit.setWeighing(state.weighing.d!.resultsTong!);
                    if (state.weighing.d!.resultsTong!.isNotEmpty) {
                      _weighingCubit
                          .selectedWeighing(state.weighing.d!.resultsTong![0]);
                    }
                    scaleBloc
                        .add(SendDataScale(plant: _weighingCubit.state.plant));
                    expiredSetBloc.add(GetExpiredSet(
                        orderNo:
                            _weighingCubit.state.selectedOrder.orderNo != null
                                ? _weighingCubit.state.selectedOrder.orderNo!
                                : '',
                        activityNo:
                            _weighingCubit.state.selectedOperation.activityNo));
                    resultScaleBloc.add(SendDataResultScale(
                        orderNo:
                            _weighingCubit.state.selectedOrder.orderNo ?? '',
                        activityNo:
                            _weighingCubit.state.selectedOperation.activityNo,
                        activityWh:
                            _weighingCubit.state.selectedContainer.activityWh ??
                                ''));

                    _weighingCubit.setTab(WeighingStatus.scale);
                    _weighingCubit.setPrevTab(WeighingStatus.weighing);
                  }
                }
              }),
              BlocListener<OrderBloc, OrderState>(listener: (context, state) {
                if (state is OrderLoaded) {
                  var order = state.order.d!.results!;
                  _weighingCubit.setOrders(order);
                }
              }),
              BlocListener<ScaleBloc, ScaleState>(
                listener: (context, state) {
                  if (state is ScaleLoaded) {
                    _weighingCubit.setEquipments(state.scale.d!.results!);
                  }
                },
              ),
              BlocListener<OperationTypeBloc, OperationTypeState>(
                  listener: (context, state) {
                if (state is OperationTypeLoaded) {
                  var oprType = state.operationType.d!.results!;
                  for (var data in oprType) {
                    _weighingCubit.setMaterialsFull(data);
                    _weighingCubit.setOperationTypeList(
                        data.oprTypToDescNav!.resultsOprType!);
                  }
                }
              }),
              BlocListener<ExpiredSetBloc, ExpiredSetState>(
                  listener: (context, state) {
                if (state is ExpiredSetLoaded) {
                  for (var expiredSet
                      in state.expiredSet.d!.resultsExpiredSet!) {
                    _weighingCubit.setExpired(expiredSet);
                  }
                }
              }),
              BlocListener<ResultScaleBloc, ResultScaleState>(
                  listener: (context, state) {
                if (state is ResultScaleLoaded) {
                  _weighingCubit
                      .setResultScaleList(state.resultScale.d!.results!);
                  _weighingCubit.setTotalContainer(
                      state.resultScale.d!.results![0].totalWadah!);
                }
              }),
              BlocListener<OperationBloc, OperationState>(
                  listener: (context, state) {
                if (state is OperationLoaded) {
                  _weighingCubit
                      .setOperations(state.operation.d!.resultsOperationNo!);
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
                                      keyboardType: TextInputType.number,
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
                                  keyboardType: TextInputType.number,
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        _weighingCubit.setSelectedOrder(selectedOrder);
                        operationBloc.add(SendDataOperation(
                            operationType: selectedOrder.operationType!,
                            routingNo: selectedOrder.routingNo!,
                            operationApps:
                                "eq '${weighingState.operationApps}'"));
                        return _showOperationNo(context);
                      },
                    );
                  },
                ));
          }),
    );
  }

  Widget _showOperationNo(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _weighingCubit),
          BlocProvider.value(value: weighingBloc)
        ],
        child: Dialog(
            insetPadding: EdgeInsets.zero,
            child: BlocBuilder<WeighingCubit, WeighingState>(
              builder: (context, weighingState) {
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
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: weighingState.operations.length,
                            itemBuilder: (BuildContext context, int index) {
                              final selectedOperation =
                                  weighingState.operations[index];

                              final isSelected =
                                  weighingState.selectedOperation.activityNo ==
                                      selectedOperation.activityNo;

                              return Card(
                                elevation: weighingState
                                            .operations[index].lastOperation ==
                                        ''
                                    ? 7
                                    : 0,
                                shadowColor: Colors.blueGrey[100],
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                color: weighingState
                                            .operations[index].lastOperation ==
                                        ''
                                    ? isSelected
                                        ? Colors.black
                                        : Colors.grey[100]
                                    : Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedOperation.operationDesc,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: weighingState
                                                            .operations[index]
                                                            .lastOperation ==
                                                        ''
                                                    ? isSelected
                                                        ? Colors.white
                                                        : Colors.black
                                                    : Colors.grey[600],
                                              )),
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
                                                      color: weighingState
                                                                  .operations[
                                                                      index]
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
                                                      color: weighingState
                                                                  .operations[
                                                                      index]
                                                                  .lastOperation ==
                                                              ''
                                                          ? isSelected
                                                              ? Colors.white
                                                              : Colors.black
                                                          : Colors.grey[600],
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
                                                      color: weighingState
                                                                  .operations[
                                                                      index]
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
                                                selectedOperation.operationApps,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: weighingState
                                                                  .operations[
                                                                      index]
                                                                  .lastOperation ==
                                                              ''
                                                          ? isSelected
                                                              ? Colors.white
                                                              : Colors.black
                                                          : Colors.grey[600],
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
                                  onTap: weighingState.operations[index]
                                              .lastOperation ==
                                          ''
                                      ? selectedOperation
                                              .operationDesc2!.isEmpty
                                          ? () {
                                              _weighingCubit
                                                  .setSelectedOperation(
                                                      selectedOperation);
                                              weighingBloc.add(SendDataWeighing(
                                                  routingNo: selectedOperation
                                                      .routingNo,
                                                  internalCntr:
                                                      selectedOperation
                                                          .internalCntr,
                                                  activityNo: selectedOperation
                                                      .activityNo,
                                                  operationType: weighingState
                                                      .operationType,
                                                  operationApps: weighingState
                                                      .operationApps));
                                              if (mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          : () {
                                              final List<ResultOperation>
                                                  operations = [
                                                selectedOperation,
                                                selectedOperation.copyWith(
                                                    operationDesc:
                                                        selectedOperation
                                                            .operationDesc2)
                                              ];
                                              _weighingCubit
                                                  .setChooseOperations(
                                                      operations);
                                              _weighingCubit.setTab(
                                                  WeighingStatus
                                                      .chooseOperation);
                                              Navigator.of(context).pop();
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
              },
            )));
  }
}
