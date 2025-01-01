import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/repository/result_scale2_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'result_scale_2_event.dart';
part 'result_scale_2_state.dart';

class ResultScale2Bloc extends Bloc<ResultScale2Event, ResultScale2State> {
  final ResultScale2Repository _resultScale2Repository =
      ResultScale2Repository();
  ResultScale2Bloc() : super(ResultScale2Initial()) {
    on<SendDataResultScale2>((event, emit) async {
      emit(ResultScale2Loading());
      try {
        final resultScale2 = await _resultScale2Repository.fetchresultscale2(
            event.orderNo,
            event.activityNo,
            event.activityWh,
            event.objectName);
        emit(ResultScale2Loaded(resultScale2: resultScale2));
      } catch (e) {
        emit(ResultScale2Error());
      }
    });
  }
}
