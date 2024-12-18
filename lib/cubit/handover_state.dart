part of 'handover_cubit.dart';

enum HandoverStatus {
  handover,
  scantong,
  chooseOperation,
  scantongmaterial,
  scanTongResultsWeighing,
  chooseLocation,
  scanMaterialMixing,
}

enum ErrorScanType { noError, dataScanned, dataNull, incorrectPriority }

@immutable
class HandoverState extends Equatable {
  final String operator;
  final String pengawas;
  final String plant;
  final String materialCode;
  final String date;
  final String operationType;
  final ResultsOrder selectedOrder;
  final List<ResultsOrder> orders;
  final ResultOperation selectedOperation;
  final List<ResultOperation> operations;
  final HandoverStatus tab;
  final HandoverStatus prevTab;
  final List<ResultTong> tongs;
  final String tong;
  final bool isLoadingTong;
  final bool isResultOperationLoaded;
  final bool isComplete;
  final bool isCompleteTong;
  final bool isCompleteMaterials;
  final bool isCompleteWeighingResults;
  final String startDate;
  final List<ResultsFullPack> fullpack;
  final bool isLoadingFullpack;
  final List<ResultsMaterialset> materialSet;
  final bool isLoadingMaterialset;
  final String line;
  final String operationApps;
  final bool isChecked;
  final bool isNullData;
  final List<ResultsOprType> operationTypeList;
  final bool isNext;
  final List<ResultsLocationSet> locationSets;
  final ResultsLocationSet selectedLocationSet;
  final List<ResultTong> wadah;
  final List<ResultsMaterial> materials;
  final String startTime;
  final bool isStartDateStatus;
  final ErrorScanType errorScanType;
  final bool isCompletedcontainer;

  const HandoverState(
      {this.operator = '',
      this.pengawas = '',
      this.plant = "",
      this.materialCode = "",
      this.date = "",
      this.operationType = "",
      this.selectedOrder = const ResultsOrder(),
      this.orders = const [],
      this.selectedOperation = const ResultOperation(),
      this.operations = const [],
      this.tab = HandoverStatus.handover,
      this.prevTab = HandoverStatus.handover,
      this.tongs = const [],
      this.tong = "",
      this.isLoadingTong = false,
      this.isResultOperationLoaded = false,
      this.isComplete = false,
      this.isCompleteTong = false,
      this.isCompleteMaterials = false,
      this.isCompleteWeighingResults = false,
      this.startDate = "",
      this.fullpack = const [],
      this.isLoadingFullpack = false,
      this.materialSet = const [],
      this.isLoadingMaterialset = false,
      this.line = "",
      this.operationApps = "",
      this.isChecked = false,
      this.isNullData = false,
      this.operationTypeList = const [],
      this.isNext = false,
      this.locationSets = const [],
      this.selectedLocationSet = const ResultsLocationSet(),
      this.wadah = const [],
      this.materials = const [],
      this.startTime = "",
      this.isStartDateStatus = false,
      this.errorScanType = ErrorScanType.noError,
      this.isCompletedcontainer = false});

  HandoverState copyWith(
      {String? operator,
      String? pengawas,
      String? plant,
      String? materialCode,
      String? date,
      String? operationType,
      ResultsOrder? selectedOrder,
      List<ResultsOrder>? orders,
      ResultOperation? selectedOperation,
      List<ResultOperation>? operations,
      HandoverStatus? tab,
      HandoverStatus? prevTab,
      List<ResultTong>? tongs,
      String? tong,
      bool? isLoadingTong,
      bool? isResultOperationLoaded,
      bool? isComplete,
      bool? isCompleteTong,
      bool? isCompleteMaterials,
      bool? isCompleteWeighingResults,
      String? startDate,
      List<ResultsFullPack>? fullpack,
      bool? isLoadingFullpack,
      List<ResultsMaterialset>? materialSet,
      bool? isLoadingMaterialset,
      String? line,
      String? operationApps,
      bool? isChecked,
      bool? isNullData,
      List<ResultsOprType>? operationTypeList,
      bool? isNext,
      List<ResultsLocationSet>? locationSets,
      ResultsLocationSet? selectedLocationSet,
      List<ResultTong>? wadah,
      List<ResultsMaterial>? materials,
      String? startTime,
      bool? isStartDateStatus,
      ErrorScanType? errorScanType,
      bool? isCompletedcontainer}) {
    return HandoverState(
        operator: operator ?? this.operator,
        pengawas: pengawas ?? this.pengawas,
        plant: plant ?? this.plant,
        materialCode: materialCode ?? this.materialCode,
        date: date ?? this.date,
        operationType: operationType ?? this.operationType,
        selectedOrder: selectedOrder ?? this.selectedOrder,
        orders: orders ?? this.orders,
        selectedOperation: selectedOperation ?? this.selectedOperation,
        operations: operations ?? this.operations,
        tab: tab ?? this.tab,
        prevTab: prevTab ?? this.prevTab,
        tongs: tongs ?? this.tongs,
        tong: tong ?? this.tong,
        isLoadingTong: isLoadingTong ?? this.isLoadingTong,
        isResultOperationLoaded:
            isResultOperationLoaded ?? this.isResultOperationLoaded,
        isComplete: isComplete ?? this.isComplete,
        isCompleteTong: isCompleteTong ?? this.isCompleteTong,
        isCompleteMaterials: isCompleteMaterials ?? this.isCompleteMaterials,
        isCompleteWeighingResults:
            isCompleteWeighingResults ?? this.isCompleteWeighingResults,
        startDate: startDate ?? this.startDate,
        fullpack: fullpack ?? this.fullpack,
        isLoadingFullpack: isLoadingFullpack ?? this.isLoadingFullpack,
        materialSet: materialSet ?? this.materialSet,
        isLoadingMaterialset: isLoadingMaterialset ?? this.isLoadingMaterialset,
        line: line ?? this.line,
        operationApps: operationApps ?? this.operationApps,
        isChecked: isChecked ?? this.isChecked,
        isNullData: isNullData ?? this.isNullData,
        operationTypeList: operationTypeList ?? this.operationTypeList,
        isNext: isNext ?? this.isNext,
        locationSets: locationSets ?? this.locationSets,
        selectedLocationSet: selectedLocationSet ?? this.selectedLocationSet,
        wadah: wadah ?? this.wadah,
        materials: materials ?? this.materials,
        startTime: startTime ?? this.startTime,
        isStartDateStatus: isStartDateStatus ?? this.isStartDateStatus,
        errorScanType: errorScanType ?? this.errorScanType,
        isCompletedcontainer:
            isCompletedcontainer ?? this.isCompletedcontainer);
  }

  @override
  List<Object> get props => [
        operator,
        pengawas,
        plant,
        materialCode,
        date,
        operationType,
        selectedOrder,
        orders,
        selectedOperation,
        operations,
        tab,
        prevTab,
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
        isNullData,
        operationTypeList,
        isNext,
        locationSets,
        selectedLocationSet,
        wadah,
        materials,
        startTime,
        isStartDateStatus,
        isCompleteWeighingResults,
        errorScanType,
        isCompletedcontainer
      ];
}
