import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/repository/tong_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'tong_event.dart';
part 'tong_state.dart';

class TongBloc extends Bloc<TongEvent, TongState> {
  final TongRepository _tongRepository = TongRepository();
  TongBloc() : super(TongInitial()) {
    on<SendDataTong>((event, emit) async {
      emit(TongLoading());
      try {
        final tong = await _tongRepository.fetchtong(event.routingNo,
            event.activityNo, event.controlRecipe, event.operationType);
        emit(TongLoaded(tong));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(TongError(e.error!.message!.value!));
        } else {
          emit(const TongError('Server Error'));
        }
      }
    });
  }
}
