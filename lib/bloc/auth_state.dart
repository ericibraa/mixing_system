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

  const Authenticated(
      {required this.token,
      this.nrpOperator = '',
      this.nrpPengawas = '',
      this.weerks = ''});

  Authenticated copyWith({
    String? token,
    String? nrpOperator,
    String? nrpPengawas,
    String? weerks,
  }) {
    return Authenticated(
        token: token ?? this.token,
        nrpOperator: nrpOperator ?? this.nrpOperator,
        nrpPengawas: nrpPengawas ?? this.nrpPengawas,
        weerks: weerks ?? this.weerks);
  }

  @override
  List<Object> get props => [token, nrpOperator, nrpPengawas, weerks];
}

class Unauthenticated extends AuthState {}
