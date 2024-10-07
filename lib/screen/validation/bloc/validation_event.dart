part of 'validation_bloc.dart';

@immutable
abstract class ValidationEvent extends Equatable {
  const ValidationEvent();

  @override
  List<Object> get props => [];
}

class SendValidation extends ValidationEvent {
  final String nrp;
  final String title;

  const SendValidation({required this.nrp, required this.title});
  @override
  List<Object> get props => [nrp, title];
}
