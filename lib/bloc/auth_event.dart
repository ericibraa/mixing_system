part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class ChangeAuthStatus extends AuthEvent {
  final String token;

  const ChangeAuthStatus({required this.token});

  @override
  List<Object> get props => [token];
}

class ChangeUserEvent extends AuthEvent {
  final String? nrpOperator;
  final String? nrpPengawas;
  final String? weerks;

  const ChangeUserEvent({this.nrpOperator, this.nrpPengawas, this.weerks});

  @override
  List<Object> get props =>
      [nrpOperator ?? '', nrpPengawas ?? '', weerks ?? ''];
}

class DeleteUserEvent extends AuthEvent {}

class InitAuth extends AuthEvent {}
