part of 'label_bloc.dart';

@immutable
abstract class LabelEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendDataLabel extends LabelEvent {
  final String orderNo;
  final String activityNo;

  SendDataLabel({required this.orderNo, required this.activityNo});
  @override
  List<Object> get props => [orderNo, activityNo];
}
