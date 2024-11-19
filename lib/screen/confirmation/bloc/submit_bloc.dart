import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/submit_confirmation.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/submit_confirmation.dart';
import 'package:dumping_system/screen/confirmation/cubit/confirmation_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'submit_event.dart';
part 'submit_state.dart';

class SubmitBloc extends Bloc<SubmitEvent, SubmitState> {
  final SubmitConfirmationRepository _submitConfirmationRepository =
      SubmitConfirmationRepository();
  SubmitBloc() : super(SubmitInitial()) {
    on<SubmitConfirmation>((event, emit) async {
      emit(SubmitLoading());
      try {
        DateTime finishDate = DateTime.now();
        SubmitConfirmationRequest submitConfirmationRequest =
            SubmitConfirmationRequest(
                routingNo: event.submitConfirmation.yieldSet.routingNo,
                internalCntr: event.submitConfirmation.yieldSet.internalCntr,
                orderNo: event.submitConfirmation.yieldSet.orderNo,
                activityNo: event.submitConfirmation.yieldSet.activityNo,
                yieldQty: event.submitConfirmation.yieldSet.yieldQty,
                unitYield: event.submitConfirmation.yieldSet.unitYield,
                startDateOpr: event.submitConfirmation.yieldSet.startDateOpr,
                startTimeOpr: event.submitConfirmation.yieldSet.startTimeOpr,
                startDateConf: DateFormat('yyyyMMdd')
                    .format(event.submitConfirmation.startTime!),
                startTimeConf: DateFormat('HHmmss')
                    .format(event.submitConfirmation.startTime!),
                finishDate: DateFormat('yyyyMMdd').format(finishDate),
                finishTime: DateFormat('HHmmss').format(finishDate),
                line: event.submitConfirmation.line,
                postDate: DateFormat('yyyyMMdd').format(finishDate),
                machineHour: '0',
                laborHour: '0',
                operationApps: '40',
                operator: event.submitConfirmation.operator,
                pengawas: event.submitConfirmation.pengawas);
        SubmitConfirmationResponse confirmation =
            await _submitConfirmationRepository
                .submitConfirmation(submitConfirmationRequest);
        emit(SubmitSuccess(confirmation));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(SubmitError(e.error!.message!.value!));
        } else {
          emit(const SubmitError('Server Error'));
        }
      }
    });
  }
}
