import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/submit_confirmation.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/yield_set.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'confirmation_state.dart';

class ConfirmationCubit extends Cubit<ConfirmationState> {
  ConfirmationCubit() : super(const ConfirmationState());

  void setTab(ConfirmationStatus tab) {
    emit(state.copyWith(tab: tab));
  }

  void setOperator(String operator) {
    emit(state.copyWith(operator: operator));
  }

  void setPengawas(String pengawas) {
    emit(state.copyWith(pengawas: pengawas));
  }

  void setMaterials(List<ResultsMaterial> materials) {
    emit(state.copyWith(materials: materials));
  }

  void setProductiSupervisor(String productiSupervisor) {
    emit(state.copyWith(productSupervisor: productiSupervisor));
  }

  void setOperationTypes(List<ResultsOprType> operationTypes) {
    emit(state.copyWith(operationTypes: operationTypes));
  }

  void setOrders(List<ResultsOrder> orders) {
    emit(state.copyWith(orders: orders));
  }

  void setSelectedOrder(ResultsOrder selectedOrder) {
    emit(state.copyWith(selectedOrder: selectedOrder));
  }

  void setOperations(List<ResultOperation> operations) {
    emit(state.copyWith(operations: operations));
  }

  void setSelectedOperation(ResultOperation selectedOperation) {
    emit(state.copyWith(selectedOperation: selectedOperation));
  }

  void setDataOrder(
      String plant, String materialCode, String date, String operationType) {
    String? operationApps;
    switch (operationType) {
      case 'DECOCT':
        operationApps = '31';
        break;
      case 'CB':
        operationApps = '32';
        break;
      case 'CK':
        operationApps = '33';
        break;
      case 'LIQUID MIXING':
        operationApps = '34';
        break;
      case 'SEMI SOLID MIXING':
        operationApps = '35';
        break;
    }
    emit(state.copyWith(
        plant: plant,
        materialCode: materialCode,
        date: date,
        operationApps: operationApps,
        operationType: operationType));
  }

  void setYieldSet(ResultsYieldSet yieldSet) {
    emit(state.copyWith(yieldSet: yieldSet));
  }

  void editMachineTime(String machineTime) {
    var data = ResultsYieldSet(machineHour: machineTime);
    emit(state.copyWith(yieldSet: data));
  }

  void editLaborTime(String laborTime) {
    var data = ResultsYieldSet(laborHour: laborTime);
    emit(state.copyWith(yieldSet: data));
  }

  void setLine(String line) {
    emit(state.copyWith(line: line));
  }

  void setStartDate() {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(startTime: DateTime.now(), isLoading: false));
  }

  void setComplete(bool isComplete) {
    emit(state.copyWith(isComplete: isComplete));
  }

  void setReason(List<YieldToLinesNav> reason) {
    emit(state.copyWith(reason: reason));
  }
}
