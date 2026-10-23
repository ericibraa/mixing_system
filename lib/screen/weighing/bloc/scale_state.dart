part of 'scale_bloc.dart';

@immutable
abstract class ScaleState extends Equatable {
  const ScaleState();
  @override
  List<Object> get props => [];
}

final class ScaleInitial extends ScaleState {}

final class ScaleLoading extends ScaleState {}

final class ScaleLoaded extends ScaleState {
  final ScaleResponse scale;
  const ScaleLoaded({required this.scale});

  @override
  List<Object> get props => [scale];
}

final class ScaleError extends ScaleState {
  final String error;

  const ScaleError(this.error);

  @override
  List<Object> get props => [error];
}
