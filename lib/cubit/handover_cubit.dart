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

  void setScannedTong(List<String> activityNo) {
    emit(state.copyWith(
        isLoadingTong: true,
        isLoadingFullpack: true,
        isLoadingMaterialset: true));
    var tongs = state.tongs;
    var fullpack = state.fullpack;
    var materialSets = state.materialSet;
    var line = state.line;
    var completed = tongs.where((tong) => tong.isScanned == true).length;
    var completedFullpack =
        fullpack.where((pack) => pack.isScannedFullpack == true).length;
    var completedMaterialset =
        materialSets.where((material) => material.scanFlag == 'X').length;
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
    print("_---------------------");
    print(unscannedPriorities);
    print(lowestUnscannedPriority);
    switch (activityNo.length) {
      case 4:
        for (var i = 0; i < tongs.length; i++) {
          if (tongs[i].activityNo == activityNo[3]) {
            matchFound = true;
            if (tongs[i].isScanned!) {
              isChecked = true;
            } else {
              var tong = tongs[i].copyWith(isScanned: true);
              completed++;
              tongs[i] = tong;
            }
            isNullData = !matchFound;
          }
        }
        break;
      case 5:
        for (var i = 0; i < tongs.length; i++) {
          if (tongs[i].activityNo == activityNo[3]) {
            matchFound = true;
            if (tongs[i].isScanned!) {
              isChecked = true;
            } else {
              var tong = tongs[i].copyWith(isScanned: true);
              tongs[i] = tong;
              completed++;
            }
          }
          isNullData = !matchFound;
        }
        break;
      case 7:
        for (var j = 0; j < fullpack.length; j++) {
          if (fullpack[j].recipient != 'F') {
            print("------");
            if (fullpack[j].bOMItem == activityNo[3] &&
                fullpack[j].counter == activityNo[6]) {
              matchFound = true;
              if (fullpack[j].isScannedFullpack) {
                isChecked = true;
              } else {
                var fullpacks = fullpack[j]
                    .copyWith(isScannedFullpack: true, scanFlag: 'X');
                completedFullpack++;
                fullpack[j] = fullpacks;
              }
              isNullData = !matchFound;
            }
          } else {
            print("Test7 ++");
            print(materialSets.toList());
            for (var k = 0; k < materialSets.length; k++) {
              // if (materialSets[k].counter == activityNo[5] &&
              //     materialSets[k].priority == lowestUnscannedPriority) {
              //   matchFound = true;
              //   print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
              //   print(materialSets[k]);
              //   if (materialSets[k].isScanned) {
              //     isChecked = true;
              //   } else {
              //     print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
              //     var materialSet =
              //         materialSets[k].copyWith(isScanned: true, scanFlag: "X");
              //     completedMaterialset++;
              //     materialSets[k] = materialSet;
              //   }
              // }
              // isNullData = !matchFound;
              if (materialSets[k].scanFlag == "") {
                if (materialSets[k].activityNo == activityNo[2]) {
                  print("trueeeeeeeeeeeeeeeeeeee6666666666666666666666");
                  var materialSet =
                      materialSets[k].copyWith(isScanned: true, scanFlag: "X");
                  completedMaterialset++;
                  materialSets[k] = materialSet;
                } else {
                  isNullData = true;
                }

                break;
              } else if ((materialSets[k].activityNo == activityNo[2])) {
                isChecked = true;
              } else {
                isNullData = true;
              }
            }
          }
        }
        break;
      case 9:
        if (activityNo[7] == 'F' && state.tab == HandoverStatus.scantong) {
          print(activityNo[7]);
          for (var j = 0; j < fullpack.length; j++) {
            print("Lewat sini");
            if (fullpack[j].bOMItem.isNotEmpty) {
              if (fullpack[j].bOMItem == activityNo[3] &&
                  fullpack[j].counter == activityNo[6]) {
                matchFound = true;
                if (fullpack[j].isScannedFullpack) {
                  isChecked = true;
                } else {
                  var fullpacks = fullpack[j]
                      .copyWith(isScannedFullpack: true, scanFlag: 'X');
                  fullpack[j] = fullpacks;
                  completedFullpack++;
                }
              }
            } else {
              print("test9");
              if (fullpack[j].counter == activityNo[5]) {
                matchFound = true;
                if (fullpack[j].isScannedFullpack) {
                  isChecked = true;
                } else {
                  var fullpacks = fullpack[j]
                      .copyWith(isScannedFullpack: true, scanFlag: 'X');
                  fullpack[j] = fullpacks;
                  completedFullpack++;
                }
              }
            }
            isNullData = !matchFound;
          }
        } else {
          for (var k = 0; k < materialSets.length; k++) {
            print("ashdakjshdahdasdhasdj");
            var lastScan = 0;
            if (materialSets[k].scanFlag == "") {
              lastScan = int.parse(materialSets[k].priority);
              if (materialSets[k].bOMItem == activityNo[3] &&
                  materialSets[k].counter == activityNo[6]) {
                print("trueeeeeeeeeeeeeeeeeeee99999999999999999999999999");
                var materialSet =
                    materialSets[k].copyWith(isScanned: true, scanFlag: "X");
                completedMaterialset++;
                materialSets[k] = materialSet;
                isChecked = false;
                isNullData = false;
                break;
              } else if (int.parse(materialSets[k + 1].priority) > lastScan) {
                isNullData = true;
                break;
              }
            } else if ((materialSets[k].bOMItem == activityNo[3])) {
              isChecked = true;
            } else {
              lastScan = int.parse(materialSets[k].priority);
              isNullData = true;
            }
          }
          break;
        }
        break;
      case 6:
        String lastPrioEmpty = "";
        for (var k = 0; k < materialSets.length; k++) {
          // print("MAterial Set =================");
          // print(materialSets[k].priority);
          // print(lowestUnscannedPriority);
          // print(unscannedPriorities);
          // if (materialSets[k].bOMItem == activityNo[3] &&
          //     materialSets[k].counter.isEmpty &&
          //     materialSets[k].priority == lowestUnscannedPriority) {
          //   print("Lewat===================");
          //   matchFound = true;
          //   if (materialSets[k].isScanned) {
          //     isChecked = true;
          //   } else {
          //     var materialSet =
          //         materialSets[k].copyWith(isScanned: true, scanFlag: 'X');
          //     materialSets[k] = materialSet;
          //     completedMaterialset++;
          //     // emit(state.copyWith(tong: activityNo[2]));
          //   }
          // }
          // isNullData = !matchFound;

          if (materialSets[k].scanFlag == "" &&
              lastPrioEmpty == "" &&
              materialSets[k].bOMItem == activityNo[3]) {
            var materialSet =
                materialSets[k].copyWith(isScanned: true, scanFlag: "X");
            completedMaterialset++;
            materialSets[k] = materialSet;
            break;
          }

          if (materialSets[k].scanFlag == "") {
            if (lastPrioEmpty != "" &&
                lastPrioEmpty != materialSets[k].priority) {
              isNullData = true;
              break;
            }
            lastPrioEmpty = materialSets[k].priority;
            if (materialSets[k].bOMItem == activityNo[3]) {
              print("trueeeeeeeeeeeeeeeeeeee6666666666666666666666");
              var materialSet =
                  materialSets[k].copyWith(isScanned: true, scanFlag: "X");
              completedMaterialset++;
              materialSets[k] = materialSet;
              break;
            } else if (k != materialSets.length &&
                int.parse(materialSets[k + 1].priority) >
                    int.parse(materialSets[k].priority)) {
              print("mat--------------------------------+1");
              isNullData = true;
              lastPrioEmpty = "";
              break;
            }
          } else if ((materialSets[k].bOMItem == activityNo[3])) {
            isChecked = true;
            if (k != materialSets.length - 1 &&
                int.parse(materialSets[k + 1].priority) >
                    int.parse(materialSets[k].priority)) {
              lastPrioEmpty = "";
              break;
            }
          } else {
            isNullData = true;
          }
        }
        break;
      case 1:
        line = activityNo[0];
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
    print("00000000000000000000000000000000000000000000000000000");
    print(materialSets);
    emit(state.copyWith(
        tongs: tongs,
        fullpack: fullpack,
        materialSet: materialSets,
        line: line,
        isLoadingTong: false,
        isLoadingFullpack: false,
        isLoadingMaterialset: false,
        isComplete: isCompleted && isCompletedFullpack,
        isCompleteTong:
            isCompleted && isCompletedFullpack && isCompletedMaterial,
        isCompleteMaterials: isCompletedMaterial && completedMaterialset != 0,
        isCompleteWeighingResults: isCompletedFullpack,
        startDate: formattedDate,
        isChecked: isChecked,
        isNullData: isNullData));
  }

  void resetFullpackWadah() {
    emit(state.copyWith(
        tongs: [], fullpack: [], isComplete: false, isCompleteTong: false));
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
    print("============================");
    print(formatDate);
    emit(state.copyWith(startTime: formatDate));
  }

  void setStartDateByString(String startDate) {
    emit(state.copyWith(startTime: startDate));
  }
}
