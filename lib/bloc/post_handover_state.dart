part of 'post_handover_bloc.dart';

@immutable
abstract class SubmitHandoverState extends Equatable {
  const SubmitHandoverState();
  @override
  List<Object> get props => [];
}

final class SubmitHandoverInitial extends SubmitHandoverState {}

final class SubmitHandoverLoading extends SubmitHandoverState {}

final class SubmitHandoverLoaded extends SubmitHandoverState {
  final String submitHandover;
  const SubmitHandoverLoaded({required this.submitHandover});

  @override
  List<Object> get props => [submitHandover];
}

final class SubmitHandoverError extends SubmitHandoverState {}
