import 'dart:io';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/models/response/volume.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_2_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/submit_weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/volume_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dumping_system/screen/weighing/helpers/network_label_printer.dart';
import 'package:dumping_system/screen/weighing/helpers/zpl.dart';

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
  VolumeBloc volumeBloc = VolumeBloc();
  final temperature = TextEditingController();
  final temperatureEnd = TextEditingController();
  final topMoistureContent = TextEditingController();
  final middleMoistureContent = TextEditingController();
  final bottomMoistureContent = TextEditingController();
  final numberOfContainer = TextEditingController();
  final volumeLiterLqd = TextEditingController();
  final scale = TextEditingController();
  final bruto = TextEditingController();
  final tara = TextEditingController();
  final netto = TextEditingController();
  final line = TextEditingController();
  final lot = TextEditingController();
  bool isLdConect = false;
  Socket? socket;
  String weight = "";
  String scannedBarcode = '';
  String plant = '';
  RegExp replaceZero = RegExp(r"^0{2,}", caseSensitive: true, multiLine: false);
  RegExp replaceDoubleSpace = RegExp(r"\s+");
  String gramasi = '';
  Scale scaleD = const Scale();
  final String title = '';
  final labelPrinter = NetworkLabelPrinter();
  ResultScaleBloc resultScaleBloc = ResultScaleBloc();
  ResultScale2Bloc resultScale2Bloc = ResultScale2Bloc();
  int totalCont = 0;
  ScaleBloc scaleBloc = ScaleBloc();
  List<ResultVolume> volume = [];
  List<DropdownMenuEntry<String>> menuEntries = [];
  String? volumeValue;
  bool isLast = false;
  bool isFirst = false;

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
        // _weighingCubit.resetScaleWeighing();
        _weighingCubit.setSelectedEquipment(scannedBarcode);
        if (_weighingCubit.state.productiSupervisor == 'LQD') {
          isLdConect = true;
          _weighingCubit.setStartWork();
          _weighingCubit.setScaleWeighing(_weighingCubit.state.scaleWeighing
              .copyWith(
                  bruto: _parseDouble(volumeValue),
                  netto: _parseDouble(volumeValue),
                  numberOfContainer: numberOfContainer.text,
                  unit: 'l'));
        }
        if (_weighingCubit.state.selectedEquipment.equipmentNo.isNotEmpty) {
          _weighingCubit.setScaleWeighing(_weighingCubit.state.scaleWeighing
              .copyWith(
                  scaleName:
                      _weighingCubit.state.selectedEquipment.equipmentDesc,
                  scaleId: _weighingCubit.state.selectedEquipment.equipmentNo,
                  regex: _weighingCubit.state.selectedEquipment.regex,
                  urlAddress:
                      _weighingCubit.state.selectedEquipment.urlAddress));
          if (_weighingCubit.state.productiSupervisor != 'LQD') {
            tCPListen();
          }
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
    numberOfContainer.text = '';
    _weighingCubit.resetResultScale();
    _weighingCubit.resetScaleWeighing();
  }

  _onChangeNettoLqd(value) {
    _weighingCubit.setScaleWeighing(_weighingCubit.state.scaleWeighing.copyWith(
        bruto: _parseDouble(value),
        netto: _parseDouble(value),
        numberOfContainer: numberOfContainer.text,
        unit: 'l'));
  }

  bool checkOperationType() {
    switch (_weighingCubit.state.operationType) {
      case 'DECOCT':
        if (numberOfContainer.text.isNotEmpty &&
            bruto.text.isNotEmpty &&
            tara.text.isNotEmpty &&
            netto.text.isNotEmpty &&
            lot.text.isNotEmpty &&
            line.text.isNotEmpty) {
          return true;
        }
        break;
      case 'CB':
        if (topMoistureContent.text.isNotEmpty &&
            middleMoistureContent.text.isNotEmpty &&
            bottomMoistureContent.text.isNotEmpty &&
            numberOfContainer.text.isNotEmpty &&
            bruto.text.isNotEmpty &&
            tara.text.isNotEmpty &&
            netto.text.isNotEmpty &&
            line.text.isNotEmpty) {
          return true;
        }
        break;
      case 'CK':
        if (numberOfContainer.text.isNotEmpty &&
            bruto.text.isNotEmpty &&
            tara.text.isNotEmpty &&
            netto.text.isNotEmpty &&
            line.text.isNotEmpty) {
          return true;
        }
        break;
      case 'LIQUID MIXING':
        if (numberOfContainer.text.isNotEmpty &&
            netto.text.isNotEmpty &&
            line.text.isNotEmpty) {
          return true;
        }
        break;
    }
    return false;
  }

  int _parseInt(String? value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    return int.tryParse(value.trim()) ?? fallback;
  }

  double _parseDouble(String? value, {double fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? fallback;
  }

  int _maxWadah(List<ResultScaleList> results) {
    return results.fold<int>(
      0,
      (max, item) {
        final wadah = _parseInt(item.wadah);
        return wadah > max ? wadah : max;
      },
    );
  }

  String _resolveTotalContainer(
    ResultScaleList? dataLabel,
    WeighingState weighingState,
  ) {
    final candidates = [
      dataLabel?.totalWadah,
      weighingState.totalContainer,
      weighingState.scaleWeighing.numberOfContainer,
      numberOfContainer.text,
    ];

    for (final candidate in candidates) {
      final total = _parseInt(candidate);
      if (total > 0) {
        return total.toString();
      }
    }

    final currentWadah = _parseInt(dataLabel?.wadah);
    if (currentWadah > 0) {
      return currentWadah.toString();
    }

    return '';
  }

  int _validTotalContainer(WeighingState weighingState) {
    return _parseInt(_resolveTotalContainer(null, weighingState));
  }

  String _safeWadah(ResultScaleList dataLabel) {
    final wadah = _parseInt(dataLabel.wadah, fallback: 1);
    return wadah < 1 ? '1' : wadah.toString();
  }

  String _counterText(ResultScaleList dataLabel, WeighingState weighingState) {
    final wadah = _safeWadah(dataLabel);
    final total = _resolveTotalContainer(dataLabel, weighingState);
    return '$wadah/${total.isNotEmpty ? total : '-'}';
  }

  String _weightText(String? value) {
    return _parseDouble(value).toStringAsFixed(2);
  }

  String _safeText(String? value) {
    return value?.trim() ?? '';
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  String _formatSapDateTime(String? date, String? time) {
    if (date == null || date.isEmpty) {
      return '';
    }

    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) {
      return '';
    }

    final safeTime = time ?? '';
    final hours = safeTime.length >= 2 ? safeTime.substring(0, 2) : '00';
    final minutes = safeTime.length >= 4 ? safeTime.substring(2, 4) : '00';
    final seconds = safeTime.length >= 6 ? safeTime.substring(4, 6) : '00';
    final formattedDate = DateFormat('dd.MM.yyyy').format(parsedDate);
    return '$formattedDate $hours:$minutes:$seconds';
  }

  ZplData? _zplDataFromResult(
    ResultScaleList dataLabel,
    WeighingState weighingState,
  ) {
    final totalContainer = _resolveTotalContainer(dataLabel, weighingState);
    if (totalContainer.isEmpty) {
      _showError('Total container kosong dari server');
      return null;
    }

    final startWork = _formatSapDateTime(
      dataLabel.createdDate,
      dataLabel.createdTime,
    );
    if (startWork.isEmpty) {
      _showError('Tanggal weighing tidak valid');
      return null;
    }

    final stagingTime = _formatSapDateTime(
      dataLabel.expiredDate,
      dataLabel.expiredTime,
    );

    return ZplData(
      materialCode: weighingState.materialCode,
      materialDesc: _safeText(weighingState.resultsOpr.materialDesc),
      batchFG: _safeText(weighingState.selectedOrder.batchFG),
      orderNo: _safeText(dataLabel.orderNo),
      line: _safeText(dataLabel.line),
      equipmentDesc: _safeText(dataLabel.equipmentDesc),
      workCenterDesc: _safeText(dataLabel.resourceDesc),
      operationType: weighingState.operationType,
      operationDesc: _safeText(dataLabel.activityNoDesc),
      lot: _safeText(dataLabel.lot),
      operator: _safeText(dataLabel.operator),
      pengawas: _safeText(dataLabel.pengawas),
      stagingTime: stagingTime,
      totalContainer: totalContainer,
      containerConter: _safeWadah(dataLabel),
      bruto: _parseDouble(dataLabel.bruto),
      tara: _parseDouble(dataLabel.tara),
      netto: _parseDouble(dataLabel.netto),
      unit: _safeText(dataLabel.unitWeighing),
      expiredNo: '',
      expiredUnit: '',
      startWork: startWork,
      activityWh: _safeText(dataLabel.activityWh),
      activityNo: _safeText(dataLabel.activityNo),
      temperature: _safeText(dataLabel.temperature),
    );
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
          print(dataReg);
          if (dataReg != null) {
            var a = dataReg[1]!.replaceAll(",", ".");
            var brutoFloat = _parseDouble(a);
            var nettoFloat = brutoFloat;
            var taraFloat = 0.0;
            if (tara.text.isNotEmpty) {
              taraFloat = _parseDouble(tara.text);
            }

            if (dataReg[2] == '-') {
              brutoFloat *= -1;
            }
            _weighingCubit.setLine(line.text);
            _weighingCubit.setScaleWeighing(
              _weighingCubit.state.scaleWeighing.copyWith(
                  bruto: brutoFloat,
                  netto: nettoFloat,
                  tara: taraFloat,
                  unit: _safeText(dataReg[2])),
            );
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
    // _weighingCubit.resetScaleWeighing();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _weighingCubit,
        ),
        BlocProvider.value(value: submitWeighingBloc),
        BlocProvider<ResultScale2Bloc>(create: (context) => resultScale2Bloc),
        BlocProvider<VolumeBloc>(create: (context) => volumeBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<WeighingCubit, WeighingState>(
            listener: (context, state) {
              if (state.selectedOperation.operationDesc !=
                  state.selectedOperation.operationDesc2) {
                if (state.productiSupervisor == 'LQD') {
                  volumeBloc.add(GetVolume(plant: state.plant));
                  if (isFirst == false) {
                    if (state.containerCounter == _validTotalContainer(state)) {
                      isLast = true;
                      isFirst = true;
                    }
                  }
                }
                scale.text = state.selectedEquipment.equipmentDesc;
                if (state.productiSupervisor != 'LQD') {
                  bruto.text = state.scaleWeighing.bruto.toStringAsFixed(2);
                  netto.text = state.scaleWeighing.netto.toStringAsFixed(2);
                } else {
                  if (isLast == true) {
                    netto.clear();
                    bruto.clear();
                  }
                  isLast = false;
                }
                if (state.resultScales.isNotEmpty) {
                  if (state.operationType == 'CB') {
                    var moisture =
                        _safeText(state.resultScales[0].moistureContent)
                            .split(";");
                    if (moisture.length > 2) {
                      topMoistureContent.text = moisture[0];
                      middleMoistureContent.text = moisture[1];
                      bottomMoistureContent.text = moisture[2];
                    } else if (moisture.first.isNotEmpty) {
                      topMoistureContent.text = moisture[0];
                    }
                  }
                  final totalContainer =
                      _resolveTotalContainer(state.resultScales[0], state);
                  if (totalContainer.isNotEmpty) {
                    numberOfContainer.text = totalContainer;
                    _weighingCubit.setTotalContainer(totalContainer);
                  }
                  line.text = _safeText(state.resultScales[0].line);
                  scale.text = _safeText(state.resultScales[0].equipmentDesc);
                  var cancelWadah =
                      _safeText(state.resultScales[0].cancelWadah).split(';');
                  if (_safeText(state.resultScales[0].cancelWadah).isEmpty) {
                    _weighingCubit.setContainerCounter(
                      _maxWadah(state.resultScales) + 1,
                    );
                  } else {
                    _weighingCubit.setContainerCounter(
                      _parseInt(cancelWadah[0], fallback: 1),
                    );
                  }
                }
              } else {
                if (state.productiSupervisor == 'LQD') {
                  volumeBloc.add(GetVolume(plant: state.plant));
                  if (isFirst == false) {
                    if (state.containerCounter == _validTotalContainer(state)) {
                      isLast = true;
                      isFirst = true;
                    }
                  }
                }
                scale.text = state.selectedEquipment.equipmentDesc;
                if (state.productiSupervisor != 'LQD') {
                  bruto.text = state.scaleWeighing.bruto.toStringAsFixed(2);
                  netto.text = state.scaleWeighing.netto.toStringAsFixed(2);
                } else {
                  volumeBloc.add(GetVolume(plant: state.plant));
                  if (state.containerCounter == _validTotalContainer(state)) {
                    if (!isLast) {
                      netto.clear();
                    }
                    isLast = true;
                  }
                }
                if (state.resultScales2.isNotEmpty) {
                  if (state.operationType == 'CB') {
                    var moisture =
                        _safeText(state.resultScales2[0].moistureContent)
                            .split(";");
                    temperature.text =
                        _safeText(state.resultScales2[0].temperature);
                    if (moisture.length > 2) {
                      topMoistureContent.text = moisture[0];
                      middleMoistureContent.text = moisture[1];
                      bottomMoistureContent.text = moisture[2];
                    } else if (moisture.first.isNotEmpty) {
                      topMoistureContent.text = moisture[0];
                    }
                  }
                  final totalContainer =
                      _resolveTotalContainer(state.resultScales2[0], state);
                  if (totalContainer.isNotEmpty) {
                    numberOfContainer.text = totalContainer;
                    _weighingCubit.setTotalContainer(totalContainer);
                  }
                  line.text = _safeText(state.resultScales2[0].line);
                  scale.text = _safeText(state.resultScales2[0].equipmentDesc);
                  var cancelWadah =
                      _safeText(state.resultScales2[0].cancelWadah).split(';');
                  if (_safeText(state.resultScales2[0].cancelWadah).isEmpty) {
                    _weighingCubit.setContainerCounter(
                      _maxWadah(state.resultScales2) + 1,
                    );
                  } else {
                    _weighingCubit.setContainerCounter(
                      _parseInt(cancelWadah[0], fallback: 1),
                    );
                  }
                }
              }
            },
          ),
          BlocListener<SubmitWeighingBloc, SubmitWeighingState>(
              listener: (context, state) async {
            switch (state) {
              case SubmitWeighingSuccess():
                var sumCont = _weighingCubit.state.containerCounter;
                if (sumCont == _parseInt(numberOfContainer.text)) {
                  print("All Done");
                } else {
                  _weighingCubit.setContainerCounter(sumCont + 1);
                }
                temperature.clear();
                temperatureEnd.clear();
                lot.clear();
                tara.clear();
                if (_weighingCubit.state.productiSupervisor == 'LQD') {
                  _weighingCubit.setScaleWeighing(
                      _weighingCubit.state.scaleWeighing.copyWith(
                          bruto: _parseDouble(
                              state.submitWeighing.submitWeighing?.bruto),
                          netto: _parseDouble(
                              state.submitWeighing.submitWeighing?.netto),
                          numberOfContainer: numberOfContainer.text,
                          unit: 'l'));
                }
                if (_weighingCubit.state.selectedOperation.operationDesc !=
                    _weighingCubit.state.selectedOperation.operationDesc2) {
                  resultScaleBloc.add(SendDataResultScale(
                      orderNo:
                          _weighingCubit.state.selectedOrder.orderNo != null
                              ? _weighingCubit.state.selectedOrder.orderNo!
                              : '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo,
                      activityWh: _weighingCubit.state.operationType == 'DECOCT'
                          ? ''
                          : _weighingCubit.state.selectedContainer.activityWh !=
                                  null
                              ? _weighingCubit
                                  .state.selectedContainer.activityWh!
                              : '',
                      operationType: _weighingCubit.state.operationType));
                } else {
                  resultScale2Bloc.add(SendDataResultScale2(
                      orderNo:
                          _weighingCubit.state.selectedOrder.orderNo != null
                              ? _weighingCubit.state.selectedOrder.orderNo!
                              : '',
                      activityNo:
                          _weighingCubit.state.selectedOperation.activityNo,
                      activityWh: _weighingCubit.state.operationType == 'DECOCT'
                          ? ''
                          : _weighingCubit.state.selectedContainer.activityWh !=
                                  null
                              ? _weighingCubit
                                  .state.selectedContainer.activityWh!
                              : '',
                      objectName:
                          _weighingCubit.state.selectedOperation.objectName!,
                      operationType: _weighingCubit.state.operationType));
                }
                final submitData = state.submitWeighing.submitWeighing;
                final weighingTime = _formatSapDateTime(
                  submitData?.startDate,
                  submitData?.startTime,
                );
                final stagingTime = _formatSapDateTime(
                  submitData?.expiredDate,
                  submitData?.expiredTime,
                );
                final totalContainer = [
                  submitData?.totalWadah,
                  _weighingCubit.state.totalContainer,
                  numberOfContainer.text,
                ]
                    .map((value) => _parseInt(value))
                    .firstWhere((total) => total > 0, orElse: () => 0);

                if (weighingTime.isEmpty || totalContainer == 0) {
                  _showError('Data label dari server belum lengkap');
                  break;
                }
                _weighingCubit.setStartWork();
                var zplData = ZplData(
                    materialCode: _weighingCubit.state.materialCode,
                    materialDesc: _safeText(
                        _weighingCubit.state.selectedOrder.materialDesc),
                    batchFG:
                        _safeText(_weighingCubit.state.selectedOrder.batchFG),
                    orderNo: _safeText(submitData?.orderNo),
                    line: _safeText(submitData?.line),
                    equipmentDesc:
                        _weighingCubit.state.selectedEquipment.equipmentDesc,
                    workCenterDesc: _safeText(
                        _weighingCubit.state.expiredSet.workCenterDesc),
                    operationType: _weighingCubit.state.operationType,
                    operationDesc:
                        _weighingCubit.state.selectedOperation.operationDesc,
                    lot: _weighingCubit.state.operationType == 'DECOCT'
                        ? _weighingCubit.state.scaleWeighing.lot == '-'
                            ? _safeText(
                                _weighingCubit.state.selectedContainer.lot)
                            : _weighingCubit.state.scaleWeighing.lot
                        : _safeText(_weighingCubit.state.selectedContainer.lot),
                    operator: _safeText(submitData?.operator),
                    pengawas: _safeText(submitData?.pengawas),
                    stagingTime: stagingTime,
                    totalContainer: totalContainer.toString(),
                    containerConter: _safeText(submitData?.wadah),
                    bruto: _parseDouble(submitData?.bruto),
                    tara: _parseDouble(submitData?.tara),
                    netto: _parseDouble(submitData?.netto),
                    unit: _safeText(submitData?.unitWeighing),
                    expiredNo: _weighingCubit.state.expiredSet.expiredNo ?? '',
                    expiredUnit: _weighingCubit.state.expiredSet.unit ?? '',
                    startWork: weighingTime,
                    activityWh: _safeText(submitData?.activityWh),
                    activityNo: _safeText(submitData?.activityNo),
                    temperature: _safeText(submitData?.temperature));
                final printed = await labelPrinter.printWeighingLabel(
                  address: _weighingCubit.state.selectedEquipment.ipPrinter,
                  data: zplData,
                  printerType:
                      _weighingCubit.state.selectedEquipment.printerType,
                );
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(printed ? "Label printed" : "failed to print"),
                  backgroundColor: printed ? Colors.black : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                break;
              case SubmitWeighingError():
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
          BlocListener<ResultScaleBloc, ResultScaleState>(
              listener: (context, state) {
            if (state is ResultScaleLoaded) {
              final results = state.resultScale.d?.results ?? [];
              if (results.isEmpty) {
                _showError('Data weighing belum tersedia');
                return;
              }
              if (_weighingCubit.state.selectedEquipment.equipmentNo.isEmpty) {
                _weighingCubit
                    .setSelectedEquipment(_safeText(results[0].equipmentNo));
              }
              _weighingCubit.setResultScaleList(results);
              line.text = _safeText(results[0].line);
              _weighingCubit.setLine(line.text);
            } else if (state is ResultScaleError) {
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
          BlocListener<ResultScale2Bloc, ResultScale2State>(
              listener: (context, state) {
            if (state is ResultScale2Loaded) {
              final results = state.resultScale2.d?.results ?? [];
              if (results.isEmpty) {
                _showError('Data weighing belum tersedia');
                return;
              }
              if (_weighingCubit.state.selectedEquipment.equipmentNo.isEmpty) {
                _weighingCubit
                    .setSelectedEquipment(_safeText(results[0].equipmentNo));
              }
              _weighingCubit.setResultScales2(results);
              line.text = _safeText(results[0].line);
              _weighingCubit.setLine(line.text);
            } else if (state is ResultScale2Error) {
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
          BlocListener<VolumeBloc, VolumeState>(listener: (context, state) {
            if (state is VolumeLoaded) {
              volume = state.volume.d?.results ?? [];
              setState(() {
                menuEntries = volume
                    .map((e) => DropdownMenuEntry<String>(
                          value: _safeText(e.volume),
                          label: _safeText(e.volume),
                        ))
                    .where((entry) => entry.value.isNotEmpty)
                    .toList();

                volumeValue ??= volume.isNotEmpty ? volume.first.volume! : '';
              });
            } else if (state is VolumeError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ));
            }
          })
        ],
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                toolbarHeight: 100,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Scale Weighing ${weighingState.selectedOperation.operationDesc}"),
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
                    _weighingCubit.resetScaleWeighing();
                    _weighingCubit.resetResultScale();
                    tara.clear();
                    line.clear();
                    numberOfContainer.clear();
                    lot.clear();
                    temperature.clear();
                    if (weighingState.isConnectedTcp) {
                      closeConnection();
                    }
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
                                    weighingState.selectedOrder.material != null
                                        ? '(${weighingState.selectedOrder.material}) ${weighingState.selectedOrder.materialDesc}'
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
                                    weighingState.selectedOrder.orderNo != null
                                        ? weighingState.selectedOrder.orderNo!
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
                                    weighingState.selectedOrder.batchFG != null
                                        ? weighingState.selectedOrder.batchFG!
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
                                    weighingState.selectedOperation.activityNo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    '${weighingState.selectedOperation.operationDesc} / ${weighingState.selectedContainer.operationDesc}',
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
                                  _validTotalContainer(weighingState) ||
                              (weighingState.resultScales.isNotEmpty &&
                                  weighingState.resultScales.length <
                                      _validTotalContainer(weighingState))
                          ? TextButton(
                              onPressed: checkOperationType()
                                  ? () {
                                      submitWeighingBloc.add(SendDataWeighing(
                                          weighingState: weighingState));
                                      print(weighingState.scaleWeighing);
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                backgroundColor: checkOperationType()
                                    ? Colors.black
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Save & Print Label ${weighingState.containerCounter}/${_validTotalContainer(weighingState)}",
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
                                _validTotalContainer(weighingState) == 0
                                    ? null
                                    : context.go('/home');
                                if (weighingState.isConnectedTcp) {
                                  closeConnection();
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    _validTotalContainer(weighingState) == 0
                                        ? Colors.grey
                                        : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _validTotalContainer(weighingState) == 0
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
                    if (weighingState.operationType == "DECOCT")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: temperature,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _weighingCubit.setScaleWeighing(_weighingCubit
                                      .state.scaleWeighing
                                      .copyWith(
                                          temperature:
                                              '$value;${temperatureEnd.text}'));
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: 'Temperature Start',
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
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: temperatureEnd,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _weighingCubit.setScaleWeighing(_weighingCubit
                                      .state.scaleWeighing
                                      .copyWith(
                                          temperature:
                                              '${temperature.text};$value'));
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelText: 'Temperature End',
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
                          ],
                        ),
                      ),
                    if (weighingState.operationType == "CB")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: topMoistureContent,
                                keyboardType: TextInputType.number,
                                readOnly: weighingState.resultScales.isNotEmpty,
                                onChanged: (value) {
                                  _weighingCubit.setScaleWeighing(_weighingCubit
                                      .state.scaleWeighing
                                      .copyWith(
                                          moistureContent:
                                              '$value;${middleMoistureContent.text};${bottomMoistureContent.text}'));
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Top Moisture Content',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    suffixIcon: const Icon(Icons.percent)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: middleMoistureContent,
                                keyboardType: TextInputType.number,
                                readOnly: weighingState.resultScales.isNotEmpty,
                                onChanged: (value) {
                                  _weighingCubit.setScaleWeighing(_weighingCubit
                                      .state.scaleWeighing
                                      .copyWith(
                                          moistureContent:
                                              '${topMoistureContent.text};$value;${bottomMoistureContent.text}'));
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Middle Moisture Content',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    suffixIcon: const Icon(Icons.percent)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: bottomMoistureContent,
                                keyboardType: TextInputType.number,
                                readOnly: weighingState.resultScales.isNotEmpty,
                                onChanged: (value) {
                                  _weighingCubit.setScaleWeighing(_weighingCubit
                                      .state.scaleWeighing
                                      .copyWith(
                                          moistureContent:
                                              '${topMoistureContent.text};${middleMoistureContent.text};$value'));
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Bottom Moisture Content',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    suffixIcon: const Icon(Icons.percent)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (weighingState.productiSupervisor == 'LQD') ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            return DropdownMenu<String>(
                              width: w,
                              menuStyle: MenuStyle(
                                minimumSize:
                                    WidgetStateProperty.all(Size(w, 0)),
                                maximumSize: WidgetStateProperty.all(
                                    Size(w, double.infinity)),
                              ),
                              dropdownMenuEntries: menuEntries,
                              initialSelection: volumeValue,
                              onSelected: (String? value) {
                                setState(() => volumeValue = value);
                                netto.text = _safeText(value);
                                bruto.text = _safeText(value);
                                _weighingCubit.setScaleWeighing(
                                    _weighingCubit.state.scaleWeighing.copyWith(
                                        bruto: _parseDouble(volumeValue),
                                        netto: _parseDouble(volumeValue),
                                        numberOfContainer:
                                            numberOfContainer.text));
                              },
                              label: const Text('Volume'),
                            );
                          },
                        ),
                      )
                    ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: numberOfContainer,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _weighingCubit.setTotalContainer(value);
                          _weighingCubit.setScaleWeighing(_weighingCubit
                              .state.scaleWeighing
                              .copyWith(numberOfContainer: value));
                        },
                        readOnly: weighingState.resultScales.isNotEmpty &&
                            weighingState.selectedOperation.operationDesc !=
                                weighingState.selectedOperation.operationDesc2,
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
                    if (weighingState.operationType == 'DECOCT')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: lot,
                          onChanged: (value) {
                            _weighingCubit.setScaleWeighing(_weighingCubit
                                .state.scaleWeighing
                                .copyWith(lot: value));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Lot',
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
                          onChanged: (value) {
                            _weighingCubit.setScaleWeighing(_weighingCubit
                                .state.scaleWeighing
                                .copyWith(tara: _parseDouble(value)));
                          },
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
                    ],
                    if (weighingState.productiSupervisor == 'LQD' && isLdConect)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: netto,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Netto',
                              hintText: "0.0",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffix: const Text("L")),
                          onFieldSubmitted: (value) {
                            _onChangeNettoLqd(value);
                          },
                        ),
                      ),
                    if (weighingState.selectedOperation.operationDesc !=
                        weighingState.selectedOperation.operationDesc2) ...[
                      if (weighingState.resultScales.isNotEmpty) ...[
                        DataTable(
                          columns: [
                            DataColumn(
                                label: Text(
                              'Counter',
                              style: Theme.of(context).textTheme.bodySmall,
                            )),
                            DataColumn(
                                label: Text('Bruto',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Tara',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Netto',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Act',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                          ],
                          rows: [
                            for (var dataLabel in weighingState.resultScales)
                              DataRow(cells: [
                                DataCell(Text(
                                    _counterText(dataLabel, weighingState))),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.bruto),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.tara),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.netto),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(IconButton(
                                    onPressed: () {
                                      if (weighingState.selectedEquipment
                                          .ipPrinter.isNotEmpty) {
                                        print(weighingState
                                            .selectedEquipment.ipPrinter);
                                        print(dataLabel.temperature);
                                        var zplData = _zplDataFromResult(
                                          dataLabel,
                                          weighingState,
                                        );
                                        if (zplData == null) {
                                          return;
                                        }
                                        labelPrinter
                                            .printWeighingLabel(
                                                address: weighingState
                                                    .selectedEquipment
                                                    .ipPrinter,
                                                data: zplData,
                                                printerType: weighingState
                                                    .selectedEquipment
                                                    .printerType)
                                            .then((printed) {
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(printed
                                                ? "Label printed"
                                                : "failed to print"),
                                            backgroundColor: printed
                                                ? Colors.black
                                                : Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ));
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              const Text("Please Scan Scale"),
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
                      ]
                    ] else ...[
                      if (weighingState.resultScales2.isNotEmpty) ...[
                        DataTable(
                          columns: [
                            DataColumn(
                                label: Text(
                              'Counter',
                              style: Theme.of(context).textTheme.bodySmall,
                            )),
                            DataColumn(
                                label: Text('Bruto',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Tara',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Netto',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                            DataColumn(
                                label: Text('Act',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
                          ],
                          rows: [
                            for (var dataLabel in weighingState.resultScales2)
                              DataRow(cells: [
                                DataCell(Text(
                                    _counterText(dataLabel, weighingState))),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.bruto),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.tara),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: _weightText(dataLabel.netto),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' ${_safeText(dataLabel.unitWeighing)}'),
                                    ],
                                  ),
                                )),
                                DataCell(IconButton(
                                    onPressed: () {
                                      if (weighingState.selectedEquipment
                                          .ipPrinter.isNotEmpty) {
                                        print(weighingState
                                            .selectedEquipment.ipPrinter);
                                        var zplData = _zplDataFromResult(
                                          dataLabel,
                                          weighingState,
                                        );
                                        if (zplData == null) {
                                          return;
                                        }

                                        labelPrinter
                                            .printWeighingLabel(
                                                address: weighingState
                                                    .selectedEquipment
                                                    .ipPrinter,
                                                data: zplData,
                                                printerType: weighingState
                                                    .selectedEquipment
                                                    .printerType)
                                            .then((printed) {
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(printed
                                                ? "Label printed"
                                                : "failed to print"),
                                            backgroundColor: printed
                                                ? Colors.black
                                                : Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ));
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              const Text("Please Scan Scale"),
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
                      ]
                    ]
                  ],
                ),
              ));
        },
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    closeConnection();
    // _weighingCubit.resetScaleWeighing();
  }
}
