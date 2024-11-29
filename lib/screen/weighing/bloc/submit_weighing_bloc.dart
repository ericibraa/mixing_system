import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/submit_weighing.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/submit_weighing._repository.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:zsdk/zsdk.dart';

part 'submit_weighing_event.dart';
part 'submit_weighing_state.dart';

class SubmitWeighingBloc
    extends Bloc<SubmitWeighingEvent, SubmitWeighingState> {
  final SubmitWeighingRepository _submitWeighingRepository =
      SubmitWeighingRepository();
  SubmitWeighingBloc() : super(SubmitWeighingInitial()) {
    on<SendDataWeighing>((event, emit) async {
      emit(SubmitWeighingLoading());
      try {
        DateTime finishTimeWeighing = DateTime.now();
        DateTime? expiredDateParse;
        String finalExpDate = '';
        String finalExpTime = '';
        String lotNo = '';
        if (event.weighingState.operationType == 'DECOCT') {
          lotNo = event.weighingState.scaleWeighing.lot;
        }
        if (event.weighingState.expiredSet.expiredNo != '0,000') {
          if (event.weighingState.expiredSet.unit == 'DAY') {
            expiredDateParse = finishTimeWeighing.add(Duration(
                days: int.parse(event.weighingState.expiredSet.expiredNo!)));
            finalExpDate = DateFormat('yyyyMMdd').format(expiredDateParse);
          } else {
            expiredDateParse = finishTimeWeighing.add(Duration(
                hours: int.parse(event.weighingState.expiredSet.expiredNo!)));
            finalExpTime = DateFormat('HHmmss').format(expiredDateParse);
          }
        }
        SubmitWeighing submitWeighing = SubmitWeighing(
            orderNo: event.weighingState.selectedOrder.orderNo,
            activityNo: event.weighingState.selectedOperation.activityNo,
            equipmentNo: event.weighingState.selectedEquipment.equipmentNo,
            resource: event.weighingState.expiredSet.workCenter,
            activityWh: event.weighingState.selectedContainer.activityWh,
            bruto: event.weighingState.scaleWeighing.bruto.toString(),
            tara: event.weighingState.scaleWeighing.tara.toString(),
            netto: event.weighingState.scaleWeighing.netto.toStringAsFixed(1),
            unitWeighing: event.weighingState.scaleWeighing.unit,
            temperature: event.weighingState.scaleWeighing.temperature,
            unitTemperature: "GC",
            moistureContent: event.weighingState.scaleWeighing.moistureContent,
            unitMoisture: "%",
            expiredDate: finalExpDate,
            expiredTime: finalExpTime,
            operator: event.weighingState.operator,
            pengawas: event.weighingState.pengawas,
            startDate:
                DateFormat('yyyyMMdd').format(event.weighingState.startWork!),
            startTime:
                DateFormat('HHmmss').format(event.weighingState.startWork!),
            wadah: event.weighingState.containerCounter.toString(),
            totalWadah: event.weighingState.scaleWeighing.numberOfContainer,
            line: event.weighingState.line,
            finishDate: DateFormat('yyyyMMdd').format(finishTimeWeighing),
            finishTime: DateFormat('HHmmss').format(finishTimeWeighing),
            lotNo: lotNo);

        String weighing =
            await _submitWeighingRepository.submitweighing(submitWeighing);

        final zsdk = ZSDK();
        String zplData = '''
         ^XA
          ^PW560                           ; Set print width for portrait A7 (560 dots, approximately 74mm)
          ^LL800 
          ^FO10,25^GB550,765,2^FS      ; Full border around the label
          ^CF0, 22    ; General font
          ^FO30,40^GFA,357,357,7,,::00JF3IFC,007IF3IF8,003IF3IF,001IF3FFE,K033,::0JFI3IFC,07IFI3IFC,07IFI3IF8,03IFI3IF,01IFI3FFE,J0J3,::7IFJ31IFC,7IFK3IFC,7IFK3IF8,3IFK3IF,1IFK3IF,1IFK3FFE,I0L3,::::::::::::::::::::::,:::^FS      ; Logo
          ^FO0,55 ^FB570,,,C ^A0N,30^FDPRODUK DALAM PROSES^FS     ; Title 
          ^FO30,110^FDProduct^FS
          ^FO200,110^FD${event.weighingState.materialCode}^FS       ; Product code
          ^FO28,145 ^FB355,2,,L^A0N,30^FD${event.weighingState.resultsOpr.materialDesc}^FS     ; Product name
          ^FO28,215^A0N,30^FDBatch^FS
          ^FO200,215^A0N,30^FD${event.weighingState.selectedOrder.batchFG}^FS        ; Batch number
          ^FO30,250 ^FDPrO^FS
          ^FO200,250^FD${event.weighingState.selectedOrder.orderNo}^FS      ; PrO number
          ^FO30,280^FDLine^FS
          ^FO200,280^FD${event.weighingState.line}^FS         ; Line number
          ^FO30,310^FDScale^FS
          ^FO200,310^FD${event.weighingState.selectedEquipment.equipmentDesc}^FS       ; Scale information
          ^FO30,340^FDMesin^FS
          ^FO200,340^FD${event.weighingState.expiredSet.workCenterDesc}^FS      ; Machine info
          ^FO30,370^FDOperation/Lot^FS
          ^FO200,370^FD${event.weighingState.operationType == 'DECOCT' ? '${event.weighingState.selectedOperation.operationDesc} / $lotNo' : event.weighingState.selectedContainer.lot!.isNotEmpty ? '${event.weighingState.selectedOperation.operationDesc} / ${event.weighingState.selectedContainer.lot}' : '${event.weighingState.selectedOperation.operationDesc}'}^FS       ; Operation/lot
          ^FO30,400^FDOperator/PWS^FS
          ^FO200,400^FD${event.weighingState.operator}/${event.weighingState.pengawas}^FS             ; Operator/PWS info
          ^FO30,430^FDTgl. Timbang^FS
          ^FO200,430^FD${DateFormat('dd.MM.yyyy HH:mm:ss').format(event.weighingState.startWork!)}^FS        ; Date and time
          ^FO30,460^FD${event.weighingState.expiredSet.expiredNo != '0,000' ? 'Staging Time' : ''}^FS
          ^FO200,460^FD${event.weighingState.expiredSet.expiredNo != '0,000' ? DateFormat('dd.MM.yyyy HH:mm:ss').format(expiredDateParse!) : ''}^FS       ; Holding time
          ^FO30,490^A0N,30^FD${event.weighingState.operationType}^FS          ; CB label
          ^FO395,114 ^FB200,,,R^BQN,2,4^FDQA,${event.weighingState.selectedOrder.orderNo};${event.weighingState.materialCode};${event.weighingState.selectedOperation.activityNo};${event.weighingState.operationType};${double.parse(event.weighingState.scaleWeighing.netto.toStringAsFixed(2))};${int.parse(int.parse(event.weighingState.containerCounter.toString()).toString())}/${int.parse(event.weighingState.totalContainer).toString()};${event.weighingState.selectedContainer.activityWh}^FS          ; QR code at top right
          ^FO470,540^A0N,20,20^FDJumlah^FS       
          ^FO30,575^FDBruto^FS                   ; "Nett" label
          ^FO290,575 ^FB200,,,R^FD${double.parse(event.weighingState.scaleWeighing.bruto.toStringAsFixed(2))}^FS          ; Aligned value
          ^FO330,575 ^FB200,,,R^FD${event.weighingState.scaleWeighing.unit}^FS                    ; Aligned unit
          ^FO30,610^FDTara^FS                   ; "Nett" label
          ^FO290,610 ^FB200,,,R^FD${double.parse(event.weighingState.scaleWeighing.tara.toStringAsFixed(2))}^FS           ; Aligned value
          ^FO330,610 ^FB200,,,R^FD${event.weighingState.scaleWeighing.unit}^FS                    ; Aligned unit
          ^FO30,645^FDNetto^FS                   ; "Nett" label
          ^FO290,645 ^FB200,,,R^FD${double.parse(event.weighingState.scaleWeighing.netto.toStringAsFixed(2))}^FS         ; Aligned value
          ^FO330,645 ^FB200,,,R^FD${event.weighingState.scaleWeighing.unit}^FS                    ; Aligned unit
          ^FO485,755^FD${int.parse(int.parse(event.weighingState.containerCounter.toString()).toString())}/${int.parse(event.weighingState.totalContainer).toString()}^FS        ; Page number^FS        ; Page number
          ^XZ
        ''';
        await zsdk
            .printZplDataOverTCPIP(
                address: event.weighingState.selectedEquipment.ipPrinter,
                port: 9100,
                data: zplData)
            .then((value) {
          final printerResponse = PrinterResponse.fromMap(value);
          Status status = printerResponse.statusInfo.status;
          print(status);
          if (printerResponse.errorCode == ErrorCode.SUCCESS) {
            print("printer connect");
            emit(SubmitWeighingSuccess(
                submitWeighing: weighing, isPrinted: true));
          } else {
            emit(SubmitWeighingSuccess(
                submitWeighing: weighing, isPrinted: false));
            Cause cause = printerResponse.statusInfo.cause;
            print(cause);
          }
        });
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(SubmitWeighingError(e.error!.message!.value!));
        } else {
          emit(const SubmitWeighingError('Server Error'));
        }
      }
    });
  }
}
