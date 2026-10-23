class Volume {
  D? d;

  Volume({this.d});

  Volume.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? D.fromJson(json['d']) : null;
  }
}

class D {
  List<ResultVolume>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ResultVolume>[];
      json['results'].forEach((v) {
        results!.add( ResultVolume.fromJson(v));
      });
    }
  }
}

class ResultVolume {
  String? plant;
  String? item;
  String? volume;
  String? unit;

  ResultVolume({this.plant, this.item, this.volume, this.unit});

  ResultVolume.fromJson(Map<String, dynamic> json) {
    plant = json['Plant'];
    item = json['Item'];
    volume = json['Volume'];
    unit = json['Unit'];
  }
}
