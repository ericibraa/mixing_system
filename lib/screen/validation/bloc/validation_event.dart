part of 'validation_bloc.dart';

@immutable
abstract class ValidationEvent extends Equatable {
  const ValidationEvent();

  @override
  List<Object> get props => [];
}

class SendValidation extends ValidationEvent {
  final String nrp;
  final String name;
  final String title;

  const SendValidation(
      {required this.nrp, required this.name, required this.title});
  @override
  List<Object> get props => [nrp, name, title];
}
