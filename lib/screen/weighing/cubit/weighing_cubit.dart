import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/label.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
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
    var formattedDate = scale.createDate;
    var expired = state.label.expiredNo;
    var now = DateTime.now();
    DateTime expiredDate;

    if (formattedDate.isEmpty) {
      // Check if expiredNo is not null and is a valid integer
      int durationValue = 0;
      if (state.label.expiredNo != null && state.label.expiredNo!.isNotEmpty) {
        durationValue = int.tryParse(state.label.expiredNo!) ?? 0;
      }

      // Calculate expiredDate based on the unit
      if (state.label.unit == "DAY") {
        expiredDate = now.add(Duration(days: durationValue));
      } else {
        expiredDate = now.add(Duration(hours: durationValue));
      }

      // Format the dates
      formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);
      expired = DateFormat('yyyyMMdd-HHmmss').format(expiredDate);
    }

    // Update the scale and state
    scale = scale.copyWith(
      netto: scale.bruto - scale.tara,
      createDate: formattedDate,
      expiredDate: expired,
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

  void setScale(ResultScale resultScale) {
    emit(state.copyWith(scaleUnit: resultScale));
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

  void setContainer(int sumContainer) {
    print(sumContainer);
    emit(state.copyWith(containerCounter: sumContainer));
  }

  void setProductiSupervisor(String productiSupervisor) {
    emit(state.copyWith(productiSupervisor: productiSupervisor));
  }
}
