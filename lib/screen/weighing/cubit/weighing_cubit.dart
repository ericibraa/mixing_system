import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/label.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'weighing_state.dart';

class WeighingCubit extends Cubit<WeighingState> {
  WeighingCubit() : super(const WeighingState());

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

  void setOrderList(ResultsOrder orderList) {
    emit(state.copyWith(orderList: orderList));
  }

  void setOrders(List<ResultsOrder> orders) {
    emit(state.copyWith(orders: orders));
  }

  void setOperationList(ResultOperation operationList) {
    emit(state.copyWith(
      operationList: operationList,
      isResultOperationLoaded: true,
    ));
  }

  void setTab(WeighingStatus tab) {
    emit(state.copyWith(tab: tab));
  }

  void setConnectedStatus(bool connectedStatus) {
    emit(state.copyWith(isConnectedTcp: connectedStatus));
  }

  void setScaleWeighing(Scale scale) {
    scale = scale.copyWith(
      netto: scale.bruto - scale.tara,
    );
    emit(state.copyWith(scaleWeighing: scale));
  }

  void setWeighing(List<ResultTong> weighing) {
    emit(state.copyWith(weighingList: weighing));
  }

  void selectedWeighing(ResultTong selectedWeighing) {
    emit(state.copyWith(selectedWeighing: selectedWeighing));
  }

  void setLabel(ResultsLabel label) {
    emit(state.copyWith(label: label));
  }

  void resetScaleWeighing() {
    emit(state.copyWith(scaleWeighing: const Scale()));
  }

  void setEquipments(List<ResultScale> equipments) {
    emit(state.copyWith(equipments: equipments));
  }

  void setSelectedEquipment(ResultScale selectedEqupment) {
    emit(state.copyWith(selectedEquipment: selectedEqupment));
  }

  void setOperator(String operator) {
    emit(state.copyWith(operator: operator));
  }

  void setPengawas(String pengawas) {
    emit(state.copyWith(pengawas: pengawas));
  }

  void setResultScaleList(List<ResultScaleList> resultScaleList) {
    emit(state.copyWith(resultScaleList: resultScaleList));
  }

  void setContainerCounter(int sumContainer) {
    emit(state.copyWith(containerCounter: sumContainer));
  }

  void setProductiSupervisor(String productiSupervisor) {
    emit(state.copyWith(productiSupervisor: productiSupervisor));
  }

  void setLine(String line) {
    emit(state.copyWith(line: line));
  }

  void setOperationTypeList(List<ResultsOprType> operationTypeList) {
    emit(state.copyWith(operationTypeList: operationTypeList));
  }

  void setMaterialsFull(ResultsOperationType resultsOpr) {
    emit(state.copyWith(resultsOpr: resultsOpr));
  }

  void setTotalContainer(String total) {
    emit(state.copyWith(totalContainer: total));
  }

  void setStartWork() {
    emit(state.copyWith(onChangeStartWork: true));
    emit(state.copyWith(startWork: DateTime.now(), onChangeStartWork: false));
  }
}
