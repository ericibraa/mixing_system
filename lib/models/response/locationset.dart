import 'package:equatable/equatable.dart';

class LocationSetResponse {
  D? d;

  LocationSetResponse({this.d});

  LocationSetResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsLocationSet>? locationSet;

  D({this.locationSet});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      locationSet = <ResultsLocationSet>[];
      json['results'].forEach((v) {
        locationSet!.add(ResultsLocationSet.fromJson(v));
      });
    }
  }
}

class ResultsLocationSet extends Equatable {
  final String? routingNo;
  final String? internalCntr;
  final String? activityNo;
  final String? operationApps;
  final String? activityWh;
  final String? operationDesc;
  final String? line;

  const ResultsLocationSet(
      {this.routingNo,
      this.internalCntr,
      this.activityNo,
      this.operationApps,
      this.activityWh,
      this.operationDesc,
      this.line});

  factory ResultsLocationSet.fromJson(Map<String, dynamic> json) =>
      ResultsLocationSet(
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        activityNo: json['ActivityNo'],
        operationApps: json['OperationApps'],
        activityWh: json['ActivityWh'],
        operationDesc: json['OperationDesc'],
        line: json['Line'],
      );

  @override
  List<Object?> get props => [
        routingNo,
        internalCntr,
        activityNo,
        operationApps,
        activityWh,
        operationDesc,
        line
      ];
}
