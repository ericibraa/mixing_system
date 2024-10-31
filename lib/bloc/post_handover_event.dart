part of 'post_handover_bloc.dart';

@immutable
abstract class SubmitHandoverEvent extends Equatable {
  const SubmitHandoverEvent();

  @override
  List<Object> get props => [];
}

class SubmitHandover extends SubmitHandoverEvent {
  final HandoverState orderData;

  const SubmitHandover({required this.orderData});
}
