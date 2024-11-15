import 'package:equatable/equatable.dart';

class YieldSetResponse {
  D? d;

  YieldSetResponse({this.d});

  YieldSetResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsYieldSet>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsYieldSet>[];
      json['results'].forEach((v) {
        results!.add(ResultsYieldSet.fromJson(v));
      });
    }
  }
}

class ResultsYieldSet extends Equatable {
  final String? routingNo;
  final String? internalCntr;
  final String? orderNo;
  final String? activityNo;
  final String? yieldQty;
  final String? unitYield;
  final String? startDateOpr;
  final String? startTimeOpr;
  final String? startDateConf;
  final String? startTimeConf;
  final String? finishDate;
  final String? finishTime;
  final String? line;
  final String? postDate;
  final String? machineHour;
  final String? laborHour;
  final String? operationApps;
  final String? operator;
  final String? pengawas;

  const ResultsYieldSet(
      {this.routingNo,
      this.internalCntr,
      this.orderNo,
      this.activityNo,
      this.yieldQty,
      this.unitYield,
      this.startDateOpr,
      this.startTimeOpr,
      this.startDateConf,
      this.startTimeConf,
      this.finishDate,
      this.finishTime,
      this.line,
      this.postDate,
      this.machineHour,
      this.laborHour,
      this.operationApps,
      this.operator,
      this.pengawas});

  factory ResultsYieldSet.fromJson(Map<String, dynamic> json) =>
      ResultsYieldSet(
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        orderNo: json['OrderNo'],
        activityNo: json['ActivityNo'],
        yieldQty: json['YieldQty'],
        unitYield: json['UnitYield'],
        startDateOpr: json['StartDateOpr'],
        startTimeOpr: json['StartTimeOpr'],
        startDateConf: json['StartDateConf'],
        startTimeConf: json['StartTimeConf'],
        finishDate: json['FinishDate'],
        finishTime: json['FinishTime'],
        line: json['Line'],
        postDate: json['PostDate'],
        machineHour: json['MachineHour'],
        laborHour: json['LaborHour'],
        operationApps: json['OperationApps'],
        operator: json['Operator'],
        pengawas: json['Pengawas'],
      );

  @override
  List<Object?> get props => [
        routingNo,
        internalCntr,
        orderNo,
        activityNo,
        yieldQty,
        unitYield,
        startDateOpr,
        startTimeConf,
        startDateConf,
        startTimeConf,
        finishDate,
        finishTime,
        line,
        postDate,
        machineHour,
        laborHour,
        operationApps,
        operator,
        pengawas
      ];
}
