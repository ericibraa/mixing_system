part of 'submit_bloc.dart';

@immutable
abstract class SubmitState extends Equatable {
  const SubmitState();

  @override
  List<Object> get props => [];
}

final class SubmitInitial extends SubmitState {}

final class SubmitLoading extends SubmitState {}

final class SubmitSuccess extends SubmitState {
  final String confirmationStatus;

  const SubmitSuccess(this.confirmationStatus);

  @override
  List<Object> get props => [confirmationStatus];
}

final class SubmitError extends SubmitState {}
