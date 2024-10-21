import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  HandoverCubit() : super(HandoverState());

  void setDataOrder(
    String plant,
    String materialCode,
    String date,
    String operationType,
  ) {
    emit(state.copyWith(
        plant: plant,
        materialCode: materialCode,
        date: date,
        operationType: operationType));
  }

  void setOrderList(ResultsOrder selectedOperation) {
    emit(state.copyWith(selectedOperation: selectedOperation));
  }

  void setOperation(ResultOperation selectedOperationNumber) {
    if (state.selectedOperationNumber.activityNo ==
        selectedOperationNumber.activityNo) {
      emit(state.copyWith(
        selectedOperationNumber: selectedOperationNumber,
        isResultOperationLoaded: true,
      ));
    } else {
      emit(state.copyWith(
          selectedOperationNumber: selectedOperationNumber,
          isResultOperationLoaded: true,
          tongs: [],
          isComplete: false));
    }
  }

  void setFullpack(List<ResultsFullPack> fullpack) {
    emit(state.copyWith(isLoadingFullpack: true));
    emit(state.copyWith(fullpack: fullpack, isLoadingFullpack: false));
  }

  void setTab(HandoverStatus tab) {
    emit(state.copyWith(tab: tab));
  }

  void setResultTong(List<ResultTong> tongs) {
    emit(state.copyWith(isLoadingTong: true));
    emit(state.copyWith(
        tongs: tongs, isLoadingFullpack: false, isLoadingTong: false));
  }

  void setScannedTong(String activityNo) {
    emit(state.copyWith(isLoadingTong: true));
    var tongs = state.tongs;
    var fullpack = state.fullpack;
    var materialSets = state.materialSet;
    var completed = 0;
    var completedFullpack = 0;
    var completedMaterialset = 0;
    for (var i = 0; i < tongs.length; i++) {
      if (tongs[i].activityNo == activityNo) {
        var tong = tongs[i].copyWith(isScanned: true);
        tongs[i] = tong;
      }
      if (tongs[i].isScanned) {
        completed++;
      }

      for (var j = 0; j < fullpack.length; j++) {
        if (fullpack[j].counter == activityNo) {
          var fullpacks = fullpack[j].copyWith(isScannedFullpack: true);
          fullpack[j] = fullpacks;
        }
        if (fullpack[j].isScannedFullpack) {
          completedFullpack++;
        }
      }

      for (var k = 0; k < materialSets.length; k++) {
        if (materialSets[k].bOMItem == activityNo) {
          var materialSet = materialSets[k].copyWith(isScanned: true);
          materialSets[k] = materialSet;
        }
        if (materialSets[k].isScanned) {
          completedMaterialset++;
        }
      }
    }
    var formattedDate = state.startDate;
    if (formattedDate == "") {
      var now = DateTime.now();
      formattedDate = DateFormat('yyyMMdd-HH:mm:ss').format(now);
      print(now);
    }
    emit(state.copyWith(
        tongs: tongs,
        fullpack: fullpack,
        isLoadingTong: false,
        isLoadingFullpack: false,
        isComplete:
            completed == tongs.length && completedFullpack == fullpack.length,
        isCompleteTong: completed == tongs.length &&
            completedFullpack == fullpack.length &&
            completedMaterialset == materialSets.length,
        startDate: formattedDate));
  }

  void resetFullpackWadah() {
    emit(state.copyWith(tongs: [], fullpack: [], isComplete: false));
  }

  void setMaterialSet(List<ResultsMaterialset> materialSet) {
    emit(state.copyWith(isLoadingMaterialset: true));
    emit(state.copyWith(materialSet: materialSet, isLoadingMaterialset: false));
  }
}
