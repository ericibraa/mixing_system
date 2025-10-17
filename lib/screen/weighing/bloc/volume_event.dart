part of 'volume_bloc.dart';

@immutable
abstract class VolumeEvent extends Equatable {
  const VolumeEvent();

  @override
  List<Object?> get props => [];
}

class GetVolume extends VolumeEvent {
  final String plant;

  const GetVolume({required this.plant});
  @override
  List<Object?> get props => [plant];
}
