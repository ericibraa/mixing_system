part of 'order_bloc.dart';

@immutable
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object> get props => [];
}

final class OrderInitial extends OrderState {}

final class OrderLoading extends OrderState {}

final class OrderLoaded extends OrderState {
  final OrderResponse order;

  const OrderLoaded(this.order);
  @override
  List<Object> get props => [order];
}

final class OrderError extends OrderState {}
