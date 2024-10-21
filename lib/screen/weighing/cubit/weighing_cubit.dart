import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'weighing_state.dart';

class WeighingCubit extends Cubit<WeighingState> {
  WeighingCubit() : super(WeighingState());

  void setDataOrder(
    String plant,
    String materialCode,
    String date,
  ) {
    emit(state.copyWith(
      plant: plant,
      materialCode: materialCode,
      date: date,
    ));
  }

  void setTab(WeighingStatus tab) {
    emit(state.copyWith(tab: tab));
  }
}
