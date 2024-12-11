import 'package:bloc/bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/models/request/submit_handover_mixing_request.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/submit_handover_mixing_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'submit_handover_mixing_event.dart';
part 'submit_handover_mixing_state.dart';

class SubmitHandoverMixingBloc
    extends Bloc<SubmitHandoverMixingEvent, SubmitHandoverMixingState> {
  final SubmitHandoverMixingRepository _submitHandoverMixingRepository =
      SubmitHandoverMixingRepository();
  SubmitHandoverMixingBloc() : super(SubmitHandoverMixingInitial()) {
    on<SubmitHandoverMixing>((event, emit) async {
      emit(SubmitHandoverMixingLoading());
      try {
        var dateNow = DateTime.now();
        var formattedDate = DateFormat('yyyyMMdd-HHmmss').format(dateNow);
        var finishdate = formattedDate.split("-");
        var startDate = [];
        startDate = event.handoverMixingData.startTime.split("-");
        print("------------------------");
        print(startDate);
        SubmitHandoverMixingRequest submitHandoverMixing =
            SubmitHandoverMixingRequest(
                routingNo: event.handoverMixingData.selectedOrder.routingNo,
                activityNo:
                    event.handoverMixingData.selectedOperation.activityNo,
                activityWh: event.handoverMixingData.tong,
                operationType: event.handoverMixingData.operationType,
                operationApps: event.handoverMixingData.operationApps,
                startDate: startDate[0],
                startTime: startDate[1],
                finishDate: finishdate[0],
                finishTime: finishdate[1],
                operator: event.handoverMixingData.operator,
                pengawas: event.handoverMixingData.pengawas);
        String handoverMixing = await _submitHandoverMixingRepository
            .submitHandoverMixing(submitHandoverMixing);
        emit(SubmitHandoverMixingLoaded(submitHandoverMixing: handoverMixing));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(SubmitHandoverMixingError(e.error!.message!.value!));
        } else {
          emit(const SubmitHandoverMixingError('Server Error'));
        }
      }
    });
  }
}
