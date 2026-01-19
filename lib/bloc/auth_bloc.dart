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
        await _authRepository.persistPlantUsername(event.username ?? '');
        final hasPlantUsername = await _authRepository.hasPlantUsername();
        emit(
            Authenticated(token: event.token, plantUsername: hasPlantUsername));
      } else {
        emit(Unauthenticated());
      }
    });

    on<ChangeUserEvent>((event, emit) async {
      final currentState = state;
      if (currentState is Authenticated) {
        var nrpOperator = currentState.nrpOperator;
        var nrpPengawas = currentState.nrpPengawas;
        var nameOperator = currentState.nameOperator;
        var namePengawas = currentState.namePengawas;
        var weerks = currentState.weerks;
        if (event.nrpOperator != null) {
          currentState.copyWith(
            nrpOperator: event.nrpOperator,
            nameOperator: event.nameOperator,
            weerks: event.weerks ?? currentState.weerks,
          );
          nrpOperator = event.nrpOperator!;
          nameOperator = event.nameOperator != null ? event.nameOperator! : '';
          weerks = event.weerks!;
        }
        if (event.nrpPengawas != null) {
          currentState.copyWith(
            nrpPengawas: event.nrpPengawas,
            namePengawas: event.namePengawas,
            weerks: event.weerks ?? currentState.weerks,
          );
          nrpPengawas = event.nrpPengawas!;
          namePengawas = event.namePengawas != null ? event.namePengawas! : '';
          weerks = event.weerks!;
        }
        await _authRepository.persistUser(
            nrpOperator, nrpPengawas, nameOperator, namePengawas, weerks);
        emit(currentState.copyWith(
          nrpOperator: nrpOperator,
          nrpPengawas: nrpPengawas,
          nameOperator: nameOperator,
          namePengawas: namePengawas,
          weerks: weerks,
        ));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      try {
        final hasCredentials = await _authRepository.hasToken();
        final hasPlantUsername = await _authRepository.hasPlantUsername();
        await _authRepository.deleteUserData();
        emit(Authenticated(
            token: hasCredentials, plantUsername: hasPlantUsername));
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
        final hasPlantUsername = await _authRepository.hasPlantUsername();
        print("Init has credentials = $hasCredentials");
        print("Init has operator = $hasnrpOperation");
        print("Init has pengawas = $hasnrpPengawas");
        print("Init has weerks = $hasWeerks");
        print("Init has csrf token = $hasCsrfToken");
        print("Init has name Operator = $hasNameOperator");
        print("Init has name Pengawas = $hasNamePengawas");
        print("Init has plant username = $hasPlantUsername");
        if (hasCredentials == "") {
          emit(Unauthenticated());
        } else {
          await _authRepository.persistToken(hasCredentials);
          await _authRepository.persistUser(hasnrpOperation, hasnrpPengawas,
              hasNameOperator, hasNamePengawas, hasWeerks);
          await _authRepository.persistCsrfToken(hasCsrfToken);
          await _authRepository.persistPlantUsername(hasPlantUsername);
          emit(Authenticated(
              token: hasCredentials,
              nrpOperator: hasnrpOperation,
              nrpPengawas: hasnrpPengawas,
              weerks: hasWeerks,
              csrfToken: hasCsrfToken,
              nameOperator: hasNameOperator,
              namePengawas: hasNamePengawas,
              plantUsername: hasPlantUsername));
        }
      } catch (error) {
        print("Error during initialization: $error");
        emit(Unauthenticated());
      }
    });
  }
}
