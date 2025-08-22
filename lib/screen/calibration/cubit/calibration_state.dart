part of 'calibration_cubit.dart';

@immutable
class CalibrationState extends Equatable {
  final List<ResultScale> equipments;
  final ResultScale selectedEquipment;
  final Scale scaleWeighing;
  final bool isConnectedTcp;

  const CalibrationState(
      {this.equipments = const [],
      this.selectedEquipment = const ResultScale(),
      this.scaleWeighing = const Scale(),
      this.isConnectedTcp = false});

  CalibrationState copyWith({
    List<ResultScale>? equipments,
    ResultScale? selectedEquipment,
    Scale? scaleWeighing,
    bool? isConnectedTcp,
  }) {
    return CalibrationState(
        equipments: equipments ?? this.equipments,
        selectedEquipment: selectedEquipment ?? this.selectedEquipment,
        scaleWeighing: scaleWeighing ?? this.scaleWeighing,
        isConnectedTcp: isConnectedTcp ?? this.isConnectedTcp);
  }

  @override
  List<Object> get props =>
      [equipments, selectedEquipment, scaleWeighing, isConnectedTcp];
}
