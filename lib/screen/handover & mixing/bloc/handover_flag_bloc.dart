import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/handover_flag.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/handover_flag_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'handover_flag_event.dart';
part 'handover_flag_state.dart';

class HandoverFlagBloc extends Bloc<HandoverFlagEvent, HandoverFlagState> {
  final HandoverFlagRepository _handoverFlagRepository =
      HandoverFlagRepository();
  HandoverFlagBloc() : super(HandoverFlagInitial()) {
    on<FlagHandover>((event, emit) async {
      emit(HandoverFlagLoading());
      try {
        String orderNo = event.handoverFlag[0];
        String activityNo = event.handoverFlag[2];
        String activityWh = event.handoverFlag[6];
        String counter = event.handoverFlag[5];
        String originalOrder = event.originalOrder;

        HandoverFlag handoverFlag = HandoverFlag(
            orderNo: orderNo,
            activityNo: activityNo,
            activityWh: activityWh,
            counter: counter,
            originalOrder: originalOrder);
        final flag =
            await _handoverFlagRepository.fetchHandoverFlag(handoverFlag);
        emit(HandoverFlagLoaded(handoverFlag: flag));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(HandoverFlagError(e.error!.message!.value!));
        } else {
          emit(const HandoverFlagError('Server Error'));
        }
      }
    });
  }
}
