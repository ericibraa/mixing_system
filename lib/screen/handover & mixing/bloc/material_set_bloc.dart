import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/materialset.dart';
import 'package:dumping_system/repository/materialset_repository.dart';
import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'material_set_event.dart';
part 'material_set_state.dart';

class MaterialSetBloc extends Bloc<MaterialSetEvent, MaterialSetState> {
  final MaterialsetRepository _materialsetRepository = MaterialsetRepository();
  MaterialSetBloc() : super(MaterialSetInitial()) {
    on<SendDataMaterialset>((event, emit) async {
      emit(MaterialSetLoading());
      try {
        final materialset = await _materialsetRepository.fetchmaterialset(
            event.routingNo, event.activityNo, event.operationType);
        // materialset.d!.results!
        //     .sort((a, b) => a.priority.compareTo(b.priority));
        emit(MaterialSetLoaded(materialset));
      } catch (e) {
        emit(MaterialSetError());
      }
    });
  }
}
