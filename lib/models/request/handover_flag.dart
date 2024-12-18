class HandoverFlag {
  String? orderNo;
  String? activityNo;
  String? activityWh;
  String? counter;

  HandoverFlag({
    this.orderNo,
    this.activityNo,
    this.activityWh,
    this.counter
  });

  HandoverFlag.fromJson(Map<String, dynamic> json) {
    orderNo = json["OrderNo"];
    activityNo = json["ActivityNo"];
    activityWh = json["ActivityWh"];
    counter = json["Counter"];
  }

   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["OrderNo"] = orderNo;
    data["ActivityNo"] = activityNo;
    data["ActivityWh"] = activityWh;
    data["Counter"] = counter;
    return data;
   }
}