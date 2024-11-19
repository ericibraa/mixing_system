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
  final ResultsOrder selectedOrder;
  final List<ResultsOrder> orders;
  final ResultOperation selectedOperation;
  final bool isResultOperationLoaded;
  final bool isConnectedTcp;
  final Scale scaleWeighing;
  final List<ResultTong> containers;
  final ResultTong selectedContainer;
  final ResultsExpiredSet expiredSet;
  final List<ResultScale> equipments;
  final ResultScale selectedEquipment;
  final String operator;
  final String pengawas;
  final List<ResultScaleList> resultScales;
  final int containerCounter;
  final String productiSupervisor;
  final String line;
  final List<ResultsOprType> operationTypes;
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
      this.selectedOrder = const ResultsOrder(),
      this.orders = const [],
      this.selectedOperation = const ResultOperation(),
      this.isResultOperationLoaded = false,
      this.isConnectedTcp = false,
      this.scaleWeighing = const Scale(),
      this.containers = const [],
      this.selectedContainer = const ResultTong(),
      this.expiredSet = const ResultsExpiredSet(),
      this.equipments = const [],
      this.selectedEquipment = const ResultScale(),
      this.operator = "",
      this.pengawas = "",
      this.resultScales = const [],
      this.containerCounter = 1,
      this.productiSupervisor = '',
      this.line = "",
      this.operationTypes = const [],
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
      ResultsOrder? selectedOrder,
      List<ResultsOrder>? orders,
      ResultOperation? selectedOperation,
      bool? isResultOperationLoaded,
      bool? isConnectedTcp,
      Scale? scaleWeighing,
      List<ResultTong>? containers,
      ResultTong? selectedContainer,
      ResultsExpiredSet? expiredSet,
      List<ResultScale>? equipments,
      ResultScale? selectedEquipment,
      String? operator,
      String? pengawas,
      List<ResultScaleList>? resultScales,
      int? containerCounter,
      String? productiSupervisor,
      String? line,
      List<ResultsOprType>? operationTypes,
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
        selectedOrder: selectedOrder ?? this.selectedOrder,
        orders: orders ?? this.orders,
        selectedOperation: selectedOperation ?? this.selectedOperation,
        isResultOperationLoaded:
            isResultOperationLoaded ?? this.isResultOperationLoaded,
        isConnectedTcp: isConnectedTcp ?? this.isConnectedTcp,
        scaleWeighing: scaleWeighing ?? this.scaleWeighing,
        containers: containers ?? this.containers,
        selectedContainer: selectedContainer ?? this.selectedContainer,
        expiredSet: expiredSet ?? this.expiredSet,
        equipments: equipments ?? this.equipments,
        selectedEquipment: selectedEquipment ?? this.selectedEquipment,
        operator: operator ?? this.operator,
        pengawas: pengawas ?? this.pengawas,
        resultScales: resultScales ?? this.resultScales,
        containerCounter: containerCounter ?? this.containerCounter,
        productiSupervisor: productiSupervisor ?? this.productiSupervisor,
        line: line ?? this.line,
        operationTypes: operationTypes ?? this.operationTypes,
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
        selectedOrder,
        orders,
        selectedOperation,
        isResultOperationLoaded,
        isConnectedTcp,
        scaleWeighing,
        containers,
        selectedContainer,
        expiredSet,
        equipments,
        selectedEquipment,
        operator,
        pengawas,
        resultScales,
        containerCounter,
        productiSupervisor,
        line,
        operationTypes,
        resultsOpr,
        totalContainer,
        onChangeStartWork
      ];
}
