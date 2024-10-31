import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'weighing_state.dart';

class WeighingCubit extends Cubit<WeighingState> {
  WeighingCubit() : super(const WeighingState());

  void setDataOrder(String plant, String materialCode, String date,
      String operationApps, String operationType) {
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
    emit(state.copyWith(scaleWeighing: scale));
  }

  void setWeighing(List<ResultTong> weighing) {
    emit(state.copyWith(weighingList: weighing));
  }

  void selectedWeighing(ResultTong selectedWeighing) {
    emit(state.copyWith(selectedWeighing: selectedWeighing));
  }
}
