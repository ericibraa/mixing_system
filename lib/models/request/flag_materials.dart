class FlagMaterials {
  String? orderNo;
  String? activityNo;
  String? bOMItem;
  String? materialNo;
  String? recipient;
  String? fullpackItem;
  String? batch;
  String? activityWh;
  String? wadah;

  FlagMaterials(
      {this.orderNo,
      this.activityNo,
      this.bOMItem,
      this.materialNo,
      this.recipient,
      this.fullpackItem,
      this.batch,
      this.activityWh,
      this.wadah});

  FlagMaterials.fromJson(Map<String, dynamic> json) {
    orderNo = json['OrderNo'];
    activityNo = json['ActivityNo'];
    bOMItem = json['BOMItem'];
    materialNo = json['MaterialNo'];
    recipient = json['Recipient'];
    fullpackItem = json['FullpackItem'];
    batch = json['Batch'];
    activityWh = json['ActivityWh'];
    wadah = json['Wadah'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['OrderNo'] = orderNo;
    data['ActivityNo'] = activityNo;
    data['BOMItem'] = bOMItem;
    data['MaterialNo'] = materialNo;
    data['Recipient'] = recipient;
    data['FullpackItem'] = fullpackItem;
    data['Batch'] = batch;
    data['ActivityWh'] = activityWh;
    data['Wadah'] = wadah;
    return data;
  }
}
