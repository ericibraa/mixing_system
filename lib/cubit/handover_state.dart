part of 'handover_cubit.dart';

enum HandoverStatus { handover, scantong, scantongmaterial }

@immutable
class HandoverState extends Equatable {
  final String plant;
  final String materialCode;
  final String date;
  final String operationType;
  final ResultsOrder selectedOperation;
  final ResultOperation selectedOperationNumber;
  final HandoverStatus tab;
  final List<ResultTong> tongs;
  final bool isLoadingTong;
  final bool isResultOperationLoaded;
  final bool isComplete;
  final bool isCompleteTong;
  final String startDate;
  final List<ResultsFullPack> fullpack;
  final bool isLoadingFullpack;
  final List<ResultsMaterialset> materialSet;
  final bool isLoadingMaterialset;

  const HandoverState(
      {this.plant = "",
      this.materialCode = "",
      this.date = "",
      this.operationType = "",
      this.selectedOperation = const ResultsOrder(),
      this.selectedOperationNumber = const ResultOperation(),
      this.tab = HandoverStatus.handover,
      this.tongs = const [],
      this.isLoadingTong = false,
      this.isResultOperationLoaded = false,
      this.isComplete = false,
      this.isCompleteTong = false,
      this.startDate = "",
      this.fullpack = const [],
      this.isLoadingFullpack = false,
      this.materialSet = const [],
      this.isLoadingMaterialset = false});

  HandoverState copyWith(
      {String? plant,
      String? materialCode,
      String? date,
      String? operationType,
      ResultsOrder? selectedOperation,
      ResultOperation? selectedOperationNumber,
      HandoverStatus? tab,
      List<ResultTong>? tongs,
      bool? isLoadingTong,
      bool? isResultOperationLoaded,
      bool? isComplete,
      bool? isCompleteTong,
      String? startDate,
      List<ResultsFullPack>? fullpack,
      bool? isLoadingFullpack,
      List<ResultsMaterialset>? materialSet,
      bool? isLoadingMaterialset}) {
    return HandoverState(
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        date: date ?? this.date,
        operationType: operationType ?? this.operationType,
        selectedOperation: selectedOperation ?? this.selectedOperation,
        selectedOperationNumber:
            selectedOperationNumber ?? this.selectedOperationNumber,
        tab: tab ?? this.tab,
        tongs: tongs ?? this.tongs,
        isLoadingTong: isLoadingTong ?? this.isLoadingTong,
        isResultOperationLoaded:
            isResultOperationLoaded ?? this.isResultOperationLoaded,
        isComplete: isComplete ?? this.isComplete,
        isCompleteTong: isCompleteTong ?? this.isCompleteTong,
        startDate: startDate ?? this.startDate,
        fullpack: fullpack ?? this.fullpack,
        isLoadingFullpack: isLoadingFullpack ?? this.isLoadingFullpack,
        materialSet: materialSet ?? this.materialSet,
        isLoadingMaterialset:
            isLoadingMaterialset ?? this.isLoadingMaterialset);
  }

  @override
  List<Object> get props => [
        plant,
        materialCode,
        date,
        operationType,
        selectedOperation,
        selectedOperationNumber,
        tab,
        tongs,
        isLoadingTong,
        isResultOperationLoaded,
        isComplete,
        startDate,
        fullpack,
        isLoadingFullpack,
        materialSet,
        isLoadingMaterialset
      ];
}
