class SubmitConfirmationRequest {
  String? routingNo;
  String? internalCntr;
  String? orderNo;
  String? activityNo;
  String? yieldQty;
  String? unitYield;
  String? startDateOpr;
  String? startTimeOpr;
  String? startDateConf;
  String? startTimeConf;
  String? finishDate;
  String? finishTime;
  String? line;
  String? postDate;
  String? machineHour;
  String? laborHour;
  String? operationApps;
  String? operator;
  String? pengawas;

  SubmitConfirmationRequest(
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

  SubmitConfirmationRequest.fromJson(Map<String, dynamic> json) {
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    orderNo = json['OrderNo'];
    activityNo = json['ActivityNo'];
    yieldQty = json['YieldQty'];
    unitYield = json['UnitYield'];
    startDateOpr = json['StartDateOpr'];
    startTimeOpr = json['StartTimeOpr'];
    startDateConf = json['StartDateConf'];
    startTimeConf = json['StartTimeConf'];
    finishDate = json['FinishDate'];
    finishTime = json['FinishTime'];
    line = json['Line'];
    postDate = json['PostDate'];
    machineHour = json['MachineHour'];
    laborHour = json['LaborHour'];
    operationApps = json['OperationApps'];
    operator = json['Operator'];
    pengawas = json['Pengawas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RoutingNo'] = routingNo;
    data['InternalCntr'] = internalCntr;
    data['OrderNo'] = orderNo;
    data['ActivityNo'] = activityNo;
    data['YieldQty'] = yieldQty;
    data['UnitYield'] = unitYield;
    data['StartDateOpr'] = startDateOpr;
    data['StartTimeOpr'] = startTimeOpr;
    data['StartDateConf'] = startDateConf;
    data['StartTimeConf'] = startTimeConf;
    data['FinishDate'] = finishDate;
    data['FinishTime'] = finishTime;
    data['Line'] = line;
    data['PostDate'] = postDate;
    data['MachineHour'] = machineHour;
    data['LaborHour'] = laborHour;
    data['OperationApps'] = operationApps;
    data['Operator'] = operator;
    data['Pengawas'] = pengawas;
    return data;
  }
}
