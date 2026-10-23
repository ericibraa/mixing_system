import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/scale.dart';
import 'package:dumping_system/repository/scale_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'scale_event.dart';
part 'scale_state.dart';

class ScaleBloc extends Bloc<ScaleEvent, ScaleState> {
  final ScaleRepository _scaleRepository = ScaleRepository();
  ScaleBloc() : super(ScaleInitial()) {
    on<SendDataScale>((event, emit) async {
      emit(ScaleLoading());
      try {
        final scale = await _scaleRepository.fetchscale(event.plant);
        emit(ScaleLoaded(scale: scale));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(ScaleError(e.error!.message!.value!));
        } else {
          emit(const ScaleError('Server Error'));
        }
      }
    });
  }
}
