import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/operation_type_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/bloc/material_bloc.dart';
import 'package:dumping_system/bloc/operation_bloc.dart';
import 'package:dumping_system/bloc/order_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/location_set_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/wadah_set_bloc.dart';
import 'package:dumping_system/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  List<ResultsMaterial> listMaterials = List.empty();
  List<ResultsOrder> listOrder = List.empty();
  List<ResultOperation> listOperation = List.empty();
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
        BlocProvider<TongBloc>(
          create: (BuildContext context) => tongBloc,
        ),
        BlocProvider<WadahSetBloc>(
            create: (BuildContext context) => wadahSetBloc),
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
          BlocListener<OperationTypeBloc, OperationTypeState>(
              listener: (context, state) {
            if (state is OperationTypeLoaded) {
              var oprType = state.operationType.d!.results!;
              for (var data in oprType) {
                _handoverCubit
                    .setOperationType(data.oprTypToDescNav!.resultsOprType!);
              }
            }
          }),
          BlocListener<LocationSetBloc, LocationSetState>(
              listener: (context, state) {
            if (state is LocationSetLoaded) {
              if (state.locationSet.d!.locationSet!.isEmpty) {
                tongBloc.add(SendDataTong(
                    routingNo: _handoverCubit
                                .state.selectedOperationNumber.routingNo !=
                            null
                        ? _handoverCubit
                            .state.selectedOperationNumber.routingNo!
                        : "",
                    activityNo: _handoverCubit
                                .state.selectedOperationNumber.activityNo !=
                            null
                        ? _handoverCubit
                            .state.selectedOperationNumber.activityNo!
                        : "",
                    controlRecipe: _handoverCubit
                                .state.selectedOperationNumber.controlRecipe !=
                            null
                        ? _handoverCubit
                            .state.selectedOperationNumber.controlRecipe!
                        : "",
                    operationType: _handoverCubit
                                .state.selectedOperation.operationType !=
                            null
                        ? _handoverCubit.state.selectedOperation.operationType!
                        : ""));
                if (int.parse(_handoverCubit
                        .state.selectedOperationNumber.operationApps!) >
                    20) {
                  _handoverCubit.setTab(HandoverStatus.scantongmaterial);
                } else {
                  _handoverCubit.setTab(HandoverStatus.scantong);
                }
                Navigator.of(context).pop();
              } else {
                _handoverCubit
                    .setLocationSet(state.locationSet.d!.locationSet!);
              }
            }
          }),
          BlocListener<TongBloc, TongState>(listener: (context, state) {
            if (state is TongLoaded) {
              _handoverCubit.setResultTong(state.tong.d!.resultsTong!);
              for (var fullpack in state.tong.d!.resultsTong!) {
                _handoverCubit
                    .setFullpack(fullpack.wadToMatNav!.resultsFullPack!);
              }
            }
          }),
          BlocListener<WadahSetBloc, WadahSetState>(listener: (context, state) {
            if (state is WadahSetLoaded) {
              _handoverCubit.setResultTong(state.wadahSet.d!.resultsTong!);
              for (var fullpack in state.wadahSet.d!.resultsTong!) {
                _handoverCubit
                    .setFullpack(fullpack.wadToMatNav!.resultsFullPack!);
              }
              _handoverCubit.setTab(HandoverStatus.scanTongResultsWeighing);
              Navigator.of(context).pop();
            }
          })
        ],
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Handover & Mixing"),
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
                                keyboardType: TextInputType.number,
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
                  operationApps: "ge '20'"));
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
        BlocProvider.value(value: operationBloc),
        BlocProvider.value(value: locationSetBloc)
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
                                      _handoverCubit.setOperation(operationNo);
                                      locationSetBloc.add(GetLocationSet(
                                          operationNo.routingNo!,
                                          operationNo.internalCntr!,
                                          operationNo.activityNo!));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Text(
                            'Choose location:',
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
                                  itemCount: handoverState.locationSets.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final selectedLocation =
                                        handoverState.locationSets[index];

                                    final isSelected = handoverState
                                            .selectedLocationSet.activityNo ==
                                        selectedLocation.activityNo;

                                    return Card(
                                        elevation: 5,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 20),
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey[200],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedLocation.operationDesc!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black),
                                              ),
                                              const SizedBox(height: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Line",
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
                                                    selectedLocation.line!,
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
                                          onTap: () {
                                            _handoverCubit
                                                .setSelectedLocationSet(
                                                    selectedLocation);
                                            wadahSetBloc.add(GetWadahSet(
                                                selectedLocation.routingNo!,
                                                selectedLocation.activityNo!,
                                                handoverState.operationType));
                                          },
                                        ));
                                  }))
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
