part of 'expired_set_bloc.dart';

@immutable
abstract class ExpiredSetEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetExpiredSet extends ExpiredSetEvent {
  final String orderNo;
  final String activityNo;

  GetExpiredSet({required this.orderNo, required this.activityNo});
  @override
  List<Object> get props => [orderNo, activityNo];
}
