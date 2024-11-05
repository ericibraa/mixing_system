import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/result_scale.dart';
import 'package:dumping_system/repository/result_scale_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'result_scale_event.dart';
part 'result_scale_state.dart';

class ResultScaleBloc extends Bloc<ResultScaleEvent, ResultScaleState> {
  final ResultScaleRepository _resultScaleRepository = ResultScaleRepository();
  ResultScaleBloc() : super(ResultScaleInitial()) {
    on<SendDataResultScale>((event, emit) async {
      emit(ResultScaleLoading());
      try {
        final resultScale = await _resultScaleRepository.fetchresultscale(
            event.orderNo, event.activityNo, event.activityWh);
        emit(ResultScaleLoaded(resultScale: resultScale));
      } catch (e) {
        emit(ResultScaleError());
      }
    });
  }
}
