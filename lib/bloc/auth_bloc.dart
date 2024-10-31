import 'package:bloc/bloc.dart';
import 'package:dumping_system/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(AuthUnkwon()) {
    on<ChangeAuthStatus>((event, emit) async {
      if (event.token != '') {
        await _authRepository.persistToken(event.token);
        await _authRepository.persistCsrfToken(event.csrfToken);
        emit(Authenticated(token: event.token));
      } else {
        emit(Unauthenticated());
      }
    });

    on<ChangeUserEvent>((event, emit) async {
      final currentState = state;
      if (currentState is Authenticated) {
        var nrpOperator = currentState.nrpOperator;
        var nrpPengawas = currentState.nrpPengawas;
        var weerks = currentState.weerks;
        if (event.nrpOperator != null) {
          currentState.copyWith(
            nrpOperator: event.nrpOperator,
            weerks: event.weerks ?? currentState.weerks,
          );
          nrpOperator = event.nrpOperator!;
          weerks = event.weerks!;
        }
        if (event.nrpPengawas != null) {
          currentState.copyWith(nrpPengawas: event.nrpPengawas);
          nrpPengawas = event.nrpPengawas!;
        }
        await _authRepository.persistUser(nrpOperator, nrpPengawas, weerks);
        emit(currentState.copyWith(
          nrpOperator: nrpOperator,
          nrpPengawas: nrpPengawas,
          weerks: weerks,
        ));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      try {
        final hasCredentials = await _authRepository.hasToken();
        await _authRepository.deleteUserData();
        emit(Authenticated(token: hasCredentials));
      } catch (error) {
        print("Error deleting user data: $error");
      }
    });

    on<InitAuth>((event, emit) async {
      try {
        final hasCredentials = await _authRepository.hasToken();
        final hasnrpOperation = await _authRepository.hasOperation();
        final hasnrpPengawas = await _authRepository.hasPengawas();
        final hasWeerks = await _authRepository.hasWeerks();
        final hasCsrfToken = await _authRepository.hasCsrfToken();
        final hasNameOperator = await _authRepository.hasNameOperator();
        final hasNamePengawas = await _authRepository.hasNamePengawas();
        print("Init has credentials = $hasCredentials");
        print("Init has operator = $hasnrpOperation");
        print("Init has pengawas = $hasnrpPengawas");
        print("Init has weerks = $hasWeerks");
        print("Init has csrf token = $hasCsrfToken");
        print("Init has name Operator = $hasNameOperator");
        print("Init has name Pengawas = $hasNamePengawas");
        if (hasCredentials == "") {
          emit(Unauthenticated());
        } else {
          await _authRepository.persistToken(hasCredentials);
          await _authRepository.persistUser(
              hasnrpOperation, hasnrpPengawas, hasWeerks);
          await _authRepository.persistCsrfToken(hasCsrfToken);
          emit(Authenticated(
              token: hasCredentials,
              nrpOperator: hasnrpOperation,
              nrpPengawas: hasnrpPengawas,
              weerks: hasWeerks,
              csrfToken: hasCsrfToken,
              nameOperator: hasNameOperator,
              namePengawas: hasNamePengawas));
        }
      } catch (error) {
        print("Error during initialization: $error");
        emit(Unauthenticated());
      }
    });
  }
}
