class ResultScaleListResponse {
  D? d;

  ResultScaleListResponse({this.d});

  ResultScaleListResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultScaleList>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultScaleList>[];
      json['results'].forEach((v) {
        results!.add(ResultScaleList.fromJson(v));
      });
    }
  }
}

class ResultScaleList {
  String? orderNo;
  String? activityNo;
  String? equipmentNo;
  String? resource;
  String? activityWh;
  String? bruto;
  String? tara;
  String? netto;
  String? unitWeighing;
  String? temperature;
  String? unitTemperature;
  String? moistureContent;
  String? unitMoisture;
  String? expiredDate;
  String? expiredTime;
  String? operator;
  String? pengawas;
  String? createdDate;
  String? createdTime;
  String? wadah;
  String? totalWadah;
  String? equipmentDesc;
  String? resourceDesc;
  String? activityNoDesc;
  String? activityWhDesc;
  String? lot;
  String? line;
  String? objectName;
  String? cancelWadah;

  ResultScaleList(
      {this.orderNo,
      this.activityNo,
      this.equipmentNo,
      this.resource,
      this.activityWh,
      this.bruto,
      this.tara,
      this.netto,
      this.unitWeighing,
      this.temperature,
      this.unitTemperature,
      this.moistureContent,
      this.unitMoisture,
      this.expiredDate,
      this.expiredTime,
      this.operator,
      this.pengawas,
      this.createdDate,
      this.createdTime,
      this.wadah,
      this.totalWadah,
      this.equipmentDesc,
      this.resourceDesc,
      this.activityNoDesc,
      this.activityWhDesc,
      this.lot,
      this.line,
      this.objectName,
      this.cancelWadah});

  ResultScaleList.fromJson(Map<String, dynamic> json) {
    orderNo = json['OrderNo'];
    activityNo = json['ActivityNo'];
    equipmentNo = json['EquipmentNo'];
    resource = json['Resource'];
    activityWh = json['ActivityWh'];
    bruto = json['Bruto'];
    tara = json['Tara'];
    netto = json['Netto'];
    unitWeighing = json['UnitWeighing'];
    temperature = json['Temperature'];
    unitTemperature = json['UnitTemperature'];
    moistureContent = json['MoistureContent'];
    unitMoisture = json['UnitMoisture'];
    expiredDate = json['ExpiredDate'];
    expiredTime = json['ExpiredTime'];
    operator = json['Operator'];
    pengawas = json['Pengawas'];
    createdDate = json['CreatedDate'];
    createdTime = json['CreatedTime'];
    wadah = json['Wadah'];
    totalWadah = json['TotalWadah'];
    equipmentDesc = json['EquipmentDesc'];
    resourceDesc = json['ResourceDesc'];
    activityNoDesc = json['ActivityNoDesc'];
    activityWhDesc = json['ActivityWhDesc'];
    lot = json['Lot'];
    line = json['Line'];
    objectName = json['ObjectName'];
    cancelWadah = json['CancelWadah'];
  }
}
