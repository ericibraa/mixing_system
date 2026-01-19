import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/yield_set.dart';
import 'package:dumping_system/repository/yield_set_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'yield_set_event.dart';
part 'yield_set_state.dart';

class YieldSetBloc extends Bloc<YieldSetEvent, YieldSetState> {
  final YieldSetRepository _yieldSetRepository = YieldSetRepository();
  YieldSetBloc() : super(YieldSetInitial()) {
    on<GetYieldSet>((event, emit) async {
      emit(YieldSetLoading());
      try {
        final yieldSet = await _yieldSetRepository.fetchYieldSet(
            event.routingNo, event.internalCntr, event.activityNo);
        emit(YieldSetSuccess(yieldSet));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(YieldSetError(e.error!.message!.value!));
        } else {
          emit(const YieldSetError('Server Error'));
        }
      }
    });
  }
}
