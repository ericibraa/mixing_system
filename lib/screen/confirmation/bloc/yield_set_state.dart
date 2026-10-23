part of 'yield_set_bloc.dart';

@immutable
abstract class YieldSetState extends Equatable {
  const YieldSetState();

  @override
  List<Object> get props => [];
}

final class YieldSetInitial extends YieldSetState {}

final class YieldSetLoading extends YieldSetState {}

final class YieldSetSuccess extends YieldSetState {
  final YieldSetResponse yieldSet;

  const YieldSetSuccess(this.yieldSet);

  @override
  List<Object> get props => [yieldSet];
}

final class YieldSetError extends YieldSetState {
  final String error;

  const YieldSetError(this.error);

  @override
  List<Object> get props => [error];
}
