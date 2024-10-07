class ValidationResponse {
  D? d;

  ValidationResponse({this.d});

  ValidationResponse.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<Results>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }
}

class Results {
  Metadata? mMetadata;
  String? nrp;
  String? title;
  String? werks;

  Results({this.mMetadata, this.nrp, this.title, this.werks});

  Results.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? Metadata.fromJson(json['__metadata'])
        : null;
    nrp = json['Nrp'];
    title = json['Title'];
    werks = json['Werks'];
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
