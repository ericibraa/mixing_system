part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class ChangeAuthStatus extends AuthEvent {
  final String token;
  final String csrfToken;
  final String? username;

  const ChangeAuthStatus({required this.token, required this.csrfToken, this.username});

  @override
  List<Object> get props => [token, csrfToken];
}

class ChangeUserEvent extends AuthEvent {
  final String? nrpOperator;
  final String? nrpPengawas;
  final String? nameOperator;
  final String? namePengawas;
  final String? weerks;

  const ChangeUserEvent(
      {this.nrpOperator,
      this.nrpPengawas,
      this.nameOperator,
      this.namePengawas,
      this.weerks});

  @override
  List<Object> get props => [
        nrpOperator ?? '',
        nrpPengawas ?? '',
        nameOperator ?? '',
        namePengawas ?? '',
        weerks ?? ''
      ];
}

class DeleteUserEvent extends AuthEvent {}

class InitAuth extends AuthEvent {}
