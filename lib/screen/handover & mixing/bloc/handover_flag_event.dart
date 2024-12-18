part of 'handover_flag_bloc.dart';

@immutable
abstract class HandoverFlagEvent extends Equatable {
  const HandoverFlagEvent();

  @override
  List<Object> get props => [];
}

class FlagHandover extends HandoverFlagEvent {
  final List<dynamic> handoverFlag;

  const FlagHandover({required this.handoverFlag});
}
