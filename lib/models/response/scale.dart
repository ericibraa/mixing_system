import 'package:equatable/equatable.dart';

class Scale extends Equatable {
  final String temperature;
  final String moistureContent;
  final String numberOfContainer;
  final String scaleName;
  final double bruto;
  final double tara;
  final double netto;
  final String unit;
  final String scaleId;
  final String urlAddress;
  final String regex;
  final String createDate;
  final String expiredDate;

  const Scale(
      {this.temperature = '',
      this.moistureContent = '',
      this.numberOfContainer = '',
      this.scaleName = '',
      this.bruto = 0.0,
      this.tara = 0.0,
      this.netto = 0.0,
      this.unit = 'g',
      this.scaleId = '',
      this.urlAddress = '',
      this.regex = '',
      this.createDate = '',
      this.expiredDate = ''});

  Scale copyWith(
      {String? temperature,
      String? moistureContent,
      String? numberOfContainer,
      String? scaleName,
      double? bruto,
      double? tara,
      double? netto,
      String? unit,
      String? scaleId,
      String? urlAddress,
      String? regex,
      String? createDate,
      String? expiredDate}) {
    return Scale(
        temperature: temperature ?? this.temperature,
        moistureContent: moistureContent ?? this.moistureContent,
        numberOfContainer: numberOfContainer ?? this.numberOfContainer,
        scaleName: scaleName ?? this.scaleName,
        bruto: bruto ?? this.bruto,
        tara: tara ?? this.tara,
        netto: netto ?? this.netto,
        unit: unit ?? this.unit,
        scaleId: scaleId ?? this.scaleId,
        urlAddress: urlAddress ?? this.urlAddress,
        regex: regex ?? this.regex,
        createDate: createDate ?? this.createDate,
        expiredDate: expiredDate ?? this.expiredDate);
  }

  @override
  List<Object?> get props => [
        temperature,
        moistureContent,
        numberOfContainer,
        scaleName,
        bruto,
        tara,
        netto,
        unit,
        scaleId,
        urlAddress,
        regex,
        createDate,
        expiredDate
      ];
}

class ScaleResponse {
  D? d;

  ScaleResponse({this.d});

  ScaleResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultScale>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultScale>[];
      json['results'].forEach((v) {
        results!.add(ResultScale.fromJson(v));
      });
    }
  }
}

class ResultScale extends Equatable {
  final String equipmentNo;
  final String equipmentDesc;
  final String plant;
  final String urlAddress;
  final String regex;

  const ResultScale(
      {this.equipmentNo = '',
      this.equipmentDesc = '',
      this.plant = '',
      this.urlAddress = '',
      this.regex = ''});

  factory ResultScale.fromJson(Map<String, dynamic> json) => ResultScale(
        equipmentNo: json['EquipmentNo'],
        equipmentDesc: json['EquipmentDesc'],
        plant: json['Plant'],
        urlAddress: json['UrlAddress'],
        regex: json['Regex'],
      );

  @override
  List<Object> get props =>
      [equipmentNo, equipmentDesc, plant, urlAddress, regex];
}
