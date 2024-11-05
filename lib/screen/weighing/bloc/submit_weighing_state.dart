part of 'submit_weighing_bloc.dart';

@immutable
abstract class SubmitWeighingState extends Equatable {
  @override
  List<Object> get props => [];
}

final class SubmitWeighingInitial extends SubmitWeighingState {}

final class SubmitWeighingLoading extends SubmitWeighingState {}

final class SubmitWeighingSuccess extends SubmitWeighingState {
  final String submitWeighing;
  SubmitWeighingSuccess({required this.submitWeighing});

  @override
  List<Object> get props => [submitWeighing];
}

final class SubmitWeighingError extends SubmitWeighingState {}
