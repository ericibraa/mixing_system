import 'package:equatable/equatable.dart';

class ResponseMaterialset {
  D? d;

  ResponseMaterialset({this.d});

  ResponseMaterialset.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsMaterialset>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsMaterialset>[];
      json['results'].forEach((v) {
        results!.add(ResultsMaterialset.fromJson(v));
      });
    }
  }
}

class ResultsMaterialset extends Equatable {
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
  final String activityDmp;
  final String scanFlag;
  final String scanDate;
  final String scanTime;
  final bool isScanned;
  final String activityWh;

  const ResultsMaterialset(
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
      required this.activityDmp,
      required this.scanFlag,
      required this.scanDate,
      required this.scanTime,
      this.isScanned = false,
      required this.activityWh});

  ResultsMaterialset copyWith({required bool isScanned, String? scanFlag}) {
    return ResultsMaterialset(
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
        activityDmp: activityDmp,
        scanFlag: scanFlag ?? this.scanFlag,
        scanDate: scanDate,
        scanTime: scanTime,
        isScanned: isScanned,
        activityWh: activityWh);
  }

  factory ResultsMaterialset.fromJson(Map<String, dynamic> json) =>
      ResultsMaterialset(
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
          activityDmp: json['ActivityDmp'],
          scanFlag: json['ScanFlag'],
          scanDate: json['ScanDate'],
          scanTime: json['ScanTime'],
          activityWh: json['ActivityWh']);

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
        activityDmp,
        scanFlag,
        scanDate,
        scanTime,
        isScanned,
        activityWh
      ];
}
