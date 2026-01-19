part of 'operation_bloc.dart';

@immutable
abstract class OperationState extends Equatable {
  const OperationState();
  @override
  List<Object> get props => [];
}

final class OperationInitial extends OperationState {}

final class OperationLoading extends OperationState {}

final class OperationLoaded extends OperationState {
  final OperationResponse operation;
  const OperationLoaded(this.operation);
  @override
  List<Object> get props => [operation];
}

final class OperationError extends OperationState {
    final String error;

  const OperationError(this.error);

  @override
  List<Object> get props => [error];
}
