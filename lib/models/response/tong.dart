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
  final String routingNo;
  final String internalCntr;
  final String material;
  final String orderNo;
  final String operationDesc;
  final String activityNo;
  final String cntrReciDest;
  final String sortString;
  final bool isScanned;
  final String? operationType;
  final WadToMatNav wadToMatNav;

  const ResultTong(
      {required this.routingNo,
      required this.internalCntr,
      required this.material,
      required this.orderNo,
      required this.operationDesc,
      required this.activityNo,
      required this.cntrReciDest,
      required this.sortString,
      this.isScanned = false,
      required this.operationType,
      required this.wadToMatNav});
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
        isScanned: isScanned,
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
  final bool isScannedFullpack;

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
      this.isScannedFullpack = false});
  ResultsFullPack copyWith({required bool isScannedFullpack}) {
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
        isScannedFullpack: isScannedFullpack);
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
      );

  @override
  List<Object?> get props => [
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
        isScannedFullpack
      ];
}
