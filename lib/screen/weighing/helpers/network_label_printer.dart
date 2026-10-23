import 'dart:convert';
import 'dart:io';

import 'package:dumping_system/screen/weighing/helpers/zpl.dart';
import 'package:zsdk/zsdk.dart';

enum PrinterLanguage { escpos, zpl }

class TaraPrintData {
  final String plant;
  final String dateTime;
  final String scale;
  final String operator;
  final String totalWeight;
  final String unit;

  const TaraPrintData({
    required this.plant,
    required this.dateTime,
    required this.scale,
    required this.operator,
    required this.totalWeight,
    required this.unit,
  });
}

class NetworkLabelPrinter {
  static const _printerLanguage = String.fromEnvironment(
    'WEIGHING_PRINTER_LANGUAGE',
    defaultValue: 'escpos',
  );

  final ZSDK _zsdk;

  NetworkLabelPrinter({ZSDK? zsdk}) : _zsdk = zsdk ?? ZSDK();

  PrinterLanguage languageFor(String printerType) {
    final normalized = printerType.toLowerCase();
    if (normalized.contains('zebra') || normalized.contains('zpl')) {
      return PrinterLanguage.zpl;
    }
    if (normalized.contains('epson') || normalized.contains('esc')) {
      return PrinterLanguage.escpos;
    }
    return _printerLanguage.toLowerCase() == 'zpl'
        ? PrinterLanguage.zpl
        : PrinterLanguage.escpos;
  }

  Future<bool> printWeighingLabel(
      {required String address,
      required ZplData data,
      String printerType = '',
      z}) {
    switch (languageFor(printerType)) {
      case PrinterLanguage.zpl:
        return _printZpl(address: address, data: data.getZpl());
      case PrinterLanguage.escpos:
        return _printEscPos(address: address, bytes: _weighingEscPos(data));
    }
  }

  Future<bool> printTaraLabel({
    required String address,
    required TaraPrintData data,
    String printerType = '',
  }) {
    switch (languageFor(printerType)) {
      case PrinterLanguage.zpl:
        return _printZpl(address: address, data: _taraZpl(data));
      case PrinterLanguage.escpos:
        return _printEscPos(address: address, bytes: _taraEscPos(data));
    }
  }

  Future<bool> _printZpl({
    required String address,
    required String data,
  }) async {
    final value = await _zsdk.printZplDataOverTCPIP(
      address: address,
      port: 9100,
      data: data,
    );
    final printerResponse = PrinterResponse.fromMap(value);
    return printerResponse.errorCode == ErrorCode.SUCCESS;
  }

  Future<bool> _printEscPos({
    required String address,
    required List<int> bytes,
  }) async {
    final socket = await Socket.connect(
      address,
      9100,
      timeout: const Duration(seconds: 5),
    );
    try {
      socket.add(bytes);
      await socket.flush();
      return true;
    } finally {
      await socket.close();
    }
  }

  List<int> _weighingEscPos(ZplData data) {
    final temp = data.temperatureParts;
    final operationLot = data.operationLot;
    final qrData =
        '${data.orderNo};${data.materialCode};${data.activityNo};${data.operationType};${data.formatted(data.netto)};${data.safeContainerCounter}/${data.safeTotalContainer};${data.activityWh}';

    return _escPosDocument([
      _line('PRODUK DALAM PROSES', align: _Align.center, bold: true),
      _line(''),
      _row('Product', data.materialCode),
      ..._wrap(data.materialDesc, width: 30).map((line) => _line(line)),
      _row('Batch', data.batchFG),
      _row('PrO', data.orderNo),
      _row('Line', data.line),
      _row('Scale', data.equipmentDesc),
      _row('Machine', data.workCenterDesc),
      _row('Operation/Lot', operationLot),
      _row('Oprt/Pgws', '${data.operator}/${data.pengawas}'),
      _row('Weighing Time', data.startWork),
      if (data.stagingTime.isNotEmpty && data.expiredNo != '0,000')
        _row('Staging Time', data.stagingTime),
      if (temp.start.isNotEmpty)
        _row(
          'Temperature',
          '${temp.start}${temp.end.isNotEmpty ? ' / ${temp.end}' : ''} C',
        ),
      _line(''),
      _line(data.operationType, bold: true),
      _line(''),
      _qr(qrData),
      _line(''),
      _row('', 'Jumlah', right: true),
      _row('Bruto', '${data.formatted(data.bruto)} ${data.unit}', right: true),
      _row('Tara', '${data.formatted(data.tara)} ${data.unit}', right: true),
      _row('Netto', '${data.formatted(data.netto)} ${data.unit}', right: true),
      _line(''),
      _row('', '${data.safeContainerCounter}/${data.safeTotalContainer}',
          right: true),
    ]);
  }

  List<int> _taraEscPos(TaraPrintData data) {
    return _escPosDocument([
      _line('PENIMBANGAN', align: _Align.center, bold: true),
      _line(''),
      _row('Plant', data.plant),
      _row('Datetime', data.dateTime),
      _row('Scale', data.scale),
      _row('Operator', data.operator),
      _line(''),
      _row('Total Weight', '${data.totalWeight} ${data.unit}', right: true),
    ]);
  }

  String _taraZpl(TaraPrintData data) {
    return '''
      ^XA
      ^PW560
      ^LL800
      ^CFQ
      ^FO5,220^GB550,400,2^FS
      ^FO30,240^GFA,357,357,7,,::00JF3IFC,007IF3IF8,003IF3IF,001IF3FFE,K033,::0JFI3IFC,07IFI3IFC,07IFI3IF8,03IFI3IF,01IFI3FFE,J0J3,::7IFJ31IFC,7IFK3IFC,7IFK3IF8,3IFK3IF,1IFK3IF,1IFK3FFE,I0L3,::::::::::::::::::::::,:::^FS
      ^FO0,255^A0N,30^FB570,,,C^FDPENIMBANGAN^FS
      ^FO30,320^FDPlant^FS
      ^FO200,320^FD${data.plant}^FS
      ^FO30,355^FDDatetime^FS
      ^FO200,355^FD${data.dateTime}^FS
      ^FO30,390^FDScale^FS
      ^FO200,390^FD${data.scale}^FS
      ^FO30,425^FDOperator^FS
      ^FO200,425^FD${data.operator}^FS
      ^CF0,30
      ^FO30,550^FDTotal Weight^FS
      ^FO290,550^FB180,,,R^FD${data.totalWeight}^FS
      ^FO330,550^FB200,,,R^FD${data.unit}^FS
      ^XZ
    ''';
  }

  List<int> _escPosDocument(List<List<int>> parts) {
    return [
      ..._init,
      ..._codePage,
      ..._textSize(width: 1, height: 1),
      ...parts.expand((part) => part),
      ..._feed(3),
      ..._cut,
    ];
  }

  List<int> _line(
    String value, {
    _Align align = _Align.left,
    bool bold = false,
  }) {
    return [
      ..._align(align),
      ..._bold(bold),
      ...latin1.encode(value),
      0x0a,
      ..._bold(false),
      ..._align(_Align.left),
    ];
  }

  List<int> _row(String label, String value, {bool right = false}) {
    const labelWidth = 16;
    const lineWidth = 42;
    final cleanLabel = label.length > labelWidth
        ? label.substring(0, labelWidth)
        : label.padRight(labelWidth);
    final valueWidth = lineWidth - labelWidth;
    final lines = _wrap(value, width: valueWidth);
    final output = <int>[];

    for (var i = 0; i < lines.length; i++) {
      final text = right ? lines[i].padLeft(valueWidth) : lines[i];
      output.addAll(latin1
          .encode('${i == 0 ? cleanLabel : ''.padRight(labelWidth)}$text'));
      output.add(0x0a);
    }

    return output;
  }

  List<int> _qr(String value) {
    final data = latin1.encode(value);
    final length = data.length + 3;
    final pL = length % 256;
    final pH = length ~/ 256;

    return [
      ..._align(_Align.center),
      0x1d,
      0x28,
      0x6b,
      0x04,
      0x00,
      0x31,
      0x41,
      0x32,
      0x00,
      0x1d,
      0x28,
      0x6b,
      0x03,
      0x00,
      0x31,
      0x43,
      0x05,
      0x1d,
      0x28,
      0x6b,
      0x03,
      0x00,
      0x31,
      0x45,
      0x31,
      0x1d,
      0x28,
      0x6b,
      pL,
      pH,
      0x31,
      0x50,
      0x30,
      ...data,
      0x1d,
      0x28,
      0x6b,
      0x03,
      0x00,
      0x31,
      0x51,
      0x30,
      ..._align(_Align.left),
    ];
  }

  List<String> _wrap(String value, {required int width}) {
    if (value.isEmpty) {
      return [''];
    }

    final words = value.split(RegExp(r'\s+'));
    final lines = <String>[];
    var line = '';

    for (final word in words) {
      if (line.isEmpty) {
        line = word;
      } else if ('$line $word'.length <= width) {
        line = '$line $word';
      } else {
        lines.add(line);
        line = word;
      }
    }
    if (line.isNotEmpty) {
      lines.add(line);
    }
    return lines;
  }

  List<int> get _init => [0x1b, 0x40];
  List<int> get _codePage => [0x1b, 0x74, 0x10];
  List<int> get _cut => [0x1d, 0x56, 0x42, 0x00];

  List<int> _feed(int lines) => [0x1b, 0x64, lines];
  List<int> _bold(bool enabled) => [0x1b, 0x45, enabled ? 1 : 0];
  List<int> _textSize({required int width, required int height}) =>
      [0x1d, 0x21, ((width - 1) << 4) + (height - 1)];
  List<int> _align(_Align align) => [0x1b, 0x61, align.index];
}

enum _Align {
  left,
  center,
  // ignore: unused_field
  right,
}
