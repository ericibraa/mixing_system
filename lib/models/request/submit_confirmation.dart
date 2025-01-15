import 'package:equatable/equatable.dart';

class SubmitConfirmationResponse {
  SubmitConfirmationRequest? submitConfirmationRequest;

  SubmitConfirmationResponse({this.submitConfirmationRequest});

  SubmitConfirmationResponse.fromJson(Map<String, dynamic> json) {
    submitConfirmationRequest = json['d'] != null
        ? SubmitConfirmationRequest.fromJson(json['d'])
        : null;
  }
}

class SubmitConfirmationRequest extends Equatable {
  final String routingNo;
  final String internalCntr;
  final String orderNo;
  final String activityNo;
  final String yieldQty;
  final String unitYield;
  final String startDateOpr;
  final String startTimeOpr;
  final String startDateConf;
  final String startTimeConf;
  final String finishDate;
  final String finishTime;
  final String line;
  final String postDate;
  final String machineHour;
  final String laborHour;
  final String operationApps;
  final String operator;
  final String pengawas;
  final List<YieldToLinesNav> yieldToLinesNav;

  const SubmitConfirmationRequest(
      {this.routingNo = "",
      this.internalCntr = "",
      this.orderNo = "",
      this.activityNo = "",
      this.yieldQty = "",
      this.unitYield = "",
      this.startDateOpr = "",
      this.startTimeOpr = "",
      this.startDateConf = "",
      this.startTimeConf = "",
      this.finishDate = "",
      this.finishTime = "",
      this.line = "",
      this.postDate = "",
      this.machineHour = "",
      this.laborHour = "",
      this.operationApps = "",
      this.operator = "",
      this.pengawas = "",
      this.yieldToLinesNav = const []});

  @override
  List<Object> get props => [
        routingNo,
        internalCntr,
        orderNo,
        activityNo,
        yieldQty,
        unitYield,
        startDateOpr,
        startTimeOpr,
        startDateConf,
        startTimeConf,
        finishDate,
        finishTime,
        line,
        postDate,
        machineHour,
        laborHour,
        operationApps,
        operator,
        pengawas,
        yieldToLinesNav
      ];

  factory SubmitConfirmationRequest.fromJson(Map<String, dynamic> json) =>
      SubmitConfirmationRequest(
        routingNo: json['RoutingNo'],
        internalCntr: json['InternalCntr'],
        orderNo: json['OrderNo'],
        activityNo: json['ActivityNo'],
        yieldQty: json['YieldQty'],
        unitYield: json['UnitYield'],
        startDateOpr: json['StartDateOpr'],
        startTimeOpr: json['StartTimeOpr'],
        startDateConf: json['StartDateConf'],
        startTimeConf: json['StartTimeConf'],
        finishDate: json['FinishDate'],
        finishTime: json['FinishTime'],
        line: json['Line'],
        postDate: json['PostDate'],
        machineHour: json['MachineHour'],
        laborHour: json['LaborHour'],
        operationApps: json['OperationApps'],
        operator: json['Operator'],
        pengawas: json['Pengawas'],
        yieldToLinesNav: json["YieldToLinesNav"] == null
            ? []
            : List<YieldToLinesNav>.from(json["YieldToLinesNav"]
                .map((x) => YieldToLinesNav.fromJson(x))),
      );

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
    if (yieldToLinesNav.isNotEmpty) {
      data['YieldToLinesNav'] = yieldToLinesNav.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class YieldToLinesNav {
  String? text;

  YieldToLinesNav({this.text});

  YieldToLinesNav.fromJson(Map<String, dynamic> json) {
    text = json['Text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Text'] = text;
    return data;
  }
}
