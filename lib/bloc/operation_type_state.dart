part of 'operation_type_bloc.dart';

@immutable
abstract class OperationTypeState extends Equatable {
  const OperationTypeState();

  @override
  List<Object?> get props => [];
}

final class OperationTypeInitial extends OperationTypeState {}

final class OperationTypeLoading extends OperationTypeState {}

final class OperationTypeLoaded extends OperationTypeState {
  final OperationTypeResponse operationType;

  const OperationTypeLoaded({required this.operationType});

  @override
  List<Object?> get props => [operationType];
}

final class OperationTypeError extends OperationTypeState {}
