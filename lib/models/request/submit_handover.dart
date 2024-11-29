class SubmitHandoverRequest {
  String? orderNo;
  String? plant;
  String? material;
  String? batchFG;
  String? routingNo;
  String? internalCntr;
  String? operationType;
  List<OrdToOprNav>? ordToOprNav;

  SubmitHandoverRequest(
      {this.orderNo,
      this.plant,
      this.material,
      this.batchFG,
      this.routingNo,
      this.internalCntr,
      this.operationType,
      this.ordToOprNav});

  SubmitHandoverRequest.fromJson(Map<String, dynamic> json) {
    orderNo = json['OrderNo'];
    plant = json['Plant'];
    material = json['Material'];
    batchFG = json['BatchFG'];
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    operationType = json['OperationType'];
    if (json['OrdToOprNav'] != null) {
      ordToOprNav = <OrdToOprNav>[];
      json['OrdToOprNav'].forEach((v) {
        ordToOprNav!.add(OrdToOprNav.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['OrderNo'] = orderNo;
    data['Plant'] = plant;
    data['Material'] = material;
    data['BatchFG'] = batchFG;
    data['RoutingNo'] = routingNo;
    data['InternalCntr'] = internalCntr;
    data['OperationType'] = operationType;
    if (ordToOprNav != null) {
      data['OrdToOprNav'] = ordToOprNav!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrdToOprNav {
  String? routingNo;
  String? internalCntr;
  String? activityNo;
  String? operationDesc;
  String? controlRecipe;
  String? operationApps;
  String? line;
  String? startDate;
  String? startTime;
  String? finishDate;
  String? finishTime;
  String? operator;
  String? pengawas;
  String? activityWh;

  OrdToOprNav(
      {this.routingNo,
      this.internalCntr,
      this.activityNo,
      this.operationDesc,
      this.controlRecipe,
      this.operationApps,
      this.line,
      this.startDate,
      this.startTime,
      this.finishDate,
      this.finishTime,
      this.operator,
      this.pengawas,
      this.activityWh});

  OrdToOprNav.fromJson(Map<String, dynamic> json) {
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    activityNo = json['ActivityNo'];
    operationDesc = json['OperationDesc'];
    controlRecipe = json['ControlRecipe'];
    operationApps = json['OperationApps'];
    line = json['Line'];
    startDate = json['StartDate'];
    startTime = json['StartTime'];
    finishDate = json['FinishDate'];
    finishTime = json['FinishTime'];
    operator = json['Operator'];
    pengawas = json['Pengawas'];
    activityWh = json['ActivityWh'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['RoutingNo'] = routingNo;
    data['InternalCntr'] = internalCntr;
    data['ActivityNo'] = activityNo;
    data['OperationDesc'] = operationDesc;
    data['ControlRecipe'] = controlRecipe;
    data['OperationApps'] = operationApps;
    data['Line'] = line;
    data['StartDate'] = startDate;
    data['StartTime'] = startTime;
    data['FinishDate'] = finishDate;
    data['FinishTime'] = finishTime;
    data['Operator'] = operator;
    data['Pengawas'] = pengawas;
    data['ActivityWh'] = activityWh;
    return data;
  }
}
