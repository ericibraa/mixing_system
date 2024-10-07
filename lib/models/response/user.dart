import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String nrpOperator;
  final String nrpPengawas;
  final String weerks;

  const User({this.nrpOperator = '', this.nrpPengawas = '', this.weerks = ''});

  @override
  List<Object> get props => [nrpOperator, nrpPengawas, weerks];

  User copyWith({String? nrpOperator, String? nrpPengawas, String? weerks}) {
    return User(
        nrpOperator: nrpOperator ?? this.nrpPengawas,
        nrpPengawas: nrpPengawas ?? this.nrpPengawas,
        weerks: weerks ?? this.weerks);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        nrpOperator: json['nrp'],
        nrpPengawas: json['nrp'],
        weerks: json['weerks']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nrp'] = nrpOperator;
    data['nrp'] = nrpPengawas;
    data['weerks'] = weerks;
    return data;
  }
}
