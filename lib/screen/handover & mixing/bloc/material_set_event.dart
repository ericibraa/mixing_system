part of 'material_set_bloc.dart';

@immutable
abstract class MaterialSetEvent extends Equatable {
  const MaterialSetEvent();

  @override
  List<Object> get props => [];
}

class SendDataMaterialset extends MaterialSetEvent {
  final String routingNo;
  final String activityNo;
  final String operationType;

  const SendDataMaterialset(
      {required this.routingNo,
      required this.activityNo,
      required this.operationType});
  @override
  List<Object> get props => [routingNo, activityNo, operationType];
}
