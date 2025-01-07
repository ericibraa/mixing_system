import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/locationset.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/models/response/operation_type.dart';
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

  void setSelectedOrder(ResultsOrder selectedOrder) {
    emit(state.copyWith(selectedOrder: selectedOrder));
  }

  void setOrders(List<ResultsOrder> orders) {
    emit(state.copyWith(orders: orders));
  }

  void setOperation(ResultOperation selectedOperation) {
    if (state.selectedOperation.activityNo == selectedOperation.activityNo) {
      emit(state.copyWith(
        selectedOperation: selectedOperation,
        isResultOperationLoaded: true,
      ));
    } else {
      emit(state.copyWith(
          selectedOperation: selectedOperation,
          isResultOperationLoaded: true,
          tongs: [],
          isComplete: false));
    }
  }

  void setOperations(List<ResultOperation> operations) {
    emit(state.copyWith(operations: operations));
  }

  void setFullpack(List<ResultsFullPack> fullpack) {
    emit(state.copyWith(isLoadingFullpack: true));
    emit(state.copyWith(fullpack: fullpack, isLoadingFullpack: false));
  }

  void setTab(HandoverStatus tab) {
    emit(state.copyWith(tab: tab));
  }

  void setPrevTab(HandoverStatus prevTab) {
    emit(state.copyWith(prevTab: prevTab));
  }

  void setResultTong(List<ResultTong> tongs) {
    emit(state.copyWith(isLoadingTong: true));
    emit(state.copyWith(
        tongs: tongs, isLoadingFullpack: false, isLoadingTong: false));
  }

  void setOperationApps(String operationApps) {
    emit(state.copyWith(operationApps: operationApps));
  }

  void setLine(String line) {
    emit(state.copyWith(line: line));
  }

  void setScannedTong(List<String> activityNo) {
    emit(state.copyWith(
        isLoadingTong: true,
        isLoadingFullpack: true,
        isLoadingMaterialset: true));
    var tongs = state.tongs;
    var fullpack = state.fullpack;
    var materialSets = state.materialSet;
    var completed = tongs.where((tong) => tong.isScanned == true).length;
    var completedFullpack =
        fullpack.where((pack) => pack.isScannedFullpack == true).length;
    var completedMaterialset =
        materialSets.where((material) => material.scanFlag == 'X').length;
    var errorType = ErrorScanType.dataNull;
    String lastPrioEmpty = "";
    bool isMatch = false;

    if (state.tab == HandoverStatus.scantong ||
        state.tab == HandoverStatus.scanTongResultsWeighing) {
      var isFound = false;
      for (var i = 0; i < tongs.length; i++) {
        switch (activityNo.length) {
          case 4:
            if (state.operationType != 'DECOCT') {
              isMatch = tongs[i].activityNo == activityNo[3];
            }
            break;
          case 5:
            if (state.operationType == "DECOCT") {
              isMatch = tongs[i].activityNo == activityNo[3];
            }
            break;
        }
        if (tongs[i].isScanned!) {
          if (isMatch) {
            errorType = ErrorScanType.dataScanned;
            isFound = true;
            break;
          }
          continue;
        }
        if (isMatch) {
          var tong = tongs[i].copyWith(isScanned: true);
          completed++;
          tongs[i] = tong;
          isFound = true;
          errorType = ErrorScanType.noError;
          break;
        }
      }
      if (!isFound) {
        for (var k = 0; k < fullpack.length; k++) {
          switch (activityNo.length) {
            case 7:
              if (state.tab == HandoverStatus.scanTongResultsWeighing) {
                isMatch = fullpack[k].activityWh == activityNo[6] &&
                    fullpack[k].counter == activityNo[5];
              } else {
                isMatch = fullpack[k].activityDmp == activityNo[2] &&
                    fullpack[k].counter == activityNo[5];
              }
              break;
            case 9:
              isMatch = fullpack[k].bOMItem == activityNo[3] &&
                  fullpack[k].counter == activityNo[6] &&
                  int.parse(fullpack[k].batch) == int.parse(activityNo[8]);
              break;
          }
          if (fullpack[k].isScannedFullpack ||
              fullpack[k].handoverFlag == 'X') {
            if (isMatch) {
              errorType = ErrorScanType.dataScanned;
              break;
            }
            continue;
          }
          if (fullpack[k].scanFlag == "" || fullpack[k].handoverFlag == '') {
            if (lastPrioEmpty != "" && lastPrioEmpty != fullpack[k].priority) {
              errorType = ErrorScanType.incorrectPriority;
              break;
            }
            lastPrioEmpty = fullpack[k].priority;
            if (isMatch) {
              var fullpacks =
                  fullpack[k].copyWith(isScannedFullpack: true, scanFlag: 'X');
              completedFullpack++;
              fullpack[k] = fullpacks;
              errorType = ErrorScanType.noError;
              break;
            }
          }
        }
      }
    } else {
      var isFound = false;
      for (var i = 0; i < tongs.length; i++) {
        switch (activityNo.length) {
          case 4:
            if (state.operationType != 'DECOCT') {
              isMatch = tongs[i].activityNo == activityNo[3];
            }
            break;
          case 5:
            if (state.operationType == "DECOCT") {
              isMatch = tongs[i].activityNo == activityNo[3];
            }
            break;
        }
        if (tongs[i].isScanned!) {
          if (isMatch) {
            errorType = ErrorScanType.dataScanned;
            isFound = true;
            break;
          }
          continue;
        }
        if (isMatch) {
          var tong = tongs[i].copyWith(isScanned: true);
          completed++;
          tongs[i] = tong;
          isFound = true;
          errorType = ErrorScanType.noError;
          break;
        }
      }
      if (!isFound) {
        for (var k = 0; k < materialSets.length; k++) {
          print("================================");
          switch (activityNo.length) {
            case 6:
              isMatch = materialSets[k].bOMItem == activityNo[3] &&
                  materialSets[k].recipient == "W";
              break;
            case 7:
              isMatch = materialSets[k].activityDmp == activityNo[2] &&
                  materialSets[k].counter == activityNo[5] &&
                  materialSets[k].activityWh == activityNo[6];

              break;
            case 9:
              isMatch = (materialSets[k].bOMItem == activityNo[3] &&
                      materialSets[k].counter == activityNo[6]) ||
                  (materialSets[k].bOMItem == activityNo[3] &&
                      materialSets[k].counter == activityNo[6] &&
                      int.parse(fullpack[k].batch) == int.parse(activityNo[8]));
              break;
          }
          if (materialSets[k].scanFlag == "X") {
            if (isMatch) {
              errorType = ErrorScanType.dataScanned;
              break;
            }
            continue;
          }
          if (materialSets[k].scanFlag == "") {
            if (lastPrioEmpty != "" &&
                lastPrioEmpty != materialSets[k].priority) {
              errorType = ErrorScanType.incorrectPriority;
              break;
            }
            lastPrioEmpty = materialSets[k].priority;
            if (isMatch) {
              var materialSet =
                  materialSets[k].copyWith(isScanned: true, scanFlag: "X");
              completedMaterialset++;
              materialSets[k] = materialSet;
              errorType = ErrorScanType.noError;
              break;
            }
          }
        }
      }
    }

    var formattedDate = state.startDate;
    if (formattedDate == "") {
      var now = DateTime.now();
      formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);
    }
    var isCompleted = tongs.isNotEmpty && completed == tongs.length;
    var isCompletedFullpack =
        fullpack.isNotEmpty && completedFullpack == fullpack.length;
    var isCompletedMaterial =
        materialSets.isNotEmpty && completedMaterialset == materialSets.length;
    emit(state.copyWith(
        tongs: tongs,
        fullpack: fullpack,
        materialSet: materialSets,
        isLoadingTong: false,
        isLoadingFullpack: false,
        isLoadingMaterialset: false,
        isCompletedcontainer: isCompleted,
        isComplete: isCompleted && isCompletedFullpack,
        isCompleteTong:
            isCompleted && isCompletedFullpack && isCompletedMaterial,
        isCompleteMaterials: isCompletedMaterial && completedMaterialset != 0,
        isCompleteWeighingResults: isCompletedFullpack,
        startDate: formattedDate,
        errorScanType: errorType));
  }

  void resetFullpackWadah() {
    emit(state.copyWith(
        tongs: [],
        fullpack: [],
        isComplete: false,
        isCompleteTong: false,
        isCompletedcontainer: false,
        isCompleteMaterials: false,
        isCompleteWeighingResults: false));
  }

  void setMaterialSet(List<ResultsMaterialset> materialSet) {
    emit(state.copyWith(isLoadingMaterialset: true));
    emit(state.copyWith(materialSet: materialSet, isLoadingMaterialset: false));
  }

  void setIsLoadingMaterialSet(bool isLoading) {
    emit(state.copyWith(isLoadingMaterialset: isLoading));
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

  void setOperationType(List<ResultsOprType> operationTypeList) {
    emit(state.copyWith(operationTypeList: operationTypeList));
  }

  void isNext(bool isNext) {
    emit(state.copyWith(isNext: isNext));
  }

  void setLocationSet(List<ResultsLocationSet> locationSet) {
    emit(state.copyWith(locationSets: locationSet));
  }

  void setSelectedLocationSet(ResultsLocationSet selectedLocationSet) {
    emit(state.copyWith(selectedLocationSet: selectedLocationSet));
  }

  void setWadahSet(List<ResultTong> wadah) {
    emit(state.copyWith(wadah: wadah));
  }

  void setMaterials(List<ResultsMaterial> materials) {
    emit(state.copyWith(materials: materials));
  }

  void setStartDate() {
    var date = DateTime.now();
    var formatDate = DateFormat('yyyyMMdd-HHmmss').format(date);
    emit(state.copyWith(startTime: formatDate));
  }

  void setStartDateByString(String startDate) {
    emit(state.copyWith(startTime: startDate));
  }

  void setTongActivity(String activityWh) {
    emit(state.copyWith(tong: activityWh));
  }

  void SetMixing(bool isMixing) {
    emit(state.copyWith(isMixing: isMixing));
  }
}
