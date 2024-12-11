import 'package:equatable/equatable.dart';

class OrderResponse {
  D? d;

  OrderResponse({this.d});

  OrderResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsOrder>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsOrder>[];
      json['results'].forEach((v) {
        results!.add(ResultsOrder.fromJson(v));
      });
    }
  }
}

class ResultsOrder extends Equatable {
  final String? orderNo;
  final String? plant;
  final String? material;
  final String? materialDesc;
  final String? startDate;
  final String? objectNo;
  final String? status;
  final String? statusDesc;
  final String? batchFG;
  final String? routingNo;
  final String? internalCntr;
  final String? operationType;

  const ResultsOrder({
    this.orderNo,
    this.plant,
    this.material,
    this.materialDesc,
    this.startDate,
    this.objectNo,
    this.status,
    this.statusDesc,
    this.batchFG,
    this.routingNo,
    this.internalCntr,
    this.operationType,
  });

  factory ResultsOrder.fromJson(Map<String, dynamic> json) => ResultsOrder(
        orderNo: json['OrderNo'],
        plant: json['Plant'],
        material: json['Material'],
        materialDesc: json['Material_Desc'],
        startDate: json['StartDate'],
        objectNo: json['ObjectNo'],
        status: json['Status'],
        statusDesc: json['StatusDesc'],
        batchFG: json['BatchFG'],
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        operationType: json['OperationType'],
      );

  @override
  List<Object?> get props => [
        orderNo,
        plant,
        material,
        materialDesc,
        startDate,
        objectNo,
        status,
        statusDesc,
        batchFG,
        routingNo,
        internalCntr,
        operationType,
      ];
}
