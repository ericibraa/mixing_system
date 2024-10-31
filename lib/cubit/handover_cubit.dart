import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  // ignore: prefer_const_constructors
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

  void setOperationApps(String operationApps) {
    emit(state.copyWith(operationApps: operationApps));
  }

  void setScannedTong(List<String> activityNo) {
    emit(state.copyWith(
        isLoadingTong: true,
        isLoadingFullpack: true,
        isLoadingMaterialset: true));
    print(activityNo.length);
    var tongs = state.tongs;
    var fullpack = state.fullpack;
    var materialSets = state.materialSet;
    var line = state.line;
    var completed = 0;
    var completedFullpack = 0;
    var completedMaterialset = 0;
    var isChecked = false;
    var isNullData = false;
    var matchFound = false;
    var unscannedPriorities = materialSets
        .where((material) => !material.isScanned)
        .map((material) => material.priority)
        .toSet();
    var lowestUnscannedPriority = unscannedPriorities.isNotEmpty
        ? unscannedPriorities.reduce((a, b) => a.compareTo(b) < 0 ? a : b)
        : null;

    for (var i = 0; i < tongs.length; i++) {
      if (activityNo.length == 4) {
        if (tongs[i].activityNo == activityNo[3]) {
          matchFound = true;
          if (tongs[i].isScanned!) {
            isChecked = true;
          } else {
            var tong = tongs[i].copyWith(isScanned: true);
            tongs[i] = tong;
          }
          isNullData = !matchFound;
        }
      }
      if (tongs[i].isScanned!) {
        completed++;
      }
    }

    for (var j = 0; j < fullpack.length; j++) {
      if (activityNo.length > 6) {
        if (fullpack[j].bOMItem == activityNo[3] &&
            fullpack[j].counter == activityNo[6]) {
          matchFound = true;
          if (fullpack[j].isScannedFullpack) {
            isChecked = true;
          } else {
            var fullpacks = fullpack[j].copyWith(isScannedFullpack: true);
            fullpack[j] = fullpacks;
          }
        }
        isNullData = !matchFound;
      }
      if (fullpack[j].isScannedFullpack) {
        completedFullpack++;
      }
    }

    for (var k = 0; k < materialSets.length; k++) {
      if (activityNo.length == 9) {
        if (materialSets[k].bOMItem == activityNo[3] &&
            materialSets[k].counter == activityNo[6] &&
            materialSets[k].priority == lowestUnscannedPriority) {
          matchFound = true;
          if (materialSets[k].isScanned) {
            isChecked = true;
          } else {
            var materialSet = materialSets[k].copyWith(isScanned: true);
            materialSets[k] = materialSet;
          }
        }
        isNullData = !matchFound;
      } else if (activityNo.length == 6) {
        if (materialSets[k].bOMItem == activityNo[3] &&
            materialSets[k].counter.isEmpty &&
            materialSets[k].priority == lowestUnscannedPriority) {
          matchFound = true;
          if (materialSets[k].isScanned) {
            isChecked = true;
          } else {
            var materialSet = materialSets[k].copyWith(isScanned: true);
            materialSets[k] = materialSet;
            emit(state.copyWith(tong: activityNo[2]));
          }
        }
        isNullData = !matchFound;
      }

      if (materialSets[k].isScanned) {
        completedMaterialset++;
      }
    }

    if (activityNo.length == 1) {
      line = activityNo[0];
    }
    var formattedDate = state.startDate;
    if (formattedDate == "") {
      var now = DateTime.now();
      formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);
    }
    emit(state.copyWith(
        tongs: tongs,
        fullpack: fullpack,
        materialSet: materialSets,
        line: line,
        isLoadingTong: false,
        isLoadingFullpack: false,
        isLoadingMaterialset: false,
        isComplete:
            completed == tongs.length && completedFullpack == fullpack.length,
        isCompleteTong: completed == tongs.length &&
            completedFullpack == fullpack.length &&
            completedMaterialset == materialSets.length,
        isCompleteMaterials: completedMaterialset == materialSets.length &&
            completedMaterialset != 0,
        startDate: formattedDate,
        isChecked: isChecked,
        isNullData: isNullData));
  }

  void resetFullpackWadah() {
    emit(state.copyWith(tongs: [], fullpack: [], isComplete: false));
  }

  void setMaterialSet(List<ResultsMaterialset> materialSet) {
    emit(state.copyWith(isLoadingMaterialset: true));
    emit(state.copyWith(materialSet: materialSet, isLoadingMaterialset: false));
  }

  void setOperator(String operator) {
    emit(state.copyWith(operator: operator));
  }

  void setPengawas(String pengawas) {
    emit(state.copyWith(pengawas: pengawas));
  }

  void resetCompleteMaterial(bool material) {
    emit(state.copyWith(isCompleteMaterials: material, materialSet: []));
  }
}
