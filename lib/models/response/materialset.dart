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
  final bool isScanned;

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
      this.isScanned = false});

  ResultsMaterialset copyWith({required bool isScanned}) {
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
        isScanned: isScanned);
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
          counter: json['Counter']);

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
        isScanned
      ];
}
