import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/post_handover_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/flag_materials_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/handover_flag_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/material_set_bloc.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/wadah_set_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class ScanTongResultsWeighing extends StatefulWidget {
  // ignore: use_super_parameters
  const ScanTongResultsWeighing({Key? key}) : super(key: key);

  @override
  State<ScanTongResultsWeighing> createState() =>
      _ScanTongResultsWeighingScreenState();
}

class _ScanTongResultsWeighingScreenState
    extends State<ScanTongResultsWeighing> {
  AuthBloc authBloc = AuthBloc();
  HandoverCubit _handoverCubit = HandoverCubit();
  SubmitHandoverBloc submitHandoverBloc = SubmitHandoverBloc();
  MaterialSetBloc materialSetBloc = MaterialSetBloc();
  FlagMaterialsBloc flagMaterialsBloc = FlagMaterialsBloc();
  HandoverFlagBloc handoverFlagBloc = HandoverFlagBloc();
  WadahSetBloc wadahSetBloc = WadahSetBloc();
  String scannedBarcode = "";
  final line = TextEditingController();
  List<dynamic> hasScanned = [];
  bool isLoading = false;

  List<String> parseStringAndWrapInMap(String input) {
    List<String> parts = input.split(';');
    List<String> scanned = [];
    scanned = parts;

    return scanned;
  }

  void _scanLine(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        _handoverCubit.setLine(barcode.displayValue!);
      });
    }
  }

  void _scanOperator(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
        hasScanned = parseStringAndWrapInMap(scannedBarcode);
      });
      _handoverCubit.setScannedTong(parseStringAndWrapInMap(scannedBarcode));
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
          FlutterRingtonePlayer().play(fromAsset: "assets/ringtone/wrong.mp3");
          Future.delayed(const Duration(milliseconds: 200), () {
            Vibration.vibrate(duration: 800);
          });
          break;
        case ErrorScanType.noError:
          handoverFlagBloc.add(FlagHandover(
              handoverFlag: hasScanned,
              originalOrder: _handoverCubit.state.selectedOrder.orderNo ?? ''));
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
          FlutterRingtonePlayer().play(fromAsset: "assets/ringtone/wrong.mp3");
          Future.delayed(const Duration(milliseconds: 200), () {
            Vibration.vibrate(duration: 800);
          });
          break;
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
        BlocProvider<SubmitHandoverBloc>(
            create: (context) => submitHandoverBloc),
        BlocProvider<HandoverFlagBloc>(create: (context) => handoverFlagBloc),
        BlocProvider<WadahSetBloc>(create: (context) => wadahSetBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SubmitHandoverBloc, SubmitHandoverState>(
              listener: (context, state) {
            if (state is SubmitHandoverLoaded) {
              if (state.submitHandover == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Send data successfully"),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                if (_handoverCubit.state.isNext) {
                  Future.delayed(const Duration(seconds: 2), () {
                    _handoverCubit.resetFullpackWadah();
                    _handoverCubit.setTab(HandoverStatus.scantongmaterial);
                  });
                } else {
                  _handoverCubit.resetFullpackWadah();
                  _handoverCubit.setTab(HandoverStatus.handover);
                }
              }
            }
          }),
          BlocListener<HandoverCubit, HandoverState>(
              listener: (context, handoverState) {
            line.text = handoverState.line;
          }),
          BlocListener<HandoverFlagBloc, HandoverFlagState>(
              listener: (context, state) {
            if (state is HandoverFlagLoading) {
              setState(() {
                isLoading = true;
              });
            } else if (state is HandoverFlagLoaded) {
              setState(() {
                isLoading = false;
              });
              wadahSetBloc.add(GetWadahSet(
                  _handoverCubit.state.selectedOperation.routingNo,
                  _handoverCubit.state.tongs[0].activityNo!,
                  _handoverCubit.state.operationType));
            } else if (state is HandoverFlagError) {
              setState(() {
                isLoading = false;
              });
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
          BlocListener<WadahSetBloc, WadahSetState>(listener: (context, state) {
            if (state is WadahSetLoaded) {
              _handoverCubit.setResultTong(state.wadahSet.d!.resultsTong!);
              List<ResultsFullPack> fullpacks = [];
              for (var fullpack in state.wadahSet.d!.resultsTong!) {
                if (fullpack.wadToMatNav!.resultsFullPack != null) {
                  fullpacks.addAll(fullpack.wadToMatNav!.resultsFullPack!);
                }
              }
              _handoverCubit.setFullpack(fullpacks);
              _handoverCubit.setTab(HandoverStatus.scanTongResultsWeighing);
              _handoverCubit.setPrevTab(HandoverStatus.chooseLocation);
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
                              Text(
                                "ActivityWh",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              )
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
                                  handoverState.selectedOperation.operationDesc,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  handoverState.tongs.isNotEmpty
                                      ? handoverState.tongs[0].activityNo!
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
                    Form(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: line,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ScanBarcodeScreen(
                                  onBarcodeScanned: (barcode) {
                                    _scanLine(barcode);
                                  },
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Line',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffixIcon:
                                  const Icon(Icons.qr_code_scanner_rounded)),
                          readOnly: true,
                        ),
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
                  child: isLoading
                      ? TextButton(
                          onPressed: null,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sending scanned data",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                              const LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [Colors.white],
                                strokeWidth: 1,
                              ),
                            ],
                          ))
                      : handoverState.operationType == 'CB'
                          ? handoverState.fullpack
                                          .where((item) =>
                                              item.handoverFlag == 'X')
                                          .length ==
                                      handoverState.fullpack.length &&
                                  line.text.isNotEmpty
                              ? TextButton(
                                  onPressed: () {
                                    submitHandoverBloc.add(SubmitHandover(
                                        orderData: handoverState));
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
                              : handoverState.fullpack
                                      .where((item) => item.handoverFlag == 'X')
                                      .isEmpty
                                  ? TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ScanBarcodeScreen(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ScanBarcodeScreen(
                                                    onBarcodeScanned:
                                                        (barcode) {
                                                      _scanOperator(barcode);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              submitHandoverBloc.add(
                                                  SubmitHandover(
                                                      orderData:
                                                          handoverState));
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                          : handoverState.fullpack
                                          .where((item) =>
                                              item.handoverFlag == 'X')
                                          .length ==
                                      handoverState.fullpack.length &&
                                  line.text.isNotEmpty
                              ? TextButton(
                                  onPressed: () {
                                    submitHandoverBloc.add(SubmitHandover(
                                        orderData: handoverState));
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
        }),
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
                    "Handover containers",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(endIndent: 10, indent: 10),
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
                        if (fullpack.handoverFlag == "X") ...[
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
        );
      }),
    );
  }
}
