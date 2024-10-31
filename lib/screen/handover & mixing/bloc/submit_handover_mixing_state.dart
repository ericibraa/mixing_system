part of 'submit_handover_mixing_bloc.dart';

@immutable
abstract class SubmitHandoverMixingState extends Equatable {
  const SubmitHandoverMixingState();
  @override
  List<Object> get props => [];
}

final class SubmitHandoverMixingInitial extends SubmitHandoverMixingState {}

final class SubmitHandoverMixingLoading extends SubmitHandoverMixingState {}

final class SubmitHandoverMixingLoaded extends SubmitHandoverMixingState {
  final String submitHandoverMixing;
  const SubmitHandoverMixingLoaded({required this.submitHandoverMixing});

  @override
  List<Object> get props => [submitHandoverMixing];
}

final class SubmitHandoverMixingError extends SubmitHandoverMixingState {}
