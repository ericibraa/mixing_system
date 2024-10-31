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
      this.selectedWeighing = const ResultTong()});

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
      ResultTong? selectedWeighing}) {
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
        selectedWeighing: selectedWeighing ?? this.selectedWeighing);
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
        selectedWeighing
      ];
}
