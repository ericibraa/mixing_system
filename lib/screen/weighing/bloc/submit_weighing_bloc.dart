import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/submit_weighing.dart';
import 'package:dumping_system/repository/submit_weighing._repository.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'submit_weighing_event.dart';
part 'submit_weighing_state.dart';

class SubmitWeighingBloc
    extends Bloc<SubmitWeighingEvent, SubmitWeighingState> {
  final SubmitWeighingRepository _submitWeighingRepository =
      SubmitWeighingRepository();
  SubmitWeighingBloc() : super(SubmitWeighingInitial()) {
    on<SendDataWeighing>((event, emit) async {
      emit(SubmitWeighingLoading());
      try {
        var createDateParts =
            event.weighingState.scaleWeighing.createDate.split("-");
        var expiredDateParts =
            event.weighingState.scaleWeighing.expiredDate.split("-");

        var createDate = createDateParts.length > 1 ? createDateParts[0] : '';
        var createTime = createDateParts.length > 1 ? createDateParts[1] : '';
        var expiredDate =
            expiredDateParts.length > 1 ? expiredDateParts[0] : '';
        var expiredTime =
            expiredDateParts.length > 1 ? expiredDateParts[1] : '';
        SubmitWeighing submitWeighing = SubmitWeighing(
            orderNo: event.weighingState.orderList.orderNo,
            activityNo: event.weighingState.operationList.activityNo,
            equipmentNo: event.weighingState.scaleWeighing.scaleId,
            resource: event.weighingState.label.workCenter,
            activityWh: event.weighingState.selectedWeighing.activityWh,
            bruto: event.weighingState.scaleWeighing.bruto.toString(),
            tara: event.weighingState.scaleWeighing.tara.toString(),
            netto: event.weighingState.scaleWeighing.netto.toStringAsFixed(1),
            unitWeighing: event.weighingState.scaleWeighing.unit,
            temperature: event.weighingState.scaleWeighing.temperature,
            unitTemperature: "GC",
            moistureContent: event.weighingState.scaleWeighing.moistureContent,
            unitMoisture: "%",
            expiredDate: expiredDate,
            expiredTime: expiredTime,
            operator: event.weighingState.operator,
            pengawas: event.weighingState.pengawas,
            createDate: createDate,
            createTime: createTime,
            wadah: event.weighingState.containerCounter.toString(),
            totalWadah: event.weighingState.scaleWeighing.numberOfContainer);
        String weighing =
            await _submitWeighingRepository.submitweighing(submitWeighing);
        emit(SubmitWeighingSuccess(submitWeighing: weighing));
      } catch (e) {
        emit(SubmitWeighingError());
      }
    });
  }
}
