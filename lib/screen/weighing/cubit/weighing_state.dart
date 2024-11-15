part of 'weighing_cubit.dart';

enum WeighingStatus { weighing, scaleWeighing, scale }

@immutable
class WeighingState extends Equatable {
  final String plant;
  final String materialCode;
  final String date;
  final String operationApps;
  final String operationType;
  final WeighingStatus tab;
  final ResultsOrder orderList;
  final List<ResultsOrder> orders;
  final ResultOperation operationList;
  final bool isResultOperationLoaded;
  final bool isConnectedTcp;
  final Scale scaleWeighing;
  final List<ResultTong> weighingList;
  final ResultTong selectedWeighing;
  final ResultsLabel label;
  final List<ResultScale> equipments;
  final ResultScale selectedEquipment;
  final String operator;
  final String pengawas;
  final List<ResultScaleList> resultScaleList;
  final int containerCounter;
  final String productiSupervisor;
  final String line;
  final List<ResultsOprType> operationTypeList;
  final ResultsOperationType resultsOpr;
  final String totalContainer;
  final DateTime? startWork;
  final bool onChangeStartWork;

  const WeighingState(
      {this.plant = "",
      this.materialCode = "",
      this.date = "",
      this.operationApps = "",
      this.operationType = "",
      this.tab = WeighingStatus.weighing,
      this.orderList = const ResultsOrder(),
      this.orders = const [],
      this.operationList = const ResultOperation(),
      this.isResultOperationLoaded = false,
      this.isConnectedTcp = false,
      this.scaleWeighing = const Scale(),
      this.weighingList = const [],
      this.selectedWeighing = const ResultTong(),
      this.label = const ResultsLabel(),
      this.equipments = const [],
      this.selectedEquipment = const ResultScale(),
      this.operator = "",
      this.pengawas = "",
      this.resultScaleList = const [],
      this.containerCounter = 1,
      this.productiSupervisor = '',
      this.line = "",
      this.operationTypeList = const [],
      this.resultsOpr = const ResultsOperationType(),
      this.totalContainer = '',
      this.startWork,
      this.onChangeStartWork = false});

  WeighingState copyWith(
      {String? plant,
      String? materialCode,
      String? date,
      String? operationApps,
      String? operationType,
      WeighingStatus? tab,
      ResultsOrder? orderList,
      List<ResultsOrder>? orders,
      ResultOperation? operationList,
      bool? isResultOperationLoaded,
      bool? isConnectedTcp,
      Scale? scaleWeighing,
      List<ResultTong>? weighingList,
      ResultTong? selectedWeighing,
      ResultsLabel? label,
      List<ResultScale>? equipments,
      ResultScale? selectedEquipment,
      String? operator,
      String? pengawas,
      List<ResultScaleList>? resultScaleList,
      int? containerCounter,
      String? productiSupervisor,
      String? line,
      List<ResultsOprType>? operationTypeList,
      ResultsOperationType? resultsOpr,
      String? totalContainer,
      DateTime? startWork,
      bool? onChangeStartWork}) {
    return WeighingState(
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        date: date ?? this.date,
        operationApps: operationApps ?? this.operationApps,
        operationType: operationType ?? this.operationType,
        tab: tab ?? this.tab,
        orderList: orderList ?? this.orderList,
        orders: orders ?? this.orders,
        operationList: operationList ?? this.operationList,
        isResultOperationLoaded:
            isResultOperationLoaded ?? this.isResultOperationLoaded,
        isConnectedTcp: isConnectedTcp ?? this.isConnectedTcp,
        scaleWeighing: scaleWeighing ?? this.scaleWeighing,
        weighingList: weighingList ?? this.weighingList,
        selectedWeighing: selectedWeighing ?? this.selectedWeighing,
        label: label ?? this.label,
        equipments: equipments ?? this.equipments,
        selectedEquipment: selectedEquipment ?? this.selectedEquipment,
        operator: operator ?? this.operator,
        pengawas: pengawas ?? this.pengawas,
        resultScaleList: resultScaleList ?? this.resultScaleList,
        containerCounter: containerCounter ?? this.containerCounter,
        productiSupervisor: productiSupervisor ?? this.productiSupervisor,
        line: line ?? this.line,
        operationTypeList: operationTypeList ?? this.operationTypeList,
        resultsOpr: resultsOpr ?? this.resultsOpr,
        totalContainer: totalContainer ?? this.totalContainer,
        startWork: startWork ?? this.startWork,
        onChangeStartWork: onChangeStartWork ?? this.onChangeStartWork);
  }

  @override
  List<Object> get props => [
        plant,
        materialCode,
        date,
        operationApps,
        operationType,
        tab,
        orderList,
        orders,
        operationList,
        isResultOperationLoaded,
        isConnectedTcp,
        scaleWeighing,
        weighingList,
        selectedWeighing,
        label,
        equipments,
        selectedEquipment,
        operator,
        pengawas,
        resultScaleList,
        containerCounter,
        productiSupervisor,
        line,
        operationTypeList,
        resultsOpr,
        totalContainer,
        onChangeStartWork
      ];
}
