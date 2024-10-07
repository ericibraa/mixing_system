part of 'validation_bloc.dart';

@immutable
abstract class ValidationState extends Equatable {
  const ValidationState();
  @override
  List<Object> get props => [];
}

final class ValidationInitial extends ValidationState {}

final class ValidationLoading extends ValidationState {}

final class ValidationLoaded extends ValidationState {
  final ValidationResponse validation;
  const ValidationLoaded(this.validation);
  @override
  List<Object> get props => [validation];
}

final class ValidationError extends ValidationState {}
