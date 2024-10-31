part of 'submit_handover_mixing_bloc.dart';

@immutable
abstract class SubmitHandoverMixingEvent extends Equatable {
  const SubmitHandoverMixingEvent();

  @override
  List<Object> get props => [];
}

class SubmitHandoverMixing extends SubmitHandoverMixingEvent {
  final HandoverState handoverMixingData;

  const SubmitHandoverMixing({required this.handoverMixingData});
}
