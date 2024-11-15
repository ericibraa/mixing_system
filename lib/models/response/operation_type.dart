import 'package:equatable/equatable.dart';

class OperationTypeResponse {
  D? d;

  OperationTypeResponse({this.d});

  OperationTypeResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsOperationType>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsOperationType>[];
      json['results'].forEach((v) {
        results!.add(ResultsOperationType.fromJson(v));
      });
    }
  }
}

class ResultsOperationType extends Equatable {
  final String? plant;
  final String? material;
  final String? materialDesc;
  final String? startDate;
  final OprTypToDescNav? oprTypToDescNav;

  const ResultsOperationType(
      {this.plant,
      this.material,
      this.materialDesc,
      this.startDate,
      this.oprTypToDescNav});

  factory ResultsOperationType.fromJson(Map<String, dynamic> json) =>
      ResultsOperationType(
        plant: json['Plant'],
        material: json['Material'],
        materialDesc: json['Material_Desc'],
        startDate: json['StartDate'],
        oprTypToDescNav: json['OprTypToDescNav'] != null
            ? OprTypToDescNav.fromJson(json['OprTypToDescNav'])
            : null,
      );
  @override
  List<Object?> get props =>
      [plant, material, materialDesc, startDate, oprTypToDescNav];
}

class OprTypToDescNav {
  List<ResultsOprType>? resultsOprType;

  OprTypToDescNav({this.resultsOprType});

  OprTypToDescNav.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      resultsOprType = <ResultsOprType>[];
      json['results'].forEach((v) {
        resultsOprType!.add(ResultsOprType.fromJson(v));
      });
    }
  }
}

class ResultsOprType extends Equatable {
  final String? plant;
  final String? operationType;

  const ResultsOprType({this.plant, this.operationType});

  factory ResultsOprType.fromJson(Map<String, dynamic> json) => ResultsOprType(
      plant: json['Plant'], operationType: json['OperationType']);
  @override
  List<Object?> get props => [plant, operationType];
}
