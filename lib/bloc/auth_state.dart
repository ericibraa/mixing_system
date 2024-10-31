part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthUnkwon extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  final String nrpOperator;
  final String nrpPengawas;
  final String weerks;
  final String csrfToken;
  final String nameOperator;
  final String namePengawas;

  const Authenticated(
      {required this.token,
      this.nrpOperator = '',
      this.nrpPengawas = '',
      this.weerks = '',
      this.csrfToken = '',
      this.nameOperator = '',
      this.namePengawas = ''});

  Authenticated copyWith(
      {String? token,
      String? nrpOperator,
      String? nrpPengawas,
      String? weerks,
      String? csrfToken,
      String? nameOperator,
      String? namePengawas}) {
    return Authenticated(
        token: token ?? this.token,
        nrpOperator: nrpOperator ?? this.nrpOperator,
        nrpPengawas: nrpPengawas ?? this.nrpPengawas,
        weerks: weerks ?? this.weerks,
        csrfToken: csrfToken ?? this.csrfToken,
        nameOperator: nameOperator ?? this.nameOperator,
        namePengawas: namePengawas ?? this.namePengawas);
  }

  @override
  List<Object> get props => [
        token,
        nrpOperator,
        nrpPengawas,
        weerks,
        csrfToken,
        nameOperator,
        namePengawas
      ];
}

class Unauthenticated extends AuthState {}
