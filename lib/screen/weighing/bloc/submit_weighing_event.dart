part of 'submit_weighing_bloc.dart';

@immutable
abstract class SubmitWeighingEvent extends Equatable {
  const SubmitWeighingEvent();

  @override
  List<Object> get props => [];
}

class SendDataWeighing extends SubmitWeighingEvent {
  final WeighingState weighingState;

  const SendDataWeighing({required this.weighingState});
}
