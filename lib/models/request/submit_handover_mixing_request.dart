class SubmitHandoverMixingRequest {
  String? routingNo;
  String? activityNo;
  String? activityWh;
  String? operationApps;
  String? operationType;
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
    data['FinishDate'] = finishDate;
    data['FinishTime'] = finishTime;
    data['Operator'] = operator;
    data['Pengawas'] = pengawas;
    return data;
  }
}
