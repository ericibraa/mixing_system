part of 'operation_type_bloc.dart';

@immutable
abstract class OperationTypeEvent extends Equatable {
  const OperationTypeEvent();
  @override
  List<Object> get props => [];
}

class SendDataOperationType extends OperationTypeEvent {
  final String startDate;
  final String materialCode;
  final String plant;

  const SendDataOperationType(
      {required this.startDate,
      required this.materialCode,
      required this.plant});

  @override
  List<Object> get props => [startDate, materialCode, plant];
}
