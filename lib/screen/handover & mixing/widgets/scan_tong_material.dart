import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/flag_materials_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/material_set_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/submit_handover_mixing_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

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
  MaterialSetBloc materialSetBloc = MaterialSetBloc();
  SubmitHandoverMixingBloc submitHandoverMixingBloc =
      SubmitHandoverMixingBloc();
  FlagMaterialsBloc flagMaterialsBloc = FlagMaterialsBloc();
  String scannedBarcode = "";
  List<dynamic> hasScanned = [];

  List<String> parseStringAndWrapInMap(String input) {
    List<String> parts = input.split(';');
    List<String> scanned = [];
    scanned = parts;

    return scanned;
  }

  void _scanOperator(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
        hasScanned = parseStringAndWrapInMap(scannedBarcode);
      });
      _handoverCubit.setScannedTong(parseStringAndWrapInMap(scannedBarcode));
      if (mounted) {
        switch (_handoverCubit.state.errorScanType) {
          case ErrorScanType.dataScanned:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Data is Scanned"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
            Future.delayed(const Duration(milliseconds: 200), () {
              Vibration.vibrate(duration: 800);
            });
            if (hasScanned.length == 4 || hasScanned.length == 5) {
              _handoverCubit.resetCompleteMaterial(false);
              _handoverCubit.setTongActivity(hasScanned[3]);
              materialSetBloc.add(SendDataMaterialset(
                  routingNo: _handoverCubit.state.selectedOperation.routingNo,
                  activityNo: hasScanned[3],
                  operationType:
                      _handoverCubit.state.selectedOrder.operationType!));
            }
            break;
          case ErrorScanType.incorrectPriority:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Invalid Priority"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
            FlutterRingtonePlayer()
                .play(fromAsset: "assets/ringtone/wrong.mp3");
            Future.delayed(const Duration(milliseconds: 200), () {
              Vibration.vibrate(duration: 800);
            });
            break;
          case ErrorScanType.noError:
            if (hasScanned.length == 4 || hasScanned.length == 5) {
              _handoverCubit.resetCompleteMaterial(false);
              _handoverCubit.setTongActivity(hasScanned[3]);
              materialSetBloc.add(SendDataMaterialset(
                  routingNo: _handoverCubit.state.selectedOperation.routingNo,
                  activityNo: hasScanned[3],
                  operationType:
                      _handoverCubit.state.selectedOrder.operationType!));
            }
            if (hasScanned.length >= 6) {
              if (_handoverCubit.state.startTime == '') {
                _handoverCubit.setStartDate();
              }
              flagMaterialsBloc.add(GetFlagMaterials(hasScanned));
            }
            break;
          case ErrorScanType.dataNull:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Data Not Found"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
            FlutterRingtonePlayer()
                .play(fromAsset: "assets/ringtone/wrong.mp3");
            Future.delayed(const Duration(milliseconds: 200), () {
              Vibration.vibrate(duration: 800);
            });
            break;
        }
      }
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
        BlocProvider.value(value: materialSetBloc),
        BlocProvider.value(value: submitHandoverMixingBloc),
        BlocProvider<FlagMaterialsBloc>(
            create: (BuildContext context) => flagMaterialsBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MaterialSetBloc, MaterialSetState>(
              listener: (context, state) {
            if (state is MaterialSetLoaded) {
              var materialSets = state.materialset.d!.results!;
              if (materialSets.isNotEmpty) {
                if (materialSets[0].priority == '') {
                  materialSets.sort((a, b) => '${a.scanDate} ${a.scanTime}'
                      .compareTo('${b.scanDate} ${b.scanTime}'));
                } else {
                  materialSets.sort((a, b) => a.priority.compareTo(b.priority));
                }
              }
              if (materialSets[0].scanFlag == 'X') {
                _handoverCubit.setStartDateByString(
                    '${materialSets[0].scanDate}-${materialSets[0].scanTime}');
              }
              _handoverCubit.setMaterialSet(materialSets);
              _handoverCubit.setTab(HandoverStatus.scanMaterialMixing);
            }
          }),
          BlocListener<SubmitHandoverMixingBloc, SubmitHandoverMixingState>(
              listener: (context, state) {
            switch (state) {
              case SubmitHandoverMixingLoaded():
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Send data successfully"),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                Navigator.of(context).pop();
                Future.delayed(const Duration(seconds: 1), () {
                  // ignore: use_build_context_synchronously
                  context.go("/home");
                });
                break;
              case SubmitHandoverMixingError():
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                break;
            }
          }),
          BlocListener<FlagMaterialsBloc, FlagMaterialsState>(
              listener: (context, state) {
            switch (state) {
              case FlagMaterialsSuccess():
                _handoverCubit.setIsLoadingMaterialSet(true);

                break;
              case FlagMaterialsError():
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                break;
            }
          })
        ],
        child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: Text(
                    "Handover Mixing - ${handoverState.selectedOperation.operationDesc} (${handoverState.selectedOperation.activityNo})"),
                leading: IconButton(
                  onPressed: () {
                    _handoverCubit.setTab(handoverState.prevTab);
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
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
                                    handoverState.selectedOrder.material != null
                                        ? '(${handoverState.selectedOrder.material}) ${handoverState.selectedOrder.materialDesc}'
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
                                    handoverState.selectedOrder.orderNo != null
                                        ? handoverState.selectedOrder.orderNo!
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
                                    handoverState.selectedOrder.batchFG != null
                                        ? handoverState.selectedOrder.batchFG!
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
                                    handoverState.selectedOperation.activityNo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    handoverState
                                        .selectedOperation.operationDesc,
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
                    child: handoverState.isComplete
                        ? TextButton(
                            onPressed: () {
                              submitHandoverMixingBloc.add(SubmitHandoverMixing(
                                  handoverMixingData: handoverState));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                      "Mixing containers",
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
                ],
              )),
        );
      }),
    );
  }

  Widget _showMaterialSets(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _handoverCubit)],
      child: BlocBuilder<HandoverCubit, HandoverState>(
        builder: (context, handoverState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Materials"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  for (var materialSet in handoverState.materialSet) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                '${materialSet.materialNo.isNotEmpty ? "${materialSet.materialNo} -" : ''} ${materialSet.materialDesc} - ${materialSet.bOMItem} - ${materialSet.quantity.replaceAll('.', ',')} ${materialSet.uom} ${materialSet.counter != '' ? '(${materialSet.counter})' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          if (materialSet.isScanned ||
                              materialSet.scanFlag == 'X') ...[
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
                  child: handoverState.materialSet
                              .where((test) => test.scanFlag == 'X')
                              .length ==
                          handoverState.materialSet.length
                      ? TextButton(
                          onPressed: () {
                            submitHandoverMixingBloc.add(SubmitHandoverMixing(
                                handoverMixingData: handoverState));
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
                                "Save",
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
    );
  }
}
