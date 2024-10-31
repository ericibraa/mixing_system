class Handover {
  String? orderNo;
  String? plant;
  String? material;
  String? batchFG;
  String? routingNo;
  String? internalCntr;
  String? operationType;
  List<OrdToOprNavResp>? ordToOprNavResp;

  Handover(
      {this.orderNo,
      this.plant,
      this.material,
      this.batchFG,
      this.routingNo,
      this.internalCntr,
      this.operationType,
      this.ordToOprNavResp});

  Handover.fromJson(Map<String, dynamic> json) {
    orderNo = json['OrderNo'];
    plant = json['Plant'];
    material = json['Material'];
    batchFG = json['BatchFG'];
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    operationType = json['OperationType'];
    if (json['OrdToOprNav'] != null) {
      ordToOprNavResp = <OrdToOprNavResp>[];
      json['OrdToOprNav'].forEach((v) {
        ordToOprNavResp!.add(OrdToOprNavResp.fromJson(v));
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
    if (ordToOprNavResp != null) {
      data['OrdToOprNav'] = ordToOprNavResp!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrdToOprNavResp {
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

  OrdToOprNavResp(
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
      this.finishTime});

  OrdToOprNavResp.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
