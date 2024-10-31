import 'package:equatable/equatable.dart';

class Scale extends Equatable {
  final String? temperature;
  final String? moistureContent;
  final String? numberOfContainer;
  final String? scale;
  final String? bruto;
  final String? tara;
  final String? netto;

  const Scale(
      {this.temperature = '',
      this.moistureContent = '',
      this.numberOfContainer = '',
      this.scale = '',
      this.bruto = '',
      this.tara = '',
      this.netto = ''});

  Scale copyWith({
    String? temperature,
    String? moistureContent,
    String? numberOfContainer,
    String? scale,
    String? bruto,
    String? tara,
    String? netto,
  }) {
    return Scale(
        temperature: temperature ?? this.temperature,
        moistureContent: moistureContent ?? this.moistureContent,
        numberOfContainer: numberOfContainer ?? this.numberOfContainer,
        scale: scale ?? this.scale,
        bruto: bruto ?? this.bruto,
        tara: tara ?? this.tara,
        netto: netto ?? this.netto);
  }

  @override
  List<Object?> get props => [
        temperature,
        moistureContent,
        numberOfContainer,
        scale,
        bruto,
        tara,
        netto
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

class ResultScale {
  String? equipmentNo;
  String? equipmentDesc;
  String? plant;
  String? urlAddress;
  String? regex;

  ResultScale(
      {this.equipmentNo,
      this.equipmentDesc,
      this.plant,
      this.urlAddress,
      this.regex});

  ResultScale.fromJson(Map<String, dynamic> json) {
    equipmentNo = json['EquipmentNo'];
    equipmentDesc = json['EquipmentDesc'];
    plant = json['Plant'];
    urlAddress = json['UrlAddress'];
    regex = json['Regex'];
  }
}
