import 'package:bloc/bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/models/request/submit_handover.dart';
import 'package:dumping_system/repository/submit_handover_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
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
        SubmitHandoverRequest submitHandover = SubmitHandoverRequest(
            orderNo: event.orderData.selectedOperation.orderNo,
            plant: event.orderData.plant,
            material: event.orderData.materialCode,
            batchFG: event.orderData.selectedOperation.batchFG,
            routingNo: event.orderData.selectedOperation.routingNo,
            internalCntr: event.orderData.selectedOperation.internalCntr,
            operationType: event.orderData.operationType,
            ordToOprNav: [
              OrdToOprNav(
                  routingNo: event.orderData.selectedOperationNumber.routingNo,
                  internalCntr:
                      event.orderData.selectedOperationNumber.internalCntr,
                  activityNo:
                      event.orderData.selectedOperationNumber.activityNo,
                  operationDesc:
                      event.orderData.selectedOperationNumber.operationDesc,
                  controlRecipe:
                      event.orderData.selectedOperationNumber.controlRecipe,
                  operationApps: operationApps,
                  line: event.orderData.line,
                  startDate: startDate[0],
                  startTime: startDate[1],
                  finishDate: finishdate[0],
                  finishTime: finishdate[1],
                  operator: event.orderData.operator,
                  pengawas: event.orderData.pengawas)
            ]);
        print("=====================");
        print(submitHandover.toJson());
        String handover =
            await _submitHandoverRepository.submitHandover(submitHandover);
        emit(SubmitHandoverLoaded(submitHandover: handover));
      } catch (e) {
        emit(SubmitHandoverError());
      }
    });
  }
}
