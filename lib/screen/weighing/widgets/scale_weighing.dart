import 'dart:io';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/models/response/volume.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_2_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/result_scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/scale_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/submit_weighing_bloc.dart';
import 'package:dumping_system/screen/weighing/bloc/volume_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zsdk/zsdk.dart';
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
  final zsdk = ZSDK();
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
        _weighingCubit.resetScaleWeighing();
        _weighingCubit.setSelectedEquipment(scannedBarcode);
        if (_weighingCubit.state.productiSupervisor == 'LQD') {
          isLdConect = true;
          _weighingCubit.setStartWork();
          scaleD = Scale(
            bruto: double.parse(volumeValue!),
            netto: double.parse(volumeValue!),
            numberOfContainer: numberOfContainer.text,
            unit: 'l',
          );
          _weighingCubit.setScaleWeighing(scaleD);
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
    scaleD = Scale(
      netto: double.parse(value),
      bruto: double.parse(value),
      unit: 'l',
      numberOfContainer: numberOfContainer.text,
    );
    _weighingCubit.setScaleWeighing(scaleD);
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
        ;
    }
    return false;
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
            var brutoFloat = double.parse(a);
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
                moistureContent:
                    '${topMoistureContent.text};${middleMoistureContent.text};${bottomMoistureContent.text}',
                numberOfContainer: numberOfContainer.text,
                temperature: '${temperature.text};${temperatureEnd.text}',
                lot: lot.text);
            _weighingCubit.setLine(line.text);
            _weighingCubit.setScaleWeighing(scaleD);
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
                    if (state.containerCounter ==
                        int.parse(state.totalContainer)) {
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
                  print(isLast);
                  if (isLast == true) {
                    netto.clear();
                    bruto.clear();
                  }
                  isLast = false;
                }
                ResultScaleList wadah = ResultScaleList();
                if (state.resultScales.isNotEmpty) {
                  wadah = state.resultScales.reduce((current, next) =>
                      int.parse(current.wadah!) > int.parse(next.wadah!)
                          ? current
                          : next);
                }
                if (state.resultScales.isNotEmpty) {
                  if (state.operationType == 'CB') {
                    var moisture =
                        state.resultScales[0].moistureContent!.split(";");
                    if (moisture.length > 1) {
                      topMoistureContent.text = moisture[0];
                      middleMoistureContent.text = moisture[1];
                      bottomMoistureContent.text = moisture[2];
                    } else {
                      topMoistureContent.text = moisture[0];
                    }
                  }
                  line.text = state.resultScales[0].line!;
                  numberOfContainer.text =
                      int.parse(state.resultScales[0].totalWadah!).toString();
                  line.text = state.resultScales[0].line!;
                  scale.text = state.resultScales[0].equipmentDesc!;
                  _weighingCubit
                      .setTotalContainer(state.resultScales[0].totalWadah!);
                  var cancelWadah =
                      state.resultScales[0].cancelWadah!.split(';');
                  if (state.resultScales[0].cancelWadah!.isEmpty) {
                    _weighingCubit
                        .setContainerCounter(int.parse(wadah.wadah!) + 1);
                  } else {
                    _weighingCubit
                        .setContainerCounter(int.parse(cancelWadah[0]));
                  }
                }
              } else {
                if (state.productiSupervisor == 'LQD') {
                  volumeBloc.add(GetVolume(plant: state.plant));
                  if (isFirst == false) {
                    if (state.containerCounter ==
                        int.parse(state.totalContainer)) {
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
                  if (state.containerCounter ==
                      int.parse(state.totalContainer)) {
                    if (!isLast) {
                      netto.clear();
                    }
                    isLast = true;
                  }
                }
                ResultScaleList wadah = ResultScaleList();
                if (state.resultScales2.isNotEmpty) {
                  wadah = state.resultScales2.reduce((current, next) =>
                      int.parse(current.wadah!) > int.parse(next.wadah!)
                          ? current
                          : next);
                }
                if (state.resultScales2.isNotEmpty) {
                  if (state.operationType == 'CB') {
                    var moisture =
                        state.resultScales2[0].moistureContent!.split(";");
                    temperature.text = state.resultScales2[0].temperature!;
                    if (moisture.length > 1) {
                      topMoistureContent.text = moisture[0];
                      middleMoistureContent.text = moisture[1];
                      bottomMoistureContent.text = moisture[2];
                    } else {
                      topMoistureContent.text = moisture[0];
                    }
                  }
                  line.text = state.resultScales2[0].line!;
                  numberOfContainer.text =
                      int.parse(state.resultScales2[0].totalWadah!).toString();
                  line.text = state.resultScales2[0].line!;
                  scale.text = state.resultScales2[0].equipmentDesc!;
                  _weighingCubit
                      .setTotalContainer(state.resultScales2[0].totalWadah!);
                  var cancelWadah =
                      state.resultScales2[0].cancelWadah!.split(';');
                  if (state.resultScales2[0].cancelWadah!.isEmpty) {
                    _weighingCubit
                        .setContainerCounter(int.parse(wadah.wadah!) + 1);
                  } else {
                    _weighingCubit
                        .setContainerCounter(int.parse(cancelWadah[0]));
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
                if (sumCont == int.parse(numberOfContainer.text)) {
                  print("All Done");
                } else {
                  _weighingCubit.setContainerCounter(sumCont + 1);
                }
                temperature.clear();
                lot.clear();
                tara.clear();
                if (_weighingCubit.state.productiSupervisor == 'LQD') {
                  scaleD = Scale(
                    netto: _weighingCubit.state.scaleWeighing.netto,
                    bruto: _weighingCubit.state.scaleWeighing.netto,
                    unit: 'l',
                    numberOfContainer: numberOfContainer.text,
                  );
                  _weighingCubit.setScaleWeighing(scaleD);
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
                var stagingTime = '';
                String weighingTime =
                    "${state.submitWeighing.submitWeighing!.startDate!.substring(6, 8)}.${state.submitWeighing.submitWeighing!.startDate!.substring(4, 6)}.${state.submitWeighing.submitWeighing!.startDate!.substring(0, 4)} "
                    "${state.submitWeighing.submitWeighing!.startTime!.substring(0, 2)}:${state.submitWeighing.submitWeighing!.startTime!.substring(2, 4)}:${state.submitWeighing.submitWeighing!.startTime!.substring(4, 6)}";
                if (state.submitWeighing.submitWeighing!.expiredDate!
                        .isNotEmpty &&
                    state.submitWeighing.submitWeighing!.expiredTime!
                        .isNotEmpty) {
                  stagingTime =
                      "${state.submitWeighing.submitWeighing!.expiredDate!.substring(6, 8)}.${state.submitWeighing.submitWeighing!.expiredDate!.substring(4, 6)}.${state.submitWeighing.submitWeighing!.expiredDate!.substring(0, 4)} "
                      "${state.submitWeighing.submitWeighing!.expiredTime!.substring(0, 2)}:${state.submitWeighing.submitWeighing!.expiredTime!.substring(2, 4)}:${state.submitWeighing.submitWeighing!.expiredTime!.substring(4, 6)}";
                }
                _weighingCubit.setStartWork();
                var zplData = ZplData(
                        materialCode: _weighingCubit.state.materialCode,
                        materialDesc:
                            _weighingCubit.state.selectedOrder.materialDesc!,
                        batchFG: _weighingCubit.state.selectedOrder.batchFG!,
                        orderNo: state.submitWeighing.submitWeighing!.orderNo!,
                        line: state.submitWeighing.submitWeighing!.line!,
                        equipmentDesc: _weighingCubit
                            .state.selectedEquipment.equipmentDesc,
                        workCenterDesc:
                            _weighingCubit.state.expiredSet.workCenterDesc!,
                        operationType: _weighingCubit.state.operationType,
                        operationDesc: _weighingCubit
                            .state.selectedOperation.operationDesc,
                        lot: _weighingCubit.state.operationType == 'DECOCT'
                            ? _weighingCubit.state.scaleWeighing.lot == '-'
                                ? _weighingCubit.state.selectedContainer.lot!
                                : _weighingCubit.state.scaleWeighing.lot
                            : _weighingCubit.state.selectedContainer.lot!,
                        operator:
                            state.submitWeighing.submitWeighing!.operator!,
                        pengawas:
                            state.submitWeighing.submitWeighing!.pengawas!,
                        stagingTime:
                            state.submitWeighing.submitWeighing!.expiredDate !=
                                    ''
                                ? stagingTime
                                : '',
                        totalContainer:
                            state.submitWeighing.submitWeighing!.totalWadah!,
                        containerConter:
                            state.submitWeighing.submitWeighing!.wadah!,
                        bruto: double.parse(
                            state.submitWeighing.submitWeighing!.bruto!),
                        tara: double.parse(
                            state.submitWeighing.submitWeighing!.tara!),
                        netto: double.parse(
                            state.submitWeighing.submitWeighing!.netto!),
                        unit:
                            state.submitWeighing.submitWeighing!.unitWeighing!,
                        expiredNo:
                            _weighingCubit.state.expiredSet.expiredNo ?? '',
                        expiredUnit: _weighingCubit.state.expiredSet.unit ?? '',
                        startWork: weighingTime,
                        activityWh:
                            state.submitWeighing.submitWeighing!.activityWh!,
                        activityNo:
                            state.submitWeighing.submitWeighing!.activityNo!,
                        temperature:
                            state.submitWeighing.submitWeighing!.temperature!)
                    .getZpl();
                await zsdk
                    .printZplDataOverTCPIP(
                        address:
                            _weighingCubit.state.selectedEquipment.ipPrinter,
                        port: 9100,
                        data: zplData)
                    .then((value) {
                  final printerResponse = PrinterResponse.fromMap(value);
                  Status status = printerResponse.statusInfo.status;
                  print(status);
                  if (printerResponse.errorCode == ErrorCode.SUCCESS) {
                    print("printer connect");
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
                    Cause cause = printerResponse.statusInfo.cause;
                    print(cause);
                  }
                });
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
              if (_weighingCubit.state.selectedEquipment.equipmentNo.isEmpty) {
                _weighingCubit.setSelectedEquipment(
                    state.resultScale.d!.results![0].equipmentNo!);
              }
              _weighingCubit.setResultScaleList(state.resultScale.d!.results!);
              line.text = state.resultScale.d!.results![0].line!;
              _weighingCubit.setLine(line.text);
            }
          }),
          BlocListener<ResultScale2Bloc, ResultScale2State>(
              listener: (context, state) {
            if (state is ResultScale2Loaded) {
              if (_weighingCubit.state.selectedEquipment.equipmentNo.isEmpty) {
                _weighingCubit.setSelectedEquipment(
                    state.resultScale2.d!.results![0].equipmentNo!);
              }
              _weighingCubit.setResultScales2(state.resultScale2.d!.results!);
              line.text = state.resultScale2.d!.results![0].line!;
              _weighingCubit.setLine(line.text);
            }
          }),
          BlocListener<VolumeBloc, VolumeState>(listener: (context, state) {
            if (state is VolumeLoaded) {
              volume = state.volume.d!.results!;
              setState(() {
                menuEntries = volume
                    .map((e) => DropdownMenuEntry<String>(
                          value: e.volume!,
                          label: e.volume!,
                        ))
                    .toList();

                volumeValue ??= volume.isNotEmpty ? volume.first.volume! : '';
              });
            }
          })
        ],
        child: BlocBuilder<WeighingCubit, WeighingState>(
          builder: (context, weighingState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: Text(
                    "Scale Weighing ${weighingState.selectedOperation.operationDesc}"),
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
                                  int.parse(weighingState.totalContainer != ''
                                      ? weighingState.totalContainer
                                      : '0') ||
                              (weighingState.resultScales.isNotEmpty &&
                                  weighingState.resultScales.length <
                                      int.parse(
                                          weighingState.totalContainer != ''
                                              ? weighingState.totalContainer
                                              : '0'))
                          ? TextButton(
                              onPressed: checkOperationType()
                                  ? () {
                                      submitWeighingBloc.add(SendDataWeighing(
                                          weighingState: weighingState));
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
                                if (weighingState.isConnectedTcp) {
                                  closeConnection();
                                }
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
                    if (weighingState.operationType == "DECOCT")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: temperature,
                                keyboardType: TextInputType.number,
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
                                netto.text = value!;
                                bruto.text = value;
                                scaleD = Scale(
                                    bruto: double.parse(volumeValue!),
                                    netto: double.parse(volumeValue!),
                                    numberOfContainer: numberOfContainer.text);
                                _weighingCubit.setScaleWeighing(scaleD);
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
                            var tara = double.parse(value);
                            _weighingCubit.setScaleWeighing(_weighingCubit
                                .state.scaleWeighing
                                .copyWith(tara: tara));
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
                                    '${int.parse(dataLabel.wadah!)}/${int.parse(dataLabel.totalWadah!)}')),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.bruto != null
                                            ? dataLabel.bruto!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.tara != null
                                            ? dataLabel.tara!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.netto != null
                                            ? dataLabel.netto!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
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
                                        DateTime parsedDate = DateTime.parse(
                                            dataLabel.createdDate!);
                                        String hours = dataLabel.createdTime!
                                            .substring(0, 2);
                                        String minutes = dataLabel.createdTime!
                                            .substring(2, 4);
                                        String seconds = dataLabel.createdTime!
                                            .substring(4, 6);
                                        DateTime parsedExpDate;
                                        String hoursExp = '';
                                        String minutesExp = '';
                                        String secondsExp = '';
                                        String formattedExpDate = '';
                                        String finalExpDate = '';
                                        String finalExpTime = '';
                                        if (dataLabel.expiredDate != '') {
                                          parsedExpDate = DateTime.parse(
                                              dataLabel.expiredDate!);
                                          hoursExp = dataLabel.expiredTime!
                                              .substring(0, 2);
                                          minutesExp = dataLabel.expiredTime!
                                              .substring(2, 4);
                                          secondsExp = dataLabel.expiredTime!
                                              .substring(4, 6);
                                          formattedExpDate =
                                              DateFormat('dd.MM.yyyy')
                                                  .format(parsedExpDate);
                                          finalExpDate = formattedExpDate;
                                          finalExpTime =
                                              '$hoursExp:$minutesExp:$secondsExp';
                                        }
                                        String formattedDate =
                                            DateFormat('dd.MM.yyyy')
                                                .format(parsedDate);
                                        var zplData = ZplData(
                                                materialCode:
                                                    weighingState.materialCode,
                                                materialDesc: weighingState
                                                    .resultsOpr.materialDesc!,
                                                batchFG: weighingState
                                                    .selectedOrder.batchFG!,
                                                orderNo: dataLabel.orderNo!,
                                                line: dataLabel.line!,
                                                equipmentDesc:
                                                    dataLabel.equipmentDesc!,
                                                workCenterDesc:
                                                    dataLabel.resourceDesc!,
                                                operationType:
                                                    weighingState.operationType,
                                                operationDesc:
                                                    dataLabel.activityNoDesc!,
                                                lot: dataLabel.lot!,
                                                operator: dataLabel.operator!,
                                                pengawas: dataLabel.pengawas!,
                                                stagingTime:
                                                    '$finalExpDate $finalExpTime',
                                                totalContainer:
                                                    dataLabel.totalWadah!,
                                                containerConter:
                                                    dataLabel.wadah!,
                                                bruto: double.parse(
                                                    dataLabel.bruto != null
                                                        ? dataLabel.bruto!
                                                        : ''),
                                                tara: double.parse(
                                                    dataLabel.tara != null
                                                        ? dataLabel.tara!
                                                        : ''),
                                                netto: double.parse(
                                                    dataLabel.netto != null
                                                        ? dataLabel.netto!
                                                        : ''),
                                                unit: dataLabel.unitWeighing!,
                                                expiredNo: '',
                                                expiredUnit: '',
                                                startWork: '$formattedDate $hours:$minutes:$seconds',
                                                activityWh: dataLabel.activityWh!,
                                                activityNo: dataLabel.activityNo!,
                                                temperature: dataLabel.temperature!)
                                            .getZpl();

                                        zsdk
                                            .printZplDataOverTCPIP(
                                                address: weighingState
                                                    .selectedEquipment
                                                    .ipPrinter,
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
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                                  const Text("Label printed"),
                                              backgroundColor: Colors.black,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ));
                                          } else {
                                            Cause cause = printerResponse
                                                .statusInfo.cause;
                                            print(cause);
                                          }
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
                                    '${int.parse(dataLabel.wadah!)}/${int.parse(dataLabel.totalWadah!)}')),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.bruto != null
                                            ? dataLabel.bruto!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.tara != null
                                            ? dataLabel.tara!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
                                    ],
                                  ),
                                )),
                                DataCell(RichText(
                                  text: TextSpan(
                                    text: double.parse(dataLabel.netto != null
                                            ? dataLabel.netto!
                                            : '')
                                        .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ${dataLabel.unitWeighing}'),
                                    ],
                                  ),
                                )),
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
                                        DateTime parsedExpDate;
                                        String hoursExp = '';
                                        String minutesExp = '';
                                        String secondsExp = '';
                                        String formattedExpDate = '';
                                        String finalExpDate = '';
                                        String finalExpTime = '';
                                        if (dataLabel.expiredDate != '') {
                                          parsedExpDate = DateTime.parse(
                                              dataLabel.expiredDate!);
                                          hoursExp = dataLabel.expiredTime!
                                              .substring(0, 2);
                                          minutesExp = dataLabel.expiredTime!
                                              .substring(2, 4);
                                          secondsExp = dataLabel.expiredTime!
                                              .substring(4, 6);
                                          formattedExpDate =
                                              DateFormat('dd.MM.yyyy')
                                                  .format(parsedExpDate);
                                          finalExpDate = formattedExpDate;
                                          finalExpTime =
                                              '$hoursExp:$minutesExp:$secondsExp';
                                        }
                                        String formattedDate =
                                            DateFormat('dd.MM.yyyy')
                                                .format(parsedDate);
                                        var zplData = ZplData(
                                                materialCode:
                                                    weighingState.materialCode,
                                                materialDesc: weighingState
                                                    .resultsOpr.materialDesc!,
                                                batchFG: weighingState
                                                    .selectedOrder.batchFG!,
                                                orderNo: dataLabel.orderNo!,
                                                line: dataLabel.line!,
                                                equipmentDesc:
                                                    dataLabel.equipmentDesc!,
                                                workCenterDesc:
                                                    dataLabel.resourceDesc!,
                                                operationType:
                                                    weighingState.operationType,
                                                operationDesc:
                                                    dataLabel.activityNoDesc!,
                                                lot: dataLabel.lot!,
                                                operator: dataLabel.operator!,
                                                pengawas: dataLabel.pengawas!,
                                                stagingTime:
                                                    '$finalExpDate $finalExpTime',
                                                totalContainer:
                                                    dataLabel.totalWadah!,
                                                containerConter:
                                                    dataLabel.wadah!,
                                                bruto: double.parse(
                                                    dataLabel.bruto != null
                                                        ? dataLabel.bruto!
                                                        : ''),
                                                tara: double.parse(
                                                    dataLabel.tara != null
                                                        ? dataLabel.tara!
                                                        : ''),
                                                netto: double.parse(
                                                    dataLabel.netto != null
                                                        ? dataLabel.netto!
                                                        : ''),
                                                unit: dataLabel.unitWeighing!,
                                                expiredNo: '',
                                                expiredUnit: '',
                                                startWork: '$formattedDate $hours:$minutes:$seconds',
                                                activityWh: dataLabel.activityWh!,
                                                activityNo: dataLabel.activityNo!,
                                                temperature: dataLabel.temperature!)
                                            .getZpl();

                                        zsdk
                                            .printZplDataOverTCPIP(
                                                address: weighingState
                                                    .selectedEquipment
                                                    .ipPrinter,
                                                port: 9100,
                                                data: zplData)
                                            .then((value) {
                                          final printerResponse =
                                              PrinterResponse.fromMap(value);
                                          Status status =
                                              printerResponse.statusInfo.status;
                                          print("=====================");
                                          print(status);
                                          if (printerResponse.errorCode ==
                                              ErrorCode.SUCCESS) {
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                                  const Text("Label printed"),
                                              backgroundColor: Colors.black,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ));
                                          } else {
                                            Cause cause = printerResponse
                                                .statusInfo.cause;
                                            print(cause);
                                            print(
                                                "============================error");
                                          }
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
    _weighingCubit.resetScaleWeighing();
  }
}
