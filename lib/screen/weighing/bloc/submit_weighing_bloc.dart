import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/submit_weighing.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/submit_weighing._repository.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        DateTime finishTimeWeighing = DateTime.now();
        DateTime? expiredDateParse;
        String finalExpDate = '';
        String finalExpTime = '';
        String lotNo = '';
        if (event.weighingState.operationType == 'DECOCT') {
          if (event.weighingState.scaleWeighing.lot == '-') {
            lotNo = event.weighingState.selectedContainer.lot!;
          } else {
            lotNo = event.weighingState.scaleWeighing.lot;
          }
        }
        if (event.weighingState.expiredSet.expiredNo != '0,000') {
          if (event.weighingState.expiredSet.unit == 'DAY') {
            expiredDateParse = finishTimeWeighing.add(Duration(
                days: int.parse(event.weighingState.expiredSet.expiredNo!)));
            finalExpDate = DateFormat('yyyyMMdd').format(expiredDateParse);
            finalExpTime = DateFormat('HHmmss').format(expiredDateParse);
          } else {
            expiredDateParse = finishTimeWeighing.add(Duration(
                hours: int.parse(event.weighingState.expiredSet.expiredNo!)));
            finalExpDate = DateFormat('yyyyMMdd').format(expiredDateParse);
            finalExpTime = DateFormat('HHmmss').format(expiredDateParse);
          }
        }
        SubmitWeighing submitWeighing = SubmitWeighing(
            orderNo: event.weighingState.selectedOrder.orderNo,
            activityNo: event.weighingState.selectedOperation.activityNo,
            equipmentNo: event.weighingState.selectedEquipment.equipmentNo,
            resource: event.weighingState.expiredSet.workCenter,
            activityWh: event.weighingState.selectedContainer.activityWh,
            bruto: event.weighingState.scaleWeighing.bruto.toString(),
            tara: event.weighingState.scaleWeighing.tara.toString(),
            netto: event.weighingState.scaleWeighing.netto.toString(),
            unitWeighing: event.weighingState.scaleWeighing.unit,
            temperature: event.weighingState.scaleWeighing.temperature,
            unitTemperature: "GC",
            moistureContent: event.weighingState.scaleWeighing.moistureContent,
            unitMoisture: "%",
            expiredDate: finalExpDate,
            expiredTime: finalExpTime,
            operator: event.weighingState.operator,
            pengawas: event.weighingState.pengawas,
            startDate:
                DateFormat('yyyyMMdd').format(event.weighingState.startWork!),
            startTime:
                DateFormat('HHmmss').format(event.weighingState.startWork!),
            wadah: event.weighingState.containerCounter.toString(),
            totalWadah: event.weighingState.scaleWeighing.numberOfContainer,
            line: event.weighingState.line,
            finishDate: DateFormat('yyyyMMdd').format(finishTimeWeighing),
            finishTime: DateFormat('HHmmss').format(finishTimeWeighing),
            lotNo: lotNo);

        final weighing =
            await _submitWeighingRepository.submitweighing(submitWeighing);
        print('++++++++++++++++++++++++++++++');
        print(weighing.toString());
        emit(SubmitWeighingSuccess(submitWeighing: weighing));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(SubmitWeighingError(e.error!.message!.value!));
        } else {
          emit(const SubmitWeighingError('Server Error'));
        }
      }
    });
  }
}
