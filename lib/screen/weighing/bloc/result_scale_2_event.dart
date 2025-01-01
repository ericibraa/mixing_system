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

  SendDataResultScale2(
      {required this.orderNo,
      required this.activityNo,
      required this.activityWh,
      required this.objectName});

  @override
  List<Object> get props => [orderNo, activityNo, activityWh, objectName];
}
