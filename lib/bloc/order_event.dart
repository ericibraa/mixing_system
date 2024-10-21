part of 'order_bloc.dart';

@immutable
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class SendDataOrder extends OrderEvent {
  final String startDate;
  final String materialCode;
  final String plant;
  final String operationType;

  const SendDataOrder(
      {required this.plant,
      required this.materialCode,
      required this.operationType,
      required this.startDate});
  @override
  List<Object> get props => [plant, materialCode, operationType, startDate];
}
