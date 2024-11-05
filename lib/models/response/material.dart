class MaterialResponse {
  D? d;

  MaterialResponse({this.d});

  MaterialResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsMaterial>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsMaterial>[];
      json['results'].forEach((v) {
        results!.add(ResultsMaterial.fromJson(v));
      });
    }
  }
}

class ResultsMaterial {
  String? plant;
  String? material;
  String? materialDesc;
  String? productiSupervisor;

  ResultsMaterial(
      {this.plant, this.material, this.materialDesc, this.productiSupervisor});

  ResultsMaterial.fromJson(Map<String, dynamic> json) {
    plant = json['Plant'];
    material = json['Material'];
    materialDesc = json['Material_Desc'];
    productiSupervisor = json['ProductiSupervisor'];
  }
}
