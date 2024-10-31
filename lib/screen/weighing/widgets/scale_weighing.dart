import 'dart:io';

import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScaleWeighingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ScaleWeighingScreen({Key? key}) : super(key: key);

  @override
  State<ScaleWeighingScreen> createState() => _ScaleWeighingScreenState();
}

class _ScaleWeighingScreenState extends State<ScaleWeighingScreen> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  ScaleBloc scaleBloc = ScaleBloc();
  List<ResultScale> scaleList = [];
  ResultScale scaleData = ResultScale();
  final temperature = TextEditingController();
  final moistureContent = TextEditingController();
  final numberOfContainer = TextEditingController();
  final scale = TextEditingController();
  final bruto = TextEditingController();
  final tara = TextEditingController();
  final netto = TextEditingController();
  late Socket socket;
  String weight = "     ";
  String scannedBarcode = '';
  String plant = '';
  RegExp replaceZero = RegExp(r"^(0)+", caseSensitive: true, multiLine: false);
  RegExp replaceDoubleSpace = RegExp(r"\s+");

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      if (mounted) {
        for (var scales in scaleList) {
          if (scales.equipmentNo == scannedBarcode) {
            scaleData = scales;
            scale.text = scales.equipmentDesc!;
            tCPListen();
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant = data.weerks;
    }
    tara.text = "0";
    scaleBloc.add(SendDataScale(plant: plant));
  }

  void tCPListen() async {
    print("tcp listen");
    try {
      RegExp regExp = RegExp(
        scaleData.regex!,
        caseSensitive: false,
        multiLine: false,
      );

      socket = await Socket.connect(scaleData.urlAddress, 4001);
      print("Connected");

      socket.listen(
        (data) {
          final dataString = String.fromCharCodes(data);
          if (regExp.hasMatch(dataString)) {
            var dataReg = regExp.firstMatch(dataString);
            print(dataReg![3]);
            var value = dataReg[3]!.replaceAll(replaceZero, "");
            var brutoFloat = double.parse(value);
            var nettoFloat = brutoFloat;
            if (tara.text.isNotEmpty) {
              var taraFloat = double.parse(tara.text);
              nettoFloat = brutoFloat - taraFloat;
              print('tara Float = $taraFloat');
            }
            print('bruto Float = $brutoFloat');
            print('netto Float = $nettoFloat');
            setState(() {
              netto.text = nettoFloat.toStringAsFixed(2);
              bruto.text =
                  "$value${dataReg[4]!.replaceAll(replaceDoubleSpace, ' ')}";
            });
          }
        },
        onDone: () {
          print('Server disconnected.');
          socket.destroy();
        },
        onError: (error) {
          print('Error: $error');
          socket.destroy();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void closeConnection() {
    socket.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _weighingCubit,
        ),
        BlocProvider(
          create: (context) => scaleBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WeighingCubit, WeighingState>(
            listener: (context, state) {},
          ),
          BlocListener<ScaleBloc, ScaleState>(
            listener: (context, state) {
              if (state is ScaleLoaded) {
                scaleList = state.scale.d!.results!;
              }
            },
          ),
        ],
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: const Text("Scale Weighing"),
                leading: BackButton(
                  onPressed: () {
                    _weighingCubit.setTab(WeighingStatus.scaleWeighing);
                    if (weighingState.isConnectedTcp) {
                      _weighingCubit.setConnectedStatus(false);
                      closeConnection();
                    }
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
                                    weighingState.orderList.material != null
                                        ? '(${weighingState.orderList.material}) ${weighingState.orderList.materialDesc}'
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
                                    weighingState.orderList.orderNo != null
                                        ? weighingState.orderList.orderNo!
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
                                    weighingState.orderList.batchFG != null
                                        ? weighingState.orderList.batchFG!
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
                                    weighingState.operationList.activityNo !=
                                            null
                                        ? weighingState
                                            .operationList.activityNo!
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
                                    weighingState.operationList.operationDesc !=
                                            null
                                        ? weighingState
                                            .operationList.operationDesc!
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
                      _formWeighing(context)
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
                      child: TextButton(
                        onPressed: () {
                          print("Complete");
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Get Weight",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                        ),
                      )),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formWeighing(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: temperature,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Temperature',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: moistureContent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Moisture Content',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: numberOfContainer,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Number Of Container',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: scale,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ScanBarcodeScreen(
                          onBarcodeScanned: (barcode) {
                            _scanBarcode(barcode);
                          },
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Scale',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: const Icon(Icons.qr_code_scanner_rounded)),
                  readOnly: true,
                ),
              ),
              if (scaleData.equipmentNo != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: bruto,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Bruto',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    readOnly: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: tara,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Tara',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: netto,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Netto',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    readOnly: true,
                  ),
                ),
              ]
            ],
          ),
        ));
  }
}
