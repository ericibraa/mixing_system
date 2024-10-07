class OperationResponse {
  D? d;

  OperationResponse({this.d});

  OperationResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? new D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsOperation>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsOperation>[];
      json['results'].forEach((v) {
        results!.add(ResultsOperation.fromJson(v));
      });
    }
  }
}

class ResultsOperation {
  Metadata? mMetadata;
  String? orderNo;
  String? plant;
  String? material;
  String? startDate;
  String? objectNo;
  String? status;
  String? statusDesc;
  String? batchFG;
  String? routingNo;
  String? internalCntr;
  String? operationType;
  D? ordToOprNav;

  ResultsOperation(
      {this.mMetadata,
      this.orderNo,
      this.plant,
      this.material,
      this.startDate,
      this.objectNo,
      this.status,
      this.statusDesc,
      this.batchFG,
      this.routingNo,
      this.internalCntr,
      this.operationType,
      this.ordToOprNav});

  ResultsOperation.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? new Metadata.fromJson(json['__metadata'])
        : null;
    orderNo = json['OrderNo'];
    plant = json['Plant'];
    material = json['Material'];
    startDate = json['StartDate'];
    objectNo = json['ObjectNo'];
    status = json['Status'];
    statusDesc = json['StatusDesc'];
    batchFG = json['BatchFG'];
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    operationType = json['OperationType'];
    ordToOprNav = json['OrdToOprNav'] != null
        ? new D.fromJson(json['OrdToOprNav'])
        : null;
  }
}

class Metadata {
  String? id;
  String? uri;
  String? type;

  Metadata({this.id, this.uri, this.type});

  Metadata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uri = json['uri'];
    type = json['type'];
  }
}

class ResultsMetaData {
  Metadata? mMetadata;
  String? routingNo;
  String? internalCntr;
  String? activityNo;
  String? controlKey;
  String? operationDesc;
  String? controlRecipe;

  ResultsMetaData(
      {this.mMetadata,
      this.routingNo,
      this.internalCntr,
      this.activityNo,
      this.controlKey,
      this.operationDesc,
      this.controlRecipe});

  ResultsMetaData.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? new Metadata.fromJson(json['__metadata'])
        : null;
    routingNo = json['RoutingNo'];
    internalCntr = json['InternalCntr'];
    activityNo = json['ActivityNo'];
    controlKey = json['ControlKey'];
    operationDesc = json['OperationDesc'];
    controlRecipe = json['ControlRecipe'];
  }
}
