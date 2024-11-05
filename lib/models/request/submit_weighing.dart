class SubmitWeighing {
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
  String? createDate;
  String? createTime;
  String? wadah;
  String? totalWadah;

  SubmitWeighing(
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
      this.createDate,
      this.createTime,
      this.wadah,
      this.totalWadah});

  SubmitWeighing.fromJson(Map<String, dynamic> json) {
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
    createDate = json['CreateDate'];
    createTime = json['CreateTime'];
    wadah = json['Wadah'];
    totalWadah = json['TotalWadah'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['OrderNo'] = orderNo;
    data['ActivityNo'] = activityNo;
    data['EquipmentNo'] = equipmentNo;
    data['Resource'] = resource;
    data['ActivityWh'] = activityWh;
    data['Bruto'] = bruto;
    data['Tara'] = tara;
    data['Netto'] = netto;
    data['UnitWeighing'] = unitWeighing;
    data['Temperature'] = temperature;
    data['UnitTemperature'] = unitTemperature;
    data['MoistureContent'] = moistureContent;
    data['UnitMoisture'] = unitMoisture;
    data['ExpiredDate'] = expiredDate;
    data['ExpiredTime'] = expiredTime;
    data['Operator'] = operator;
    data['Pengawas'] = pengawas;
    data['CreateDate'] = createDate;
    data['CreateTime'] = createTime;
    data['Wadah'] = wadah;
    data['TotalWadah'] = totalWadah;
    return data;
  }
}
