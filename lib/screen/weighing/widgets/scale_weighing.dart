import 'dart:io';
import 'dart:typed_data';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/submit_weighing_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zsdk/zsdk.dart';

class ScaleWeighingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ScaleWeighingScreen({Key? key}) : super(key: key);

  @override
  State<ScaleWeighingScreen> createState() => _ScaleWeighingScreenState();
}

class _ScaleWeighingScreenState extends State<ScaleWeighingScreen> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit _weighingCubit = WeighingCubit();
  ResultScale scaleData = const ResultScale();
  SubmitWeighingBloc submitWeighingBloc = SubmitWeighingBloc();
  final temperature = TextEditingController();
  final moistureContent = TextEditingController();
  final numberOfContainer = TextEditingController();
  final scale = TextEditingController();
  final bruto = TextEditingController();
  final tara = TextEditingController();
  final netto = TextEditingController();
  final line = TextEditingController();
  Socket? socket;
  String weight = "";
  String scannedBarcode = '';
  String plant = '';
  RegExp replaceZero = RegExp(r"^0{2,}", caseSensitive: true, multiLine: false);
  RegExp replaceDoubleSpace = RegExp(r"\s+");
  String gramasi = '';
  Scale scaleD = const Scale();
  final String title = '';
  final zsdk = ZSDK();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();
  int totalCont = 0;
  ScaleBloc scaleBloc = ScaleBloc();

  void scanLine(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      line.text = scannedBarcode;
      _weighingCubit.setLine(line.text);
    }
  }

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      if (mounted) {
        _weighingCubit.resetScaleWeighing();
        ResultScale selectedEquipment =
            _weighingCubit.state.equipments.firstWhere(
          (equpment) => equpment.equipmentNo == scannedBarcode,
          orElse: () => const ResultScale(),
        );
        if (selectedEquipment.equipmentNo.isNotEmpty) {
          _weighingCubit.setSelectedEquipment(selectedEquipment);
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

  @override
  void initState() {
    super.initState();
    _weighingCubit = BlocProvider.of<WeighingCubit>(context);
    resultScaleBloc = BlocProvider.of<ResultScaleBloc>(context);
    var data = authBloc.state;
    if (data is Authenticated) {
      plant = data.weerks;
    }
    tara.text = "";
  }

  void tCPListen() async {
    print("tcp listen");
    String dataString = "";
    int counter = 0;
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
          if (counter == 20) {
            var dataReg = regExp.firstMatch(dataString);
            if (dataReg != null) {
              print("===================");
              print(dataReg[1]!);
              var brutoFloat = double.parse(dataReg[1]!);
              var nettoFloat = brutoFloat;
              var taraFloat = 0.0;
              if (tara.text.isNotEmpty) {
                taraFloat = double.parse(tara.text);
              }

              if (dataReg[2] == '-') {
                brutoFloat *= -1;
              }
              scaleD = Scale(
                  scaleName: _weighingCubit.state.scaleWeighing.scaleName,
                  scaleId: _weighingCubit.state.scaleWeighing.scaleId,
                  regex: _weighingCubit.state.scaleWeighing.regex,
                  urlAddress: _weighingCubit.state.scaleWeighing.urlAddress,
                  bruto: brutoFloat,
                  netto: nettoFloat,
                  tara: taraFloat,
                  unit: dataReg[2]!,
                  moistureContent: moistureContent.text,
                  numberOfContainer: numberOfContainer.text,
                  temperature: temperature.text);
              _weighingCubit.setScaleWeighing(scaleD);
            }
            counter = 0;
            dataString = "";
          } else {
            dataString += String.fromCharCodes(data);
          }
          dataString = dataString.replaceAll(RegExp("[\n\t\r]"), "").trim();
          counter++;
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
          create: (context) => _weighingCubit,
        ),
        BlocProvider.value(value: submitWeighingBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WeighingCubit, WeighingState>(
            listener: (context, state) {
              scale.text = state.selectedEquipment.equipmentDesc;
              bruto.text = state.scaleWeighing.bruto.toString();
              netto.text = state.scaleWeighing.netto.toStringAsFixed(1);
              // ignore: unused_local_variable
              if (state.resultScaleList.isNotEmpty) {
                for (var data in state.resultScaleList) {
                  temperature.text = data.temperature!;
                  moistureContent.text = data.moistureContent!;
                  numberOfContainer.text =
                      int.parse(data.totalWadah!).toString();
                  line.text = data.line!;
                }
              }
            },
          ),
          BlocListener<SubmitWeighingBloc, SubmitWeighingState>(
              listener: (context, state) {
            if (state is SubmitWeighingSuccess) {
              var sumCont = _weighingCubit.state.containerCounter;
              if (sumCont == int.parse(numberOfContainer.text)) {
                print("All Done");
              } else {
                _weighingCubit.setContainerCounter(sumCont + 1);
              }
              resultScaleBloc.add(SendDataResultScale(
                  orderNo: _weighingCubit.state.orderList.orderNo != null
                      ? _weighingCubit.state.orderList.orderNo!
                      : '',
                  activityNo:
                      _weighingCubit.state.operationList.activityNo != null
                          ? _weighingCubit.state.operationList.activityNo!
                          : '',
                  activityWh:
                      _weighingCubit.state.selectedWeighing.activityWh != null
                          ? _weighingCubit.state.selectedWeighing.activityWh!
                          : ''));
              if (state.isPrinted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Label printed"),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("failed to print"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
              }
              _weighingCubit.setStartWork();
            }
          }),
          BlocListener<ResultScaleBloc, ResultScaleState>(
              listener: (context, state) {})
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: line,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ScanBarcodeScreen(
                                  onBarcodeScanned: (barcode) {
                                    scanLine(barcode);
                                  },
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Scan Line',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffixIcon:
                                  const Icon(Icons.qr_code_scanner_rounded)),
                          readOnly: true,
                        ),
                      ),
                      _formWeighing(context),
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
                      child: weighingState.containerCounter <=
                              int.parse(weighingState.totalContainer != ''
                                  ? weighingState.totalContainer
                                  : '0')
                          ? TextButton(
                              onPressed: temperature.text.isNotEmpty &&
                                      moistureContent.text.isNotEmpty &&
                                      numberOfContainer.text.isNotEmpty &&
                                      bruto.text.isNotEmpty &&
                                      tara.text.isNotEmpty &&
                                      netto.text.isNotEmpty &&
                                      line.text.isNotEmpty
                                  ? () {
                                      submitWeighingBloc.add(SendDataWeighing(
                                          weighingState: weighingState));
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                backgroundColor: temperature.text.isNotEmpty &&
                                        moistureContent.text.isNotEmpty &&
                                        numberOfContainer.text.isNotEmpty &&
                                        bruto.text.isNotEmpty &&
                                        tara.text.isNotEmpty &&
                                        netto.text.isNotEmpty &&
                                        line.text.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Save & Print Label ${weighingState.containerCounter}/${int.parse(weighingState.totalContainer)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                int.parse(weighingState.totalContainer != ''
                                            ? weighingState.totalContainer
                                            : '0') ==
                                        0
                                    ? null
                                    : context.go('/home');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: int.parse(
                                            weighingState.totalContainer != ''
                                                ? weighingState.totalContainer
                                                : '0') ==
                                        0
                                    ? Colors.grey
                                    : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                int.parse(weighingState.totalContainer != ''
                                            ? weighingState.totalContainer
                                            : '0') ==
                                        0
                                    ? "Save & Print Label"
                                    : "Complete",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _weighingCubit)],
      child: BlocBuilder<WeighingCubit, WeighingState>(
        builder: (context, weighingState) {
          return Container(
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
                        keyboardType: TextInputType.number,
                        readOnly: weighingState.resultScaleList.isNotEmpty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Temperature',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 7.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Text(
                                '°C',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: const Color.fromARGB(
                                            255, 95, 95, 95)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: moistureContent,
                        keyboardType: TextInputType.number,
                        readOnly: weighingState.resultScaleList.isNotEmpty,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Moisture Content',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            suffixIcon: const Icon(Icons.percent)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: numberOfContainer,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _weighingCubit.setTotalContainer(value);
                        },
                        readOnly: weighingState.resultScaleList.isNotEmpty,
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
                    if (weighingState.productiSupervisor != 'LQD') ...[
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
                            controller: bruto,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Bruto',
                                hintText: '0.0',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                suffix: Text(weighingState.scaleWeighing.unit
                                    .toUpperCase())),
                            readOnly: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: TextFormField(
                            controller: tara,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Tara',
                                hintText: "0",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                suffix: Text(weighingState.scaleWeighing.unit
                                    .toUpperCase())),
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
                                hintText: "0.0",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                suffix: Text(weighingState.scaleWeighing.unit
                                    .toUpperCase())),
                            readOnly: true,
                          ),
                        ),
                      ]
                    ] else ...[
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
                              suffix: const Text("L")),
                        ),
                      ),
                    ],
                    if (weighingState.resultScaleList.isNotEmpty)
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Container')),
                          DataColumn(label: Text('Bruto')),
                          DataColumn(label: Text('Tara')),
                          DataColumn(label: Text('Netto')),
                          DataColumn(label: Text('Act')),
                        ],
                        rows: [
                          for (var dataLabel in weighingState.resultScaleList)
                            DataRow(cells: [
                              DataCell(Text(
                                  '${int.parse(dataLabel.wadah!)}/${int.parse(dataLabel.totalWadah!)}')),
                              DataCell(Text(double.parse(dataLabel.bruto != null
                                      ? dataLabel.bruto!
                                      : '')
                                  .toStringAsFixed(1))),
                              DataCell(Text(double.parse(dataLabel.tara != null
                                      ? dataLabel.tara!
                                      : '')
                                  .toStringAsFixed(1))),
                              DataCell(Text(double.parse(dataLabel.netto != null
                                      ? dataLabel.netto!
                                      : '')
                                  .toStringAsFixed(1))),
                              DataCell(IconButton(
                                  onPressed: () {
                                    if (weighingState.selectedEquipment
                                        .ipPrinter.isNotEmpty) {
                                      print(weighingState
                                          .selectedEquipment.ipPrinter);
                                      DateTime parsedDate = DateTime.parse(
                                          dataLabel.createdDate!);
                                      String hours = dataLabel.createdTime!
                                          .substring(0, 2);
                                      String minutes = dataLabel.createdTime!
                                          .substring(2, 4);
                                      String seconds = dataLabel.createdTime!
                                          .substring(4, 6);
                                      DateTime parsedExpDate = DateTime.parse(
                                          dataLabel.expiredDate!);
                                      String hoursExp = dataLabel.expiredTime!
                                          .substring(0, 2);
                                      String minutesExp = dataLabel.expiredTime!
                                          .substring(2, 4);
                                      String secondsExp = dataLabel.expiredTime!
                                          .substring(4, 6);
                                      String formattedDate =
                                          DateFormat('dd.MM.yyyy')
                                              .format(parsedDate);
                                      String formattedExpDate =
                                          DateFormat('dd.MM.yyyy')
                                              .format(parsedExpDate);
                                      String zplData = '''
                                    ^XA
                                    ^PW560                           ; Set print width for portrait A7 (560 dots, approximately 74mm)
                                    ^LL800 
                                    ^FO10,25^GB550,765,2^FS      ; Full border around the label
                                    ^CF0, 22    ; General font
                                    ^FO30,40^GFA,357,357,7,,::00JF3IFC,007IF3IF8,003IF3IF,001IF3FFE,K033,::0JFI3IFC,07IFI3IFC,07IFI3IF8,03IFI3IF,01IFI3FFE,J0J3,::7IFJ31IFC,7IFK3IFC,7IFK3IF8,3IFK3IF,1IFK3IF,1IFK3FFE,I0L3,::::::::::::::::::::::,:::^FS      ; Logo
                                    ^FO0,55 ^FB570,,,C ^A0N,30^FDPRODUK DALAM PROSES^FS     ; Title 
                                    ^FO30,110^FDProduct^FS
                                    ^FO200,110^FD${weighingState.materialCode}^FS       ; Product code
                                    ^FO28,145 ^FB355,2,,L^A0N,30^FD${weighingState.resultsOpr.materialDesc}^FS     ; Product name
                                    ^FO28,215^A0N,30^FDBatch^FS
                                    ^FO200,215^A0N,30^FD${weighingState.orderList.batchFG}^FS        ; Batch number
                                    ^FO30,250 ^FDPrO^FS
                                    ^FO200,250^FD${dataLabel.orderNo}^FS      ; PrO number
                                    ^FO30,280^FDLine^FS
                                    ^FO200,280^FD${line.text}^FS         ; Line number
                                    ^FO30,310^FDScale^FS
                                    ^FO200,310^FD${dataLabel.equipmentDesc}^FS       ; Scale information
                                    ^FO30,340^FDMesin^FS
                                    ^FO200,340^FD${dataLabel.resourceDesc}^FS      ; Machine info
                                    ^FO30,370^FDOperation/Lot^FS
                                    ^FO200,370^FD${dataLabel.activityNoDesc} / ${dataLabel.lot}^FS       ; Operation/lot
                                    ^FO30,400^FDOperator/PWS^FS
                                    ^FO200,400^FD${dataLabel.operator}/${dataLabel.pengawas}^FS             ; Operator/PWS info
                                    ^FO30,430^FDTgl. Timbang^FS
                                    ^FO200,430^FD$formattedDate $hours:$minutes:$seconds^FS        ; Date and time
                                    ^FO30,460^FDHolding Time^FS
                                    ^FO200,460^FD$formattedExpDate $hoursExp:$minutesExp:$secondsExp^FS       ; Holding time
                                    ^FO30,490^A0N,30^FD${weighingState.operationType}^FS          ; CB label
                                    ^FO395,114 ^FB200,,,R^BQN,2,4^FDQA,${dataLabel.orderNo};${weighingState.materialCode};${dataLabel.activityNo};${dataLabel.activityNo};${weighingState.operationType};${dataLabel.netto};${dataLabel.wadah}/${dataLabel.totalWadah}^FS          ; QR code at top right
                                    ^FO470,540^A0N,20,20^FDJumlah^FS       
                                    ^FO30,575^FDNetto^FS                   ; "Nett" label
                                    ^FO290,575 ^FB200,,,R^FD${double.parse(dataLabel.netto != null ? dataLabel.netto! : '').toStringAsFixed(1)}^FS          ; Aligned value
                                    ^FO330,575 ^FB200,,,R^FD${dataLabel.unitWeighing}^FS                    ; Aligned unit
                                    ^FO30,610^FDTara^FS                   ; "Nett" label
                                    ^FO290,610 ^FB200,,,R^FD${double.parse(dataLabel.tara != null ? dataLabel.tara! : '').toStringAsFixed(1)}^FS           ; Aligned value
                                    ^FO330,610 ^FB200,,,R^FD${dataLabel.unitWeighing}^FS                    ; Aligned unit
                                    ^FO30,645^FDBruto^FS                   ; "Nett" label
                                    ^FO290,645 ^FB200,,,R^FD${double.parse(dataLabel.bruto != null ? dataLabel.netto! : '').toStringAsFixed(1)}^FS         ; Aligned value
                                    ^FO330,645 ^FB200,,,R^FD${dataLabel.unitWeighing}^FS                    ; Aligned unit
                                    ^FO485,755^FD${int.parse(dataLabel.wadah!)}/${int.parse(dataLabel.totalWadah!)}^FS        ; Page number
                                    ^XZ
                                    ''';

                                      zsdk
                                          .printZplDataOverTCPIP(
                                              address: weighingState
                                                  .selectedEquipment.ipPrinter,
                                              port: 9100,
                                              data: zplData)
                                          .then((value) {
                                        final printerResponse =
                                            PrinterResponse.fromMap(value);
                                        Status status =
                                            printerResponse.statusInfo.status;
                                        print(status);
                                        if (printerResponse.errorCode ==
                                            ErrorCode.SUCCESS) {
                                          print("Label Printed");
                                        } else {
                                          Cause cause =
                                              printerResponse.statusInfo.cause;
                                          print(cause);
                                        }
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text("Data is Scanned"),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ));
                                    }
                                  },
                                  icon: const Icon(Icons.print))),
                            ])
                        ],
                      ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget printPdf(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => generatePdf(format),
      ),
    );
  }

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    // Set A7 dimensions (74mm x 105mm) with a small margin
    var pdfPageFormat = const PdfPageFormat(
        74 * PdfPageFormat.mm, 105 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pdfPageFormat,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(
                left: 10, right: 10, top: 5, bottom: 5),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PRODUK DALAM PROSES',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                // Product details
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Product:',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(
                              '001-00-03',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'BODREX/TAB 2X10\'S FBX',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 8),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Batch:',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(
                              '091604',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('PrO: 200107367',
                            style: const pw.TextStyle(fontSize: 7)),
                        pw.SizedBox(height: 5),
                        pw.Text('Line: 1.2',
                            style: const pw.TextStyle(fontSize: 7)),
                        pw.SizedBox(height: 5),
                        pw.Text('Scale: AND HW 150 KGL',
                            style: const pw.TextStyle(fontSize: 7)),
                        pw.SizedBox(height: 5),
                      ],
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: '001-00-03',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),

                // Additional information
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Mesin: GRANULATION LT 1 - LINE 1',
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 5),
                    pw.Text('Operation/Lot: Ayak Kering / 1',
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 5),
                    pw.Text('Operator/PWS: TEST/TEST',
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 5),
                    pw.Text('Tgl. Timbang: 03.09.2024 11:23:22',
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 5),
                    pw.Text('Holding Time: 10.09.2024 11:23:22',
                        style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 5),
                    pw.Text("CK",
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold))
                  ],
                ),
                pw.SizedBox(height: 10),
                // Totals
                pw.Container(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text("Jumlah",
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Netto',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 7)),
                          pw.Text('93,000 KG',
                              style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Tara',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 7)),
                          pw.Text('1,000 KG',
                              style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Bruto',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 7)),
                          pw.Text('92,000 KG',
                              style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('1/6', style: const pw.TextStyle(fontSize: 7)),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  void deactivate() {
    super.deactivate();
    closeConnection();
  }
}
