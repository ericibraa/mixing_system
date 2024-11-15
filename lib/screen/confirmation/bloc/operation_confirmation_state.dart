part of 'operation_confirmation_bloc.dart';

@immutable
abstract class OperationConfirmationState extends Equatable {
  const OperationConfirmationState();
  @override
  List<Object> get props => [];
}

final class OperationConfirmationInitial extends OperationConfirmationState {}

final class OperationConfirmationLoading extends OperationConfirmationState {}

final class OperationConfirmationSuccess extends OperationConfirmationState {
  final OperationResponse operationConfirmation;

  const OperationConfirmationSuccess(this.operationConfirmation);

  @override
  List<Object> get props => [operationConfirmation];
}

final class OperationConfirmationError extends OperationConfirmationState {}
