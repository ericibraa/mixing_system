import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/repository/weighing_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'weighing_event.dart';
part 'weighing_state.dart';

class WeighingBloc extends Bloc<WeighingEvent, WeighingBlocState> {
  final WeighingRepository _weighingRepository = WeighingRepository();
  WeighingBloc() : super(WeighingInitial()) {
    on<SendDataWeighing>((event, emit) async {
      emit(WeighingLoading());
      try {
        final weighing = await _weighingRepository.fetchweighing(
            event.routingNo,
            event.internalCntr,
            event.activityNo,
            event.operationType,
            event.operationApps);
        emit(WeighingLoaded(weighing: weighing));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(WeighingErros(e.error!.message!.value!));
        } else {
          emit(const WeighingErros('Server Error'));
        }
      }
    });
  }
}
