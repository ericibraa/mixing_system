part of 'result_scale_bloc.dart';

@immutable
abstract class ResultScaleState extends Equatable {
  @override
  List<Object> get props => [];
}

final class ResultScaleInitial extends ResultScaleState {}

final class ResultScaleLoading extends ResultScaleState {}

final class ResultScaleLoaded extends ResultScaleState {
  final ResultScaleListResponse resultScale;

  ResultScaleLoaded({required this.resultScale});

  @override
  List<Object> get props => [resultScale];
}

final class ResultScaleError extends ResultScaleState {}
