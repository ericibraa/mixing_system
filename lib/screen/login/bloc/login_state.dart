part of 'login_bloc.dart';

@immutable
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final String token;
  final String csrfToken;
  final String username;

  const LoginSuccess(this.token, this.csrfToken, this.username);

  @override
  List<Object> get props => [token, csrfToken, username];
}

final class LoginError extends LoginState {}
