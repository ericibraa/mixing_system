part of 'weighing_bloc.dart';

@immutable
abstract class WeighingBlocState extends Equatable {
  const WeighingBlocState();
  @override
  List<Object?> get props => [];
}

final class WeighingInitial extends WeighingBlocState {}

final class WeighingLoading extends WeighingBlocState {}

final class WeighingLoaded extends WeighingBlocState {
  final WeighingResult weighing;
  const WeighingLoaded({required this.weighing});

  @override
  List<Object> get props => [weighing];
}

final class WeighingErros extends WeighingBlocState {
  final String error;

  const WeighingErros(this.error);

  @override
  List<Object> get props => [error];
}
