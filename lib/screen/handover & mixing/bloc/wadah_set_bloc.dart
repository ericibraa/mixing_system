import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/tong.dart';
import 'package:dumping_system/repository/wadah_set_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'wadah_set_event.dart';
part 'wadah_set_state.dart';

class WadahSetBloc extends Bloc<WadahSetEvent, WadahSetState> {
  final WadahSetRepository _wadahSetRepository = WadahSetRepository();
  WadahSetBloc() : super(WadahSetInitial()) {
    on<GetWadahSet>((event, emit) async {
      emit(WadahSetInitial());
      try {
        final wadahSet = await _wadahSetRepository.fetchWadahSet(
            event.routingNo, event.activityNo, event.operationType);
        emit(WadahSetLoaded(wadahSet));
      } catch (e) {
        emit(WadahSetError());
      }
    });
  }
}
