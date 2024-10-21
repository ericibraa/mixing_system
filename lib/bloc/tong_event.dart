part of 'tong_bloc.dart';

@immutable
abstract class TongEvent extends Equatable {
  const TongEvent();

  @override
  List<Object> get props => [];
}

class SendDataTong extends TongEvent {
  final String routingNo;
  final String activityNo;
  final String controlRecipe;
  final String operationType;

  const SendDataTong(
      {required this.routingNo,
      required this.activityNo,
      required this.controlRecipe,
      required this.operationType});
  @override
  List<Object> get props =>
      [routingNo, activityNo, controlRecipe, operationType];
}
