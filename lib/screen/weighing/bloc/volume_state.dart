part of 'volume_bloc.dart';

@immutable
abstract class VolumeState extends Equatable {
    @override
  List<Object> get props => [];
}

final class VolumeInitial extends VolumeState {}

final class VolumeLoading extends VolumeState {}

final class VolumeLoaded extends VolumeState {
  final Volume volume;
  VolumeLoaded({required this.volume});

  @override
  List<Object> get props => [volume];
}

final class VolumeError extends VolumeState {}
