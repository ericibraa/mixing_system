import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/label.dart';
import 'package:dumping_system/repository/label_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'label_event.dart';
part 'label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  final LabelRepository _labelRepository = LabelRepository();
  LabelBloc() : super(LabelInitial()) {
    on<SendDataLabel>((event, emit) async {
      emit(LabelLoading());
      try {
        final label =
            await _labelRepository.fetchlabel(event.orderNo, event.activityNo);
        emit(LabelLoaded(label: label));
      } catch (e) {
        emit(LabelError());
      }
    });
  }
}
