import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'calibration_state.dart';

class CalibrationCubit extends Cubit<CalibrationState> {
  CalibrationCubit() : super(const CalibrationState());

  void setEquipments(List<ResultScale> equipments) {
    emit(state.copyWith(equipments: equipments));
  }

  void setSelectedEquipment(String equipmentNo) {
    ResultScale selectedEquipment = state.equipments.firstWhere(
        (equpment) => equpment.equipmentNo == equipmentNo,
        orElse: () => const ResultScale());
    emit(state.copyWith(selectedEquipment: selectedEquipment));
  }

  void setScaleWeighing(Scale scale) {
    scale = scale.copyWith(
      netto: scale.bruto - scale.tara,
    );
    emit(state.copyWith(scaleWeighing: scale));
  }

  void resetScaleWeighing() {
    emit(state.copyWith(scaleWeighing: const Scale()));
  }

  void setConnectedStatus(bool connectedStatus) {
    emit(state.copyWith(isConnectedTcp: connectedStatus));
  }
}
