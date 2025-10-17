import 'dart:io';

import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/calibration/cubit/calibration_cubit.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zsdk/zsdk.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  ScaleBloc scaleBloc = ScaleBloc();
  AuthBloc authBloc = AuthBloc();
  final CalibrationCubit _calibrationCubit = CalibrationCubit();
  final plant = TextEditingController();
  String scannedBarcode = "";
  Socket? socket;
  final weight = TextEditingController();
  String unit = "";
  final scale = TextEditingController();
  final dateTime = TextEditingController();
  final zsdk = ZSDK();
  String operator = "";

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant.text = data.weerks;
      operator = data.nameOperator;
    }
    scaleBloc.add(SendDataScale(plant: plant.text));
    dateTime.text = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
  }

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      if (mounted) {
        _calibrationCubit.resetScaleWeighing();
        _calibrationCubit.setSelectedEquipment(scannedBarcode);
        if (_calibrationCubit.state.selectedEquipment.equipmentNo.isNotEmpty) {
          _calibrationCubit.setScaleWeighing(
              _calibrationCubit.state.scaleWeighing.copyWith(
                  scaleName:
                      _calibrationCubit.state.selectedEquipment.equipmentDesc,
                  scaleId:
                      _calibrationCubit.state.selectedEquipment.equipmentNo,
                  regex: _calibrationCubit.state.selectedEquipment.regex,
                  urlAddress:
                      _calibrationCubit.state.selectedEquipment.urlAddress));
          tCPListen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Invalid equipment"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Barcode Error"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    }
  }

  void tCPListen() async {
    print("tcp listen");
    String dataString = "";

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Connecting to scale ..."),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
    try {
      RegExp regExp = RegExp(
        // ignore: unnecessary_string_escapes
        r"" +
            // ignore: unnecessary_string_escapes
            _calibrationCubit.state.selectedEquipment.regex
                .replaceAll("\s", " "),
        caseSensitive: false,
        multiLine: true,
      );
      socket = await Socket.connect(
          _calibrationCubit.state.selectedEquipment.urlAddress, 4001);
      print("Connected");
      _calibrationCubit.setConnectedStatus(true);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Scale connected"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
      socket!.listen(
        (data) {
          dataString += String.fromCharCodes(data);
          dataString = dataString.replaceAll(RegExp("[\n\t\r]"), "").trim();
          var dataReg = regExp.firstMatch(dataString);
          if (dataReg != null) {
            var taraDouble = double.parse(
              dataReg[1]!,
            );

            weight.text = taraDouble.toStringAsFixed(2);
            scale.text =
                _calibrationCubit.state.selectedEquipment.equipmentDesc;
            unit = dataReg[2]!;

            dataString = "";
          }
          print(dataString);
        },
        onDone: () {
          print('Server disconnected.');
          socket!.destroy();
        },
        onError: (error) {
          print('Error: $error');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Failed connect to scale ...!"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
          socket!.destroy();
        },
      );
    } catch (e) {
      print(e);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Failed connect to scale ..."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    }
  }

  void closeConnection() {
    socket != null ? socket!.close() : '';
    _calibrationCubit.setConnectedStatus(false);
    _calibrationCubit.resetScaleWeighing();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (BuildContext context) => authBloc),
          BlocProvider<ScaleBloc>(create: (BuildContext context) => scaleBloc),
          BlocProvider<CalibrationCubit>(
              create: (BuildContext context) => _calibrationCubit)
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<ScaleBloc, ScaleState>(listener: (context, state) {
                if (state is ScaleLoaded) {
                  _calibrationCubit.setEquipments(state.scale.d!.results!);
                }
              })
            ],
            child: BlocBuilder<CalibrationCubit, CalibrationState>(
                builder: (context, calibrationState) {
              return Scaffold(
                  appBar: AppBar(
                      title: const Text("Calibration Scale"),
                      leading: IconButton(
                          onPressed: () {
                            context.push("/home");
                          },
                          icon: const Icon(Icons.chevron_left_rounded))),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
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
                            child: TextFormField(
                              controller: dateTime,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Date Time',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              readOnly: true,
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
                                  labelText: 'Scan Scale',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  suffixIcon: const Icon(
                                      Icons.qr_code_scanner_rounded)),
                              readOnly: true,
                            ),
                          ),
                          if (calibrationState.isConnectedTcp) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: TextFormField(
                                controller: weight,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Weight',
                                    hintText: '0.0',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    suffix: Text(unit.toUpperCase())),
                                readOnly: true,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    elevation: 10,
                    color: Colors.transparent,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton(
                              onPressed: weight.text.isNotEmpty
                                  ? () async {
                                      await zsdk.printZplDataOverTCPIP(
                                          address: _calibrationCubit.state
                                              .selectedEquipment.ipPrinter,
                                          port: 9100,
                                          data: '''
                              ^XA
                                ^PW560                           ; Set print width for portrait A7 (560 dots, approximately 74mm)
                                ^LL800 
                                ^CFQ
                                ^FO5,220^GB550,400,2^FS      ; Full border around the label
                                ^FO30,240^GFA,357,357,7,,::00JF3IFC,007IF3IF8,003IF3IF,001IF3FFE,K033,::0JFI3IFC,07IFI3IFC,07IFI3IF8,03IFI3IF,01IFI3FFE,J0J3,::7IFJ31IFC,7IFK3IFC,7IFK3IF8,3IFK3IF,1IFK3IF,1IFK3FFE,I0L3,::::::::::::::::::::::,:::^FS      ; Logo
                                ^FO0,255^A0N,30^FB570,,,C^FDPENIMBANGAN^FS     ; Title 
                                ^FO30,320^FDPlant^FS       : Plant
                                ^FO200,320^FD${plant.text}^FS       ; Plant Code
                                ^FO30,355^FDDatetime^FS     ; Datetime
                                ^FO200,355^FD${dateTime.text}^FS     ; Date time
                                ^FO30,390^FDScale^FS     ; Scale
                                ^FO200,390^FD${calibrationState.selectedEquipment.equipmentDesc}^FS     ; Scale
                                ^FO30,425^FDOperator^FS     ; Operator
                                ^FO200,425^FD$operator^FS     ; Operator
                                ^CF0,30 
                                ^FO30,550^FDTotal Weight^FS     ; Total Weight
                                ^FO290,550^FB180,,,R^FD${weight.text}^FS           ; Aligned value
                                ^FO330,550^FB200,,,R^FD${unit.toUpperCase()}^FS                    ; Aligned unit
                              ^XZ''').then((value) {
                                        final printerResponse =
                                            PrinterResponse.fromMap(value);
                                        Status status =
                                            printerResponse.statusInfo.status;
                                        print(status);
                                        if (printerResponse.errorCode ==
                                            ErrorCode.SUCCESS) {
                                          print("printer connect");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                const Text("Label printed"),
                                            backgroundColor: Colors.black,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                const Text("failed to print"),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ));
                                          Cause cause =
                                              printerResponse.statusInfo.cause;
                                          print(cause);
                                        }
                                      });
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                backgroundColor: weight.text.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Print Tara",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                            ))),
                  ));
            })));
  }
}
