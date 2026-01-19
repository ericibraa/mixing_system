import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/locationset.dart';
import 'package:dumping_system/repository/location_set_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'location_set_event.dart';
part 'location_set_state.dart';

class LocationSetBloc extends Bloc<LocationSetEvent, LocationSetState> {
  final LocationSetRepository _locationSetRepository = LocationSetRepository();
  LocationSetBloc() : super(LocationSetInitial()) {
    on<GetLocationSet>((event, emit) async {
      emit(LocationSetInitial());
      try {
        final locationSet = await _locationSetRepository.fetchLocationSet(
            event.routingNo, event.internalCntr, event.activityNo);
        emit(LocationSetLoaded(locationSet));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(LocationSetError(e.error!.message!.value!));
        } else {
          emit(const LocationSetError('Server Error'));
        }
      }
    });
  }
}
