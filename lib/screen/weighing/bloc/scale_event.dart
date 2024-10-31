part of 'scale_bloc.dart';

@immutable
abstract class ScaleEvent extends Equatable {
  const ScaleEvent();

  @override
  List<Object?> get props => [];
}

class SendDataScale extends ScaleEvent {
  final String plant;

  const SendDataScale({required this.plant});
  @override
  List<Object?> get props => [plant];
}
