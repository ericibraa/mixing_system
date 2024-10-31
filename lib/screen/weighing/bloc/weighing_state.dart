part of 'weighing_bloc.dart';

@immutable
abstract class WeighingBlocState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class WeighingInitial extends WeighingBlocState {}

final class WeighingLoading extends WeighingBlocState {}

final class WeighingLoaded extends WeighingBlocState {
  final TongResponse weighing;
  WeighingLoaded({required this.weighing});

  @override
  List<Object> get props => [weighing];
}

final class WeighingErros extends WeighingBlocState {}
