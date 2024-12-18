part of 'handover_flag_bloc.dart';

@immutable
abstract class HandoverFlagState extends Equatable {
  const HandoverFlagState();

  @override
  List<Object> get props => [];
}

final class HandoverFlagInitial extends HandoverFlagState {}

final class HandoverFlagLoading extends HandoverFlagState {}

final class HandoverFlagLoaded extends HandoverFlagState {
  final String handoverFlag;

  const HandoverFlagLoaded({required this.handoverFlag});

  @override
  List<Object> get props => [handoverFlag];
}

final class HandoverFlagError extends HandoverFlagState {
  final String error;
  const HandoverFlagError(this.error);

  @override
  List<Object> get props => [error];
}
