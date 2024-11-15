part of 'yield_set_bloc.dart';

@immutable
abstract class YieldSetEvent extends Equatable {
  const YieldSetEvent();

  @override
  List<Object> get props => [];
}

class GetYieldSet extends YieldSetEvent {
  final String routingNo;
  final String internalCntr;
  final String activityNo;

  const GetYieldSet(this.routingNo, this.internalCntr, this.activityNo);

  @override
  List<Object> get props => [routingNo, internalCntr, activityNo];
}
