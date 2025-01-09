part of 'result_scale_2_bloc.dart';

@immutable
abstract class ResultScale2Event extends Equatable {
  @override
  List<Object> get props => [];
}

class SendDataResultScale2 extends ResultScale2Event {
  final String orderNo;
  final String activityNo;
  final String activityWh;
  final String objectName;
  final String operationType;

  SendDataResultScale2(
      {required this.orderNo,
      required this.activityNo,
      required this.activityWh,
      required this.objectName,
      required this.operationType});

  @override
  List<Object> get props => [orderNo, activityNo, activityWh, objectName];
}
