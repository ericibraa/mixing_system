import 'package:equatable/equatable.dart';

class TongResponse {
  D? d;

  TongResponse({this.d});

  TongResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultTong>? resultsTong;

  D({this.resultsTong});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsTong = <ResultTong>[];
      json['results'].forEach((v) {
        resultsTong!.add(ResultTong.fromJson(v));
      });
    }
  }
}

class ResultTong extends Equatable {
  final String? routingNo;
  final String? internalCntr;
  final String? material;
  final String? orderNo;
  final String? operationDesc;
  final String? activityNo;
  final String? cntrReciDest;
  final String? sortString;
  final bool? isScanned;
  final String? operationType;
  final String? activityWh;
  final String? controlRecipe;
  final String? operationApps;
  final String? lot;
  final WadToMatNav? wadToMatNav;

  const ResultTong(
      {this.routingNo = '',
      this.internalCntr = '',
      this.material = '',
      this.orderNo = '',
      this.operationDesc = '',
      this.activityNo = '',
      this.cntrReciDest = '',
      this.sortString = '',
      this.isScanned = false,
      this.operationType = '',
      this.activityWh = '',
      this.controlRecipe = '',
      this.operationApps = '',
      this.lot = '',
      this.wadToMatNav});
  ResultTong copyWith({required bool isScanned}) {
    return ResultTong(
        routingNo: routingNo,
        internalCntr: internalCntr,
        material: material,
        orderNo: orderNo,
        operationDesc: operationDesc,
        activityNo: activityNo,
        cntrReciDest: cntrReciDest,
        sortString: sortString,
        operationType: operationType,
        activityWh: activityWh,
        controlRecipe: controlRecipe,
        operationApps: operationApps,
        isScanned: isScanned,
        lot: lot,
        wadToMatNav: wadToMatNav);
  }

  factory ResultTong.fromJson(Map<String, dynamic> json) => ResultTong(
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        material: json['Material'],
        orderNo: json['OrderNo'],
        operationDesc: json['OperationDesc'],
        activityNo: json['ActivityNo'],
        cntrReciDest: json['CntrReciDest'],
        sortString: json['SortString'],
        operationType: json['OperationType'],
        activityWh: json['ActivityWh'],
        controlRecipe: json['ControlRecipe'],
        operationApps: json['OperationApps'],
        lot: json['Lot'],
        wadToMatNav: json['WadToMatNav'] != null
            ? WadToMatNav.fromJson(json['WadToMatNav'])
            : WadToMatNav(),
      );

  @override
  List<Object?> get props => [
        routingNo,
        internalCntr,
        material,
        orderNo,
        operationDesc,
        activityNo,
        cntrReciDest,
        sortString,
        isScanned,
        operationType,
        activityWh,
        controlRecipe,
        operationApps,
        lot,
        wadToMatNav
      ];
}

class WadToMatNav {
  List<ResultsFullPack>? resultsFullPack;

  WadToMatNav({this.resultsFullPack});

  WadToMatNav.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsFullPack = <ResultsFullPack>[];
      json['results'].forEach((v) {
        resultsFullPack!.add(ResultsFullPack.fromJson(v));
      });
    }
  }
}

class ResultsFullPack extends Equatable {
  final String routingNo;
  final String activityNo;
  final String operationType;
  final String bOMItem;
  final String materialNo;
  final String materialDesc;
  final String quantity;
  final String uom;
  final String recipient;
  final String counter;
  final String priority;
  final String activityWh;
  final String? activityDmp;
  final String scanFlag;
  final String handoverFlag;
  final bool isScannedFullpack;
  final String batch;

  const ResultsFullPack(
      {required this.routingNo,
      required this.activityNo,
      required this.operationType,
      required this.bOMItem,
      required this.materialNo,
      required this.materialDesc,
      required this.quantity,
      required this.uom,
      required this.recipient,
      required this.counter,
      required this.priority,
      required this.activityWh,
      this.activityDmp,
      this.scanFlag = '',
      this.handoverFlag = '',
      this.isScannedFullpack = false,
      required this.batch});
  ResultsFullPack copyWith(
      {required bool isScannedFullpack, String? scanFlag}) {
    return ResultsFullPack(
        routingNo: routingNo,
        activityNo: activityNo,
        operationType: operationType,
        bOMItem: bOMItem,
        materialNo: materialNo,
        materialDesc: materialDesc,
        quantity: quantity,
        uom: uom,
        recipient: recipient,
        counter: counter,
        priority: priority,
        activityWh: activityWh,
        activityDmp: activityDmp,
        scanFlag: scanFlag ?? this.scanFlag,
        handoverFlag: handoverFlag,
        isScannedFullpack: isScannedFullpack,
        batch: batch);
  }

  factory ResultsFullPack.fromJson(Map<String, dynamic> json) =>
      ResultsFullPack(
          routingNo: json['RoutingNo'],
          activityNo: json['ActivityNo'],
          operationType: json['OperationType'],
          bOMItem: json['BOMItem'],
          materialNo: json['MaterialNo'],
          materialDesc: json['MaterialDesc'],
          quantity: json['Quantity'],
          uom: json['Uom'],
          recipient: json['Recipient'],
          counter: json['Counter'],
          priority: json['Priority'],
          activityWh: json['ActivityWh'],
          activityDmp: json['ActivityDmp'] ?? '',
          handoverFlag: json['HandoverFlag'] ?? '',
          scanFlag: json['ScanFlag'] ?? '',
          batch: json['Batch']);

  @override
  List<Object> get props => [
        routingNo,
        activityNo,
        operationType,
        bOMItem,
        materialNo,
        materialDesc,
        quantity,
        uom,
        recipient,
        counter,
        priority,
        activityWh,
        handoverFlag,
        isScannedFullpack,
        batch
      ];
}
