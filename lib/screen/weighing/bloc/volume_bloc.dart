import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/volume.dart';
import 'package:dumping_system/repository/volume_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'volume_event.dart';
part 'volume_state.dart';

class VolumeBloc extends Bloc<VolumeEvent, VolumeState> {
  final VolumeRepository _volumeRepository = VolumeRepository();
  VolumeBloc() : super(VolumeInitial()) {
    on<GetVolume>((event, emit) async {
      emit(VolumeLoading());
      try {
        final volume = await _volumeRepository.fetchVolume(event.plant);
        emit(VolumeLoaded(volume: volume));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(VolumeError(e.error!.message!.value!));
        } else {
          emit(const VolumeError('Server Error'));
        }
      }
    });
  }
}
