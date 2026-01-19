import 'dart:io';

import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zsdk/zsdk.dart';

class PrintTara extends StatefulWidget {
  const PrintTara({super.key});

  @override
  State<PrintTara> createState() => _PrintTaraState();
}

class _PrintTaraState extends State<PrintTara> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  ScaleBloc scaleBloc = ScaleBloc();
  final plant = TextEditingController();
  String scannedBarcode = '';
  Socket? socket;
  final scale = TextEditingController();
  final tara = TextEditingController();
  String unit = "";
  final dateTime = TextEditingController();
  final zsdk = ZSDK();

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant.text = data.weerks;
    }
    dateTime.text = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    super.initState();
  }

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      if (mounted) {
        _weighingCubit.resetScaleWeighing();
        _weighingCubit.setSelectedEquipment(scannedBarcode);
        if (_weighingCubit.state.selectedEquipment.equipmentNo.isNotEmpty) {
          _weighingCubit.setScaleWeighing(_weighingCubit.state.scaleWeighing
              .copyWith(
                  scaleName:
                      _weighingCubit.state.selectedEquipment.equipmentDesc,
                  scaleId: _weighingCubit.state.selectedEquipment.equipmentNo,
                  regex: _weighingCubit.state.selectedEquipment.regex,
                  urlAddress:
                      _weighingCubit.state.selectedEquipment.urlAddress));
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
            _weighingCubit.state.selectedEquipment.regex.replaceAll("\s", " "),
        caseSensitive: false,
        multiLine: true,
      );
      socket = await Socket.connect(
          _weighingCubit.state.selectedEquipment.urlAddress, 4001);
      print("Connected");
      _weighingCubit.setStartWork();
      _weighingCubit.setConnectedStatus(true);
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
            var a = dataReg[1]!.replaceAll(",", ".");
            var taraDouble = double.parse(a);

            tara.text = taraDouble.toStringAsFixed(2);
            scale.text = _weighingCubit.state.selectedEquipment.equipmentDesc;
            unit = dataReg[2]!;

            dataString = "";
          }
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
    _weighingCubit.setConnectedStatus(false);
    _weighingCubit.resetScaleWeighing();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ScaleBloc(),
        ),
      ],
      child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
        return Scaffold(
            appBar: AppBar(
              toolbarHeight: 100,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Print Tara"),
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
                    _weighingCubit.setTab(_weighingCubit.state.prevTab);
                  },
                  icon: const Icon(Icons.chevron_left_rounded)),
            ),
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
                            suffixIcon:
                                const Icon(Icons.qr_code_scanner_rounded)),
                        readOnly: true,
                      ),
                    ),
                    if (weighingState.isConnectedTcp) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: tara,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Tara',
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: tara.text.isNotEmpty
                            ? () async {
                                await zsdk.printZplDataOverTCPIP(
                                    address: _weighingCubit
                                        .state.selectedEquipment.ipPrinter,
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
                                ^FO200,390^FD${weighingState.selectedEquipment.equipmentDesc}^FS     ; Scale
                                ^FO30,425^FDOperator^FS     ; Operator
                                ^FO200,425^FD${weighingState.operator}^FS     ; Operator
                                ^CF0,30 
                                ^FO30,550^FDTotal Weight^FS     ; Total Weight
                                ^FO290,550^FB180,,,R^FD${tara.text}^FS           ; Aligned value
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
                                      content: const Text("Label printed"),
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
                                      content: const Text("failed to print"),
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
                          backgroundColor:
                              tara.text.isNotEmpty ? Colors.black : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Print Tara",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                        ),
                      ))),
            ));
      }),
    );
  }
}
