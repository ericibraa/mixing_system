import 'package:bloc/bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/models/request/submit_handover.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/submit_handover_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'post_handover_event.dart';
part 'post_handover_state.dart';

class SubmitHandoverBloc
    extends Bloc<SubmitHandoverEvent, SubmitHandoverState> {
  final SubmitHandoverRepository _submitHandoverRepository =
      SubmitHandoverRepository();
  SubmitHandoverBloc() : super(SubmitHandoverInitial()) {
    on<SubmitHandover>((event, emit) async {
      emit(SubmitHandoverLoading());
      try {
        var startDate = event.orderData.startDate.split('-');
        var dateNow = DateTime.now();
        var formattedDate = DateFormat('yyyyMMdd-HHmmss').format(dateNow);
        var finishdate = formattedDate.split("-");
        var operationApps = event.orderData.operationApps;
        operationApps = event.orderData.operationApps;
        String activityWh = '';
        if (event.orderData.fullpack.isNotEmpty &&
            event.orderData.fullpack[0].bOMItem.isEmpty) {
          activityWh = event.orderData.fullpack[0].activityNo;
        }
        SubmitHandoverRequest submitHandover = SubmitHandoverRequest(
            orderNo: event.orderData.selectedOrder.orderNo,
            plant: event.orderData.plant,
            material: event.orderData.materialCode,
            batchFG: event.orderData.selectedOrder.batchFG,
            routingNo: event.orderData.selectedOrder.routingNo,
            internalCntr: event.orderData.selectedOrder.internalCntr,
            operationType: event.orderData.operationType,
            ordToOprNav: [
              OrdToOprNav(
                  routingNo: event.orderData.selectedOperation.routingNo,
                  internalCntr: event.orderData.selectedOperation.internalCntr,
                  activityNo: event.orderData.selectedOperation.activityNo,
                  operationDesc:
                      event.orderData.selectedOperation.operationDesc,
                  controlRecipe:
                      event.orderData.selectedOperation.controlRecipe,
                  operationApps: operationApps,
                  line: event.orderData.line,
                  startDate: startDate[0],
                  startTime: startDate[1],
                  finishDate: finishdate[0],
                  finishTime: finishdate[1],
                  operator: event.orderData.operator,
                  pengawas: event.orderData.pengawas,
                  activityWh: activityWh)
            ]);
        String handover =
            await _submitHandoverRepository.submitHandover(submitHandover);
        emit(SubmitHandoverLoaded(submitHandover: handover));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(SubmitHandoverError(e.error!.message!.value!));
        } else {
          emit(const SubmitHandoverError('Server Error'));
        }
      }
    });
  }
}
