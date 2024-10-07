part of 'operation_bloc.dart';

@immutable
abstract class OperationEvent extends Equatable {
  const OperationEvent();

  @override
  List<Object> get props => [];
}

class SendDataOperation extends OperationEvent {
  final String startDate;
  final String materialCode;
  final String plant;
  final String operationType;

  const SendDataOperation(
      {required this.plant,
      required this.materialCode,
      required this.operationType,
      required this.startDate});
  @override
  List<Object> get props => [plant, materialCode, operationType, startDate];
}
