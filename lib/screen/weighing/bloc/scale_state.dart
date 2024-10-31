part of 'scale_bloc.dart';

@immutable
abstract class ScaleState extends Equatable {
  @override
  List<Object> get props => [];
}

final class ScaleInitial extends ScaleState {}

final class ScaleLoading extends ScaleState {}

final class ScaleLoaded extends ScaleState {
  final ScaleResponse scale;
  ScaleLoaded({required this.scale});

  @override
  List<Object> get props => [scale];
}

final class ScaleError extends ScaleState {}
