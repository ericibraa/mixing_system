part of 'operation_bloc.dart';

@immutable
abstract class OperationEvent extends Equatable {
  const OperationEvent();

  @override
  List<Object> get props => [];
}

class SendDataOperation extends OperationEvent {
  final String routingNo;
  final String operationType;
  final String operationApps;

  const SendDataOperation(
      {required this.routingNo,
      required this.operationType,
      required this.operationApps});
  @override
  List<Object> get props => [routingNo, operationType, operationApps];
}
