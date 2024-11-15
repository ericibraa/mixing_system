part of 'confirmation_cubit.dart';

enum ConfirmationStatus { confirmation, formConfirmation }

@immutable
class ConfirmationState extends Equatable {
  final ConfirmationStatus tab;
  final String operator;
  final String pengawas;
  final List<ResultsMaterial> materials;
  final String productSupervisor;
  final List<ResultsOprType> operationTypes;
  final List<ResultsOrder> orders;
  final ResultsOrder selectedOrder;
  final List<ResultOperation> operations;
  final ResultOperation selectedOperation;
  final String plant;
  final String materialCode;
  final String operationType;
  final String operationApps;
  final String date;
  final ResultsYieldSet yieldSet;
  final String line;
  final DateTime? startTime;

  const ConfirmationState({
    this.tab = ConfirmationStatus.confirmation,
    this.operator = '',
    this.pengawas = '',
    this.materials = const [],
    this.productSupervisor = '',
    this.operationTypes = const [],
    this.orders = const [],
    this.selectedOrder = const ResultsOrder(),
    this.operations = const [],
    this.selectedOperation = const ResultOperation(),
    this.plant = '',
    this.materialCode = '',
    this.operationType = '',
    this.operationApps = '',
    this.date = '',
    this.yieldSet = const ResultsYieldSet(),
    this.line = '',
    this.startTime,
  });

  ConfirmationState copyWith(
      {ConfirmationStatus? tab,
      String? operator,
      String? pengawas,
      List<ResultsMaterial>? materials,
      String? productSupervisor,
      List<ResultsOprType>? operationTypes,
      List<ResultsOrder>? orders,
      ResultsOrder? selectedOrder,
      List<ResultOperation>? operations,
      ResultOperation? selectedOperation,
      String? plant,
      String? materialCode,
      String? operationType,
      String? operationApps,
      String? date,
      ResultsYieldSet? yieldSet,
      String? line,
      DateTime? startTime}) {
    return ConfirmationState(
        tab: tab ?? this.tab,
        operator: operator ?? this.operator,
        pengawas: pengawas ?? this.pengawas,
        materials: materials ?? this.materials,
        productSupervisor: productSupervisor ?? this.productSupervisor,
        operationTypes: operationTypes ?? this.operationTypes,
        orders: orders ?? this.orders,
        selectedOrder: selectedOrder ?? this.selectedOrder,
        operations: operations ?? this.operations,
        selectedOperation: selectedOperation ?? this.selectedOperation,
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        operationType: operationType ?? this.operationType,
        operationApps: operationApps ?? this.operationApps,
        date: date ?? this.date,
        yieldSet: yieldSet ?? this.yieldSet,
        line: line ?? this.line,
        startTime: startTime ?? this.startTime);
  }

  @override
  List<Object?> get props => [
        tab,
        operator,
        pengawas,
        materials,
        productSupervisor,
        operationTypes,
        orders,
        selectedOrder,
        operations,
        selectedOperation,
        plant,
        materialCode,
        operationType,
        operationApps,
        date,
        yieldSet,
        line,
        startTime
      ];
}
