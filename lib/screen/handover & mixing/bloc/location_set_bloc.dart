import 'package:bloc/bloc.dart';
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
      } catch (e) {
        emit(LocationSetError());
      }
    });
  }
}
