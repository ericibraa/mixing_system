part of 'location_set_bloc.dart';

@immutable
abstract class LocationSetEvent extends Equatable {
  const LocationSetEvent();

  @override
  List<Object> get props => [];
}

class GetLocationSet extends LocationSetEvent {
  final String routingNo;
  final String internalCntr;
  final String activityNo;

  const GetLocationSet(this.routingNo, this.internalCntr, this.activityNo);
  @override
  List<Object> get props => [routingNo, internalCntr, activityNo];
}
