import 'package:equatable/equatable.dart';

class LabelResponse {
  D? d;

  LabelResponse({this.d});

  LabelResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsLabel>? resultsLabel;

  D({this.resultsLabel});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsLabel = <ResultsLabel>[];
      json['results'].forEach((v) {
        resultsLabel!.add(ResultsLabel.fromJson(v));
      });
    }
  }
}

class ResultsLabel extends Equatable {
  final String? orderNo;
  final String? activityNo;
  final String? expiredNo;
  final String? unit;
  final String? workCenter;
  final String? workCenterDesc;

  const ResultsLabel(
      {this.orderNo,
      this.activityNo,
      this.expiredNo,
      this.unit,
      this.workCenter,
      this.workCenterDesc});
  ResultsLabel copyWith({
    String? orderNo,
    String? activityNo,
    String? expiredNo,
    String? unit,
    String? workCenter,
    String? workCenterDesc,
  }) {
    return ResultsLabel(
        orderNo: orderNo ?? this.orderNo,
        activityNo: activityNo ?? this.activityNo,
        expiredNo: expiredNo ?? this.expiredNo,
        unit: unit ?? this.unit,
        workCenter: workCenter ?? this.workCenter,
        workCenterDesc: workCenterDesc ?? this.workCenterDesc);
  }

  factory ResultsLabel.fromJson(Map<String, dynamic> json) => ResultsLabel(
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
