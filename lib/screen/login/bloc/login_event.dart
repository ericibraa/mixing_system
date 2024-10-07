part of 'login_bloc.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class SendLoginData extends LoginEvent {
  final String username;
  final String password;

  const SendLoginData({required this.username, required this.password});
  @override
  List<Object> get props => [username, password];
}
