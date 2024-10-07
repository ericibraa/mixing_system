class MaterialResponse {
  D? d;

  MaterialResponse({this.d});

  MaterialResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? new D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultsMaterial>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultsMaterial>[];
      json['results'].forEach((v) {
        results!.add(new ResultsMaterial.fromJson(v));
      });
    }
  }
}

class ResultsMaterial {
  Metadata? mMetadata;
  String? plant;
  String? material;
  String? materialDesc;

  ResultsMaterial(
      {this.mMetadata, this.plant, this.material, this.materialDesc});

  ResultsMaterial.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? new Metadata.fromJson(json['__metadata'])
        : null;
    plant = json['Plant'];
    material = json['Material'];
    materialDesc = json['Material_Desc'];
  }
}

class Metadata {
  String? id;
  String? uri;
  String? type;

  Metadata({this.id, this.uri, this.type});

  Metadata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uri = json['uri'];
    type = json['type'];
  }
}
