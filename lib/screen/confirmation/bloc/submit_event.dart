part of 'submit_bloc.dart';

@immutable
abstract class SubmitEvent extends Equatable {
  const SubmitEvent();

  @override
  List<Object> get props => [];
}

class SubmitConfirmation extends SubmitEvent {
  final ConfirmationState submitConfirmation;

  const SubmitConfirmation(this.submitConfirmation);
}
