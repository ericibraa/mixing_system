import 'dart:io';
import 'dart:typed_data';
import 'package:dumping_system/screen/weighing/bloc/label_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/submit_weighing_bloc.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart' as printer;
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
  LabelBloc labelBloc = LabelBloc();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();
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
  RegExp replaceZero = RegExp(r"^0{2,}", caseSensitive: true, multiLine: false);
  RegExp replaceDoubleSpace = RegExp(r"\s+");
  String gramasi = '';
  Scale scaleD = const Scale();
  final String title = '';

  Future<List<int>> prtintData() async {
    final profile = await printer.CapabilityProfile.load();
    // Set up a custom width for A7 paper
    final generator = printer.Generator(printer.PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text('PRODUK DALAM PROSES',
        styles: const printer.PosStyles(
            align: printer.PosAlign.center,
            bold: true,
            height: printer.PosTextSize.size1));
    bytes += generator.text('Product          001-00-03',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('BODREX/TAB 2X10\'S FBX',
        styles:
            const printer.PosStyles(align: printer.PosAlign.left, bold: true));
    bytes += generator.text('Batch            091604',
        styles:
            const printer.PosStyles(align: printer.PosAlign.left, bold: true));

    // Additional details, adjusted for A7 size
    bytes += generator.text('PrO              200107367',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Line             1.2',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Scale            AND HW 150 KGL',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Mesin            GRANULATION LT 1 - LINE 1',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Operation/Lot    Ayak Kering / 1',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Operator/PWS     TEST/TEST',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Tgl. Timbang     03.09.2024 11:23:22',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('Holding Time     10.09.2024 11:23:22',
        styles: const printer.PosStyles(align: printer.PosAlign.left));
    bytes += generator.text('CB',
        styles: const printer.PosStyles(align: printer.PosAlign.left));

    // Weight information for A7 size
    bytes += generator.hr(); // Horizontal line
    bytes += generator.row([
      printer.PosColumn(
          text: 'Nett',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.left)),
      printer.PosColumn(
          text: '93,000',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.right)),
    ]);
    bytes += generator.row([
      printer.PosColumn(
          text: 'Tara',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.left)),
      printer.PosColumn(
          text: '1,000',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.right)),
    ]);
    bytes += generator.row([
      printer.PosColumn(
          text: 'Bruto',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.left)),
      printer.PosColumn(
          text: '92,000',
          width: 6,
          styles: const printer.PosStyles(align: printer.PosAlign.right)),
    ]);

    // Footer with pagination for A7 size
    bytes += generator.text('1/6',
        styles: const printer.PosStyles(align: printer.PosAlign.right));

    bytes += generator.feed(2); // Add spacing at the end
    bytes += generator.cut(); // Cut the paper

    return bytes;
  }

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      if (mounted) {
        _weighingCubit.resetScaleWeighing();
        print(_weighingCubit.state.scaleUnit.equipmentNo == scannedBarcode);
        if (_weighingCubit.state.scaleUnit.equipmentNo == scannedBarcode) {
          _weighingCubit.setScaleWeighing(Scale(
              scaleId: _weighingCubit.state.scaleUnit.equipmentNo,
              scaleName: _weighingCubit.state.scaleUnit.equipmentDesc,
              urlAddress: _weighingCubit.state.scaleUnit.urlAddress,
              regex: _weighingCubit.state.scaleUnit.regex));
          tCPListen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("socket Error"),
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
    var data = authBloc.state;
    if (data is Authenticated) {
      plant = data.weerks;
    }
    tara.text = "0";
    labelBloc.add(SendDataLabel(
        orderNo: _weighingCubit.state.orderList.orderNo != null
            ? _weighingCubit.state.orderList.orderNo!
            : '',
        activityNo: _weighingCubit.state.operationList.activityNo != null
            ? _weighingCubit.state.operationList.activityNo!
            : ''));
    // resultScaleBloc.add(SendDataResultScale(orderNo: _weighingCubit.state, activityNo: activityNo, activityWh: activityWh))
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
        r"" + _weighingCubit.state.scaleWeighing.regex.replaceAll("\s", " "),
        caseSensitive: false,
        multiLine: true,
      );

      socket = await Socket.connect(
          _weighingCubit.state.scaleWeighing.urlAddress, 4001);
      print("Connected");
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
      socket.listen(
        (data) {
          if (counter == 20) {
            var dataReg = regExp.firstMatch(dataString);

            if (dataReg != null) {
              var brutoFloat = double.parse(dataReg[3]!);
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
                  unit: dataReg[4]!,
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
          socket.destroy();
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
          socket.destroy();
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
    socket.close();
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
        BlocProvider.value(value: labelBloc),
        BlocProvider.value(value: resultScaleBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WeighingCubit, WeighingState>(
            listener: (context, state) {
              scale.text = state.scaleWeighing.scaleName;
              bruto.text = state.scaleWeighing.bruto.toString();
              netto.text = state.scaleWeighing.netto.toStringAsFixed(2);
            },
          ),
          BlocListener<LabelBloc, LabelState>(listener: (context, state) {
            if (state is LabelLoaded) {
              for (var expired in state.label.d!.resultsLabel!) {
                _weighingCubit.setLabel(expired);
              }
            }
          }),
          BlocListener<ResultScaleBloc, ResultScaleState>(
              listener: (context, state) {
            if (state is ResultScaleLoaded) {
              _weighingCubit.setResultScaleList(state.resultScale.d!.results!);
            }
          }),
          BlocListener<SubmitWeighingBloc, SubmitWeighingState>(
              listener: (context, state) {
            if (state is SubmitWeighingSuccess) {
              var sumCont = _weighingCubit.state.containerCounter;
              if (sumCont >
                  int.parse(
                      _weighingCubit.state.scaleWeighing.numberOfContainer)) {
                print("All Done");
              } else {
                _weighingCubit.setContainer(sumCont++);
              }
            }
          })
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
                      child: TextButton(
                        onPressed: () {
                          submitWeighingBloc.add(
                              SendDataWeighing(weighingState: weighingState));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save & Print",
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Temperature',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Text(
                                '°C',
                                style: Theme.of(context).textTheme.titleLarge,
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
                              labelText: 'Scale',
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
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                suffix: Text(weighingState.scaleWeighing.unit)),
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
                                suffix: Text(weighingState.scaleWeighing.unit)),
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
                                suffix: Text(weighingState.scaleWeighing.unit)),
                            readOnly: true,
                          ),
                        ),
                      ],
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
                              suffix: const Text("l")),
                          readOnly: true,
                        ),
                      ),
                    ],
                    if (numberOfContainer.text != '')
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Container')),
                          DataColumn(label: Text('Bruto')),
                          DataColumn(label: Text('Tara')),
                          DataColumn(label: Text('Netto')),
                          DataColumn(label: Text('Act')),
                        ],
                        rows: [
                          for (var i = 0;
                              i < int.parse(numberOfContainer.text);
                              i++)
                            DataRow(cells: [
                              DataCell(
                                  Text('${i + 1}/${numberOfContainer.text}')),
                              const DataCell(Text('2002.9')),
                              const DataCell(Text('1000')),
                              const DataCell(Text('1002.9')),
                              const DataCell(Icon(Icons.print)),
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
