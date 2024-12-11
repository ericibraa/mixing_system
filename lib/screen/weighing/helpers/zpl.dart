import 'package:intl/intl.dart';

class ZplData {
  final String materialCode;
  final String materialDesc;
  final String batchFG;
  final String orderNo;
  final String line;
  final String equipmentDesc;
  final String workCenterDesc;
  final String operationType;
  final String operationDesc;
  final String lot;
  final String operator;
  final String pengawas;
  final String stagingTime;
  final String totalContainer;
  final String containerConter;
  final double bruto;
  final double tara;
  final double netto;
  final String unit;
  final String expiredNo;
  final String expiredUnit;
  final String startWork;
  final String activityWh;
  final String activityNo;

  const ZplData(
      {required this.materialCode,
      required this.materialDesc,
      required this.batchFG,
      required this.orderNo,
      required this.line,
      required this.equipmentDesc,
      required this.workCenterDesc,
      required this.operationType,
      required this.operationDesc,
      required this.lot,
      required this.operator,
      required this.pengawas,
      required this.stagingTime,
      required this.totalContainer,
      required this.containerConter,
      required this.bruto,
      required this.tara,
      required this.netto,
      required this.unit,
      required this.expiredNo,
      required this.expiredUnit,
      required this.startWork,
      required this.activityWh,
      required this.activityNo});

  String Formatted(double value) {
    var currencyFormatter = NumberFormat.currency(
      locale: 'id-ID',
      symbol: '',
      decimalDigits: 2,
    );
    return currencyFormatter.format(value);
  }

  String getZpl() {
    return '''
          ^XA
          ^PW560                           ; Set print width for portrait A7 (560 dots, approximately 74mm)
          ^LL800 
          ^CFQ
          ^FO10,25^GB550,765,2^FS      ; Full border around the label
          ^FO30,40^GFA,357,357,7,,::00JF3IFC,007IF3IF8,003IF3IF,001IF3FFE,K033,::0JFI3IFC,07IFI3IFC,07IFI3IF8,03IFI3IF,01IFI3FFE,J0J3,::7IFJ31IFC,7IFK3IFC,7IFK3IF8,3IFK3IF,1IFK3IF,1IFK3FFE,I0L3,::::::::::::::::::::::,:::^FS      ; Logo
          ^FO0,55^A0N,30^FB570,,,C^FDPRODUK DALAM PROSES^FS     ; Title 
          ^FO30,110^FDProduct^FS
          ^FO200,110^FD$materialCode^FS       ; Product code
          ^FO28,145^A0N,30 ^FB355,2,5,L^FD$materialDesc^FS     ; Product name
          ^FO28,215^A0N,30^FDBatch^FS
          ^FO200,215^A0N,30^FD$batchFG^FS        ; Batch number
          ^FO30,250^FDPrO^FS
          ^FO200,250^FD$orderNo^FS      ; PrO number
          ^FO30,280^FDLine^FS
          ^FO200,280^FD$line^FS         ; Line number
          ^FO30,310^FDScale^FS
          ^FO200,310^FD$equipmentDesc^FS       ; Scale information
          ^FO30,340^FDMachine^FS
          ^FO200,345^FB350,2,5,L^FD$workCenterDesc^FS      ; Machine info
          ^FO30,390^FDOperation/Lot^FS
          ^FO200,390^FD${operationType == 'DECOCT' ? '$operationDesc / $lot' : lot.isNotEmpty ? '$operationDesc / $lot' : operationDesc}^FS       ; Operation/lot
          ^FO30,420^FDOperator/PWS^FS
          ^FO200,420^FD$operator/$pengawas^FS             ; Operator/PWS info
          ^FO30,450^FDWeighing Time^FS
          ^FO200,450^FD$startWork^FS        ; Date and time
          ^FO30,480^FD${expiredNo != '0,000' ? 'Staging Time' : ''}^FS
          ^FO200,480^FD$stagingTime^FS       ; Holding time
          ^FO30,510^A0N,26^FD$operationType^FS          ; CB label
          ^FO395,114^FB200,,,R^BQN,2,4^FDQA,$orderNo;$materialCode;$activityNo;$operationType;${Formatted(netto)};${int.parse(containerConter)}/${int.parse(totalContainer)};$activityWh^FS          ; QR code at top right
          ^FO470,560^FDJumlah^FS
          ^FO495,745^FD${int.parse(containerConter)}/${int.parse(totalContainer)}^FS        ; Page number
          ^CF0,30       
          ^FO30,595^FDBruto^FS                   ; "Nett" label
          ^FO290,595^FB180,,,R^FD${Formatted(bruto)}^FS          ; Aligned value
          ^FO330,595^FB200,,,R^FD$unit^FS                    ; Aligned unit
          ^FO30,635^FDTara^FS                   ; "Nett" label
          ^FO290,635^FB180,,,R^FD${Formatted(tara)}^FS           ; Aligned value
          ^FO330,635^FB200,,,R^FD$unit^FS                    ; Aligned unit
          ^FO30,675^FDNetto^FS                   ; "Nett" label
          ^FO290,675^FB180,,,R^FD${Formatted(netto)}^FS         ; Aligned value
          ^FO330,675^FB200,,,R^FD$unit^FS                    ; Aligned unit
          ^XZ
        ''';
  }
}
