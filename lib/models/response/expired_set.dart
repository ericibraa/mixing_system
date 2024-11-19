import 'package:equatable/equatable.dart';

class ExpiredsetResponse {
  D? d;

  ExpiredsetResponse({this.d});

  ExpiredsetResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsExpiredSet>? resultsExpiredSet;

  D({this.resultsExpiredSet});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsExpiredSet = <ResultsExpiredSet>[];
      json['results'].forEach((v) {
        resultsExpiredSet!.add(ResultsExpiredSet.fromJson(v));
      });
    }
  }
}

class ResultsExpiredSet extends Equatable {
  final String? orderNo;
  final String? activityNo;
  final String? expiredNo;
  final String? unit;
  final String? workCenter;
  final String? workCenterDesc;

  const ResultsExpiredSet(
      {this.orderNo,
      this.activityNo,
      this.expiredNo,
      this.unit,
      this.workCenter,
      this.workCenterDesc});
  ResultsExpiredSet copyWith({
    String? orderNo,
    String? activityNo,
    String? expiredNo,
    String? unit,
    String? workCenter,
    String? workCenterDesc,
  }) {
    return ResultsExpiredSet(
        orderNo: orderNo ?? this.orderNo,
        activityNo: activityNo ?? this.activityNo,
        expiredNo: expiredNo ?? this.expiredNo,
        unit: unit ?? this.unit,
        workCenter: workCenter ?? this.workCenter,
        workCenterDesc: workCenterDesc ?? this.workCenterDesc);
  }

  factory ResultsExpiredSet.fromJson(Map<String, dynamic> json) =>
      ResultsExpiredSet(
        orderNo: json['OrderNo'],
        activityNo: json['ActivityNo'],
        expiredNo: json['ExpiredNo'],
        unit: json['Unit'],
        workCenter: json['WorkCenter'],
        workCenterDesc: json['WorkCenterDesc'],
      );
  @override
  List<Object?> get props =>
      [orderNo, activityNo, expiredNo, unit, workCenter, workCenterDesc];
}
