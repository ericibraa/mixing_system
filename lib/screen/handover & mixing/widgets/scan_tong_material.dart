import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/tong_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/material_set_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanTongMaterialSetScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ScanTongMaterialSetScreen({Key? key}) : super(key: key);

  @override
  State<ScanTongMaterialSetScreen> createState() =>
      _ScanTongMaterialSetScreenState();
}

class _ScanTongMaterialSetScreenState extends State<ScanTongMaterialSetScreen> {
  AuthBloc authBloc = AuthBloc();
  HandoverCubit _handoverCubit = HandoverCubit();
  TongBloc tongBloc = TongBloc();
  MaterialSetBloc materialSetBloc = MaterialSetBloc();
  String scannedBarcode = "";

  String parseStringAndWrapInMap(String input) {
    List<String> parts = input.split(';');
    String scanned;
    scanned = parts.length > 6 ? parts[6] : parts[3];
    return scanned;
  }

  void _scanOperator(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
        _handoverCubit.setScannedTong(parseStringAndWrapInMap(scannedBarcode));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    _handoverCubit = BlocProvider.of<HandoverCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _handoverCubit),
        BlocProvider.value(value: tongBloc),
        BlocProvider.value(value: materialSetBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TongBloc, TongState>(
            listener: (context, state) {
              if (state is TongLoaded) {
                _handoverCubit.setResultTong(state.tong.d!.resultsTong!);
                for (var fullpack in state.tong.d!.resultsTong!) {
                  _handoverCubit
                      .setFullpack(fullpack.wadToMatNav.resultsFullPack!);
                  materialSetBloc.add(SendDataMaterialset(
                      routingNo: fullpack.routingNo,
                      activityNo: fullpack.activityNo,
                      operationType: fullpack.operationType!));
                }
              }
            },
          ),
          BlocListener<HandoverCubit, HandoverState>(
            listener: (context, state) {
              if (state.isResultOperationLoaded == true &&
                  state.tongs.isEmpty) {
                tongBloc.add(SendDataTong(
                    routingNo: state.selectedOperationNumber.routingNo != null
                        ? _handoverCubit
                            .state.selectedOperationNumber.routingNo!
                        : "",
                    activityNo: state.selectedOperationNumber.activityNo != null
                        ? _handoverCubit
                            .state.selectedOperationNumber.activityNo!
                        : "",
                    controlRecipe:
                        state.selectedOperationNumber.controlRecipe != null
                            ? _handoverCubit
                                .state.selectedOperationNumber.controlRecipe!
                            : "",
                    operationType: state.selectedOperation.operationType != null
                        ? _handoverCubit.state.selectedOperation.operationType!
                        : ""));
              }
            },
          ),
          BlocListener<MaterialSetBloc, MaterialSetState>(
              listener: (context, state) {
            if (state is MaterialSetLoaded) {
              _handoverCubit.setMaterialSet(state.materialset.d!.results!);
            }
          })
        ],
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: Text(
                    "Handover Mixing - ${handoverState.selectedOperationNumber.operationDesc} (${handoverState.selectedOperationNumber.activityNo})"),
                leading: BackButton(
                  onPressed: () {
                    _handoverCubit.setTab(HandoverStatus.handover);
                  },
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 10, right: 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Material",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Process order",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Batch",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Operation No",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Operation text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    handoverState.selectedOperation.material !=
                                            null
                                        ? '(${handoverState.selectedOperation.material}) ${handoverState.selectedOperation.materialDesc}'
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    handoverState.selectedOperation.orderNo !=
                                            null
                                        ? handoverState
                                            .selectedOperation.orderNo!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    handoverState.selectedOperation.batchFG !=
                                            null
                                        ? handoverState
                                            .selectedOperation.batchFG!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    handoverState.selectedOperationNumber
                                                .activityNo !=
                                            null
                                        ? handoverState
                                            .selectedOperationNumber.activityNo!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    handoverState.selectedOperationNumber
                                                .operationDesc !=
                                            null
                                        ? handoverState.selectedOperationNumber
                                            .operationDesc!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _listTong(context, handoverState)
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                elevation: 10,
                color: Colors.transparent,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: handoverState.isCompleteTong
                        ? TextButton(
                            onPressed: () {
                              print("Complete");
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Complete",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ScanBarcodeScreen(
                                    onBarcodeScanned: (barcode) {
                                      _scanOperator(barcode);
                                    },
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Scan Barcode",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
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

  Widget _listTong(BuildContext context, HandoverState handoverState) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _handoverCubit,
        ),
      ],
      child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: !handoverState.isComplete
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          "List Wadah & Fullpack",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(endIndent: 10, indent: 10),
                      for (var tong in handoverState.tongs) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '${tong.operationDesc} ${tong.activityNo}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              if (tong.isScanned == false) ...[
                                const Icon(Icons.qr_code_scanner_rounded)
                              ] else ...[
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              ]
                            ],
                          ),
                        ),
                        const Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                      ],
                      for (var fullpack in handoverState.fullpack) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '${fullpack.materialDesc} ${fullpack.counter}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              if (fullpack.isScannedFullpack == false) ...[
                                const Icon(Icons.qr_code_scanner_rounded)
                              ] else ...[
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              ]
                            ],
                          ),
                        ),
                        const Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                      ]
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          "List Material",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(endIndent: 10, indent: 10),
                      for (var materialSet in handoverState.materialSet) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '${materialSet.materialDesc} ${materialSet.bOMItem}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              if (materialSet.isScanned == false) ...[
                                const Icon(Icons.qr_code_scanner_rounded)
                              ] else ...[
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              ]
                            ],
                          ),
                        ),
                        const Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                      ],
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
