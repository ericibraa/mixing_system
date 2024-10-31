import 'package:bloc/bloc.dart';
import 'package:dumping_system/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _loginRepository = AuthRepository();
  LoginBloc() : super(LoginInitial()) {
    on<SendLoginData>((event, emit) async {
      emit(LoginLoading());
      try {
        final user =
            await _loginRepository.login(event.username, event.password);
        print(user);
        emit(LoginSuccess(user['token'], user['csrfToken']));
      } catch (e) {
        emit(LoginError());
      }
    });
  }
}
