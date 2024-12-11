class SubmitHandoverMixingRequest {
  String? routingNo;
  String? activityNo;
  String? activityWh;
  String? operationApps;
  String? operationType;
  String? startDate;
  String? startTime;
  String? finishDate;
  String? finishTime;
  String? operator;
  String? pengawas;

  SubmitHandoverMixingRequest({
    this.routingNo,
    this.activityNo,
    this.activityWh,
    this.operationApps,
    this.operationType,
    this.startDate,
    this.startTime,
    this.finishDate,
    this.finishTime,
    this.operator,
    this.pengawas,
  });

  SubmitHandoverMixingRequest.fromJson(Map<String, dynamic> json) {
    routingNo = json['RoutingNo'];
    activityNo = json['ActivityNo'];
    activityWh = json['ActivityWh'];
    operationApps = json['OperationApps'];
    operationType = json['OperationType'];
    startDate = json['StartDate'];
    startTime = json['StartTime'];
    finishDate = json['FinishDate'];
    finishTime = json['FinishTime'];
    operator = json['Operator'];
    pengawas = json['Pengawas'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['RoutingNo'] = routingNo;
    data['ActivityNo'] = activityNo;
    data['ActivityWh'] = activityWh;
    data['OperationApps'] = operationApps;
    data['OperationType'] = operationType;
    data['StartDate'] = startDate;
    data['StartTime'] = startTime;
    data['FinishDate'] = finishDate;
    data['FinishTime'] = finishTime;
    data['Operator'] = operator;
    data['Pengawas'] = pengawas;
    return data;
  }
}
