part of 'result_scale_bloc.dart';

@immutable
abstract class ResultScaleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendDataResultScale extends ResultScaleEvent {
  final String orderNo;
  final String activityNo;
  final String activityWh;

  SendDataResultScale(
      {required this.orderNo,
      required this.activityNo,
      required this.activityWh});

  @override
  List<Object> get props => [orderNo, activityNo, activityWh];
}
