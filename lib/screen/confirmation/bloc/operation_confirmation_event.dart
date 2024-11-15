part of 'operation_confirmation_bloc.dart';

@immutable
abstract class OperationConfirmationEvent extends Equatable {
  const OperationConfirmationEvent();

  @override
  List<Object> get props => [];
}

class GetOperationConfirmation extends OperationConfirmationEvent {
  final String routingNo;
  final String operationType;
  final String operationApps;

  const GetOperationConfirmation(
      this.routingNo, this.operationType, this.operationApps);

  @override
  List<Object> get props => [routingNo, operationType, operationApps];
}
