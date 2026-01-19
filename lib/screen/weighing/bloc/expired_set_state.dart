part of 'expired_set_bloc.dart';

@immutable
abstract class ExpiredSetState extends Equatable {
  const ExpiredSetState();
  @override
  List<Object> get props => [];
}

final class ExpiredSetInitial extends ExpiredSetState {}

final class ExpiredSetLoading extends ExpiredSetState {}

final class ExpiredSetLoaded extends ExpiredSetState {
  final ExpiredsetResponse expiredSet;

  const ExpiredSetLoaded({required this.expiredSet});
  @override
  List<Object> get props => [expiredSet];
}

final class ExpiredSetError extends ExpiredSetState {
  final String error;

  const ExpiredSetError(this.error);

  @override
  List<Object> get props => [error];
}
