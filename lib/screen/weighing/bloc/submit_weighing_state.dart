part of 'submit_weighing_bloc.dart';

@immutable
abstract class SubmitWeighingState extends Equatable {
  const SubmitWeighingState();

  @override
  List<Object> get props => [];
}

final class SubmitWeighingInitial extends SubmitWeighingState {}

final class SubmitWeighingLoading extends SubmitWeighingState {}

final class SubmitWeighingSuccess extends SubmitWeighingState {
  final String submitWeighing;
  final bool isPrinted;
  const SubmitWeighingSuccess(
      {required this.submitWeighing, required this.isPrinted});

  @override
  List<Object> get props => [submitWeighing, isPrinted];
}

final class SubmitWeighingError extends SubmitWeighingState {
  final String error;

  const SubmitWeighingError(this.error);

  @override
  List<Object> get props => [error];
}
