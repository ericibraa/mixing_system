import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/expired_set.dart';
import 'package:dumping_system/repository/expired_set_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'expired_set_event.dart';
part 'expired_set_state.dart';

class ExpiredSetBloc extends Bloc<ExpiredSetEvent, ExpiredSetState> {
  final ExpiredSetRepository _expiredSetRepository = ExpiredSetRepository();
  ExpiredSetBloc() : super(ExpiredSetInitial()) {
    on<GetExpiredSet>((event, emit) async {
      emit(ExpiredSetLoading());
      try {
        final expiredSet = await _expiredSetRepository.fetchExpiredSet(
            event.orderNo, event.activityNo);
        emit(ExpiredSetLoaded(expiredSet: expiredSet));
      } catch (e) {
        emit(ExpiredSetError());
      }
    });
  }
}
