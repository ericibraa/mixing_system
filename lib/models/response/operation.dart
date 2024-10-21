import 'package:equatable/equatable.dart';

class OperationResponse {
  D? d;

  OperationResponse({this.d});

  OperationResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultOperation>? resultsOperationNo;

  D({this.resultsOperationNo});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsOperationNo = <ResultOperation>[];
      json['results'].forEach((v) {
        resultsOperationNo!.add(ResultOperation.fromJson(v));
      });
    }
  }
}

class ResultOperation extends Equatable {
  final String? routingNo;
  final String? internalCntr;
  final String? activityNo;
  final String? controlKey;
  final String? operationDesc;
  final String? controlRecipe;

  const ResultOperation(
      {this.routingNo,
      this.internalCntr,
      this.activityNo,
      this.controlKey,
      this.operationDesc,
      this.controlRecipe});

  factory ResultOperation.fromJson(Map<String, dynamic> json) =>
      ResultOperation(
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        activityNo: json['ActivityNo'],
        controlKey: json['ControlKey'],
        operationDesc: json['OperationDesc'],
        controlRecipe: json['ControlRecipe'],
      );

  @override
  List<Object?> get props => [
        routingNo,
        internalCntr,
        activityNo,
        controlKey,
        operationDesc,
        controlRecipe,
        operationDesc
      ];
}
