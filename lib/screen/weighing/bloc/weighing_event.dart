part of 'weighing_bloc.dart';

@immutable
abstract class WeighingEvent extends Equatable {
  const WeighingEvent();

  @override
  List<Object> get props => [];
}

class SendDataWeighing extends WeighingEvent {
  final String routingNo;
  final String internalCntr;
  final String activityNo;
  final String operationType;
  final String operationApps;

  const SendDataWeighing(
      {required this.routingNo,
      required this.internalCntr,
      required this.activityNo,
      required this.operationType,
      required this.operationApps});

  @override
  List<Object> get props =>
      [routingNo, internalCntr, activityNo, operationType, operationApps];
}
