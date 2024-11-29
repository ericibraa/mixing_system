part of 'wadah_set_bloc.dart';

@immutable
abstract class WadahSetEvent extends Equatable {
  const WadahSetEvent();

  @override
  List<Object> get props => [];
}

class GetWadahSet extends WadahSetEvent {
  final String routingNo;
  final String activityNo;
  final String operationType;

  const GetWadahSet(this.routingNo, this.activityNo, this.operationType);

  @override
  List<Object> get props => [routingNo, activityNo, operationType];
}
