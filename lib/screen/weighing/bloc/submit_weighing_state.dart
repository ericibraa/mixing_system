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
  final bool isPrinted;
  SubmitWeighingSuccess(
      {required this.submitWeighing, required this.isPrinted});

  @override
  List<Object> get props => [submitWeighing, isPrinted];
}

final class SubmitWeighingError extends SubmitWeighingState {}
