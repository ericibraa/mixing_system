part of 'handover_cubit.dart';

enum HandoverStatus { handover, scantong, scantongmaterial }

@immutable
class HandoverState extends Equatable {
  final String operator;
  final String pengawas;
  final String plant;
  final String materialCode;
  final String date;
  final String operationType;
  final ResultsOrder selectedOperation;
  final ResultOperation selectedOperationNumber;
  final HandoverStatus tab;
  final List<ResultTong> tongs;
  final String tong;
  final bool isLoadingTong;
  final bool isResultOperationLoaded;
  final bool isComplete;
  final bool isCompleteTong;
  final bool isCompleteMaterials;
  final String startDate;
  final List<ResultsFullPack> fullpack;
  final bool isLoadingFullpack;
  final List<ResultsMaterialset> materialSet;
  final bool isLoadingMaterialset;
  final String line;
  final String operationApps;
  final bool isChecked;
  final bool isNullData;

  const HandoverState(
      {this.operator = '',
      this.pengawas = '',
      this.plant = "",
      this.materialCode = "",
      this.date = "",
      this.operationType = "",
      this.selectedOperation = const ResultsOrder(),
      this.selectedOperationNumber = const ResultOperation(),
      this.tab = HandoverStatus.handover,
      this.tongs = const [],
      this.tong = "",
      this.isLoadingTong = false,
      this.isResultOperationLoaded = false,
      this.isComplete = false,
      this.isCompleteTong = false,
      this.isCompleteMaterials = false,
      this.startDate = "",
      this.fullpack = const [],
      this.isLoadingFullpack = false,
      this.materialSet = const [],
      this.isLoadingMaterialset = false,
      this.line = "",
      this.operationApps = "",
      this.isChecked = false,
      this.isNullData = false});

  HandoverState copyWith(
      {String? operator,
      String? pengawas,
      String? plant,
      String? materialCode,
      String? date,
      String? operationType,
      ResultsOrder? selectedOperation,
      ResultOperation? selectedOperationNumber,
      HandoverStatus? tab,
      List<ResultTong>? tongs,
      String? tong,
      bool? isLoadingTong,
      bool? isResultOperationLoaded,
      bool? isComplete,
      bool? isCompleteTong,
      bool? isCompleteMaterials,
      String? startDate,
      List<ResultsFullPack>? fullpack,
      bool? isLoadingFullpack,
      List<ResultsMaterialset>? materialSet,
      bool? isLoadingMaterialset,
      String? line,
      String? operationApps,
      bool? isChecked,
      bool? isNullData}) {
    return HandoverState(
        operator: operator ?? this.operator,
        pengawas: pengawas ?? this.pengawas,
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        date: date ?? this.date,
        operationType: operationType ?? this.operationType,
        selectedOperation: selectedOperation ?? this.selectedOperation,
        selectedOperationNumber:
            selectedOperationNumber ?? this.selectedOperationNumber,
        tab: tab ?? this.tab,
        tongs: tongs ?? this.tongs,
        tong: tong ?? this.tong,
        isLoadingTong: isLoadingTong ?? this.isLoadingTong,
        isResultOperationLoaded:
            isResultOperationLoaded ?? this.isResultOperationLoaded,
        isComplete: isComplete ?? this.isComplete,
        isCompleteTong: isCompleteTong ?? this.isCompleteTong,
        isCompleteMaterials: isCompleteMaterials ?? this.isCompleteMaterials,
        startDate: startDate ?? this.startDate,
        fullpack: fullpack ?? this.fullpack,
        isLoadingFullpack: isLoadingFullpack ?? this.isLoadingFullpack,
        materialSet: materialSet ?? this.materialSet,
        isLoadingMaterialset: isLoadingMaterialset ?? this.isLoadingMaterialset,
        line: line ?? this.line,
        operationApps: operationApps ?? this.operationApps,
        isChecked: isChecked ?? this.isChecked,
        isNullData: isNullData ?? this.isNullData);
  }

  @override
  List<Object> get props => [
        operator,
        pengawas,
        plant,
        materialCode,
        date,
        operationType,
        selectedOperation,
        selectedOperationNumber,
        tab,
        tongs,
        tong,
        isLoadingTong,
        isResultOperationLoaded,
        isComplete,
        startDate,
        fullpack,
        isLoadingFullpack,
        materialSet,
        isLoadingMaterialset,
        line,
        operationApps,
        isCompleteMaterials,
        isCompleteTong,
        isChecked,
        isNullData
      ];
}
