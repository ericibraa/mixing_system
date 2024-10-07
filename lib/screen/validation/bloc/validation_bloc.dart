import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/validation.dart';
import 'package:dumping_system/repository/validation_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'validation_event.dart';
part 'validation_state.dart';

class ValidationBloc extends Bloc<ValidationEvent, ValidationState> {
  final ValidationRepository _validationRepository = ValidationRepository();
  ValidationBloc() : super(ValidationInitial()) {
    on<SendValidation>((event, emit) async {
      emit(ValidationLoading());
      try {
        final validation =
            await _validationRepository.validation(event.nrp, event.title);
        emit(ValidationLoaded(validation));
      } catch (e) {
        emit(ValidationError());
      }
    });
  }
}
