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
  final ResponseSubmitWeighing submitWeighing;
  const SubmitWeighingSuccess({required this.submitWeighing});

  @override
  List<Object> get props => [submitWeighing];
}

final class SubmitWeighingError extends SubmitWeighingState {
  final String error;

  const SubmitWeighingError(this.error);

  @override
  List<Object> get props => [error];
}
