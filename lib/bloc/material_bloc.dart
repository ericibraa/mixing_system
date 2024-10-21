import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/material.dart';
import 'package:dumping_system/repository/material_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'material_event.dart';
part 'material_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final MaterialRepository _materialRepository = MaterialRepository();
  MaterialsBloc() : super(MaterialsInitial()) {
    on<SendPlant>((event, emit) async {
      emit(MaterialsLoading());
      try {
        final material = await _materialRepository.fetchmaterial(event.plant);
        emit(MaterialsLoaded(material));
      } catch (e) {
        emit(MaterialsError());
      }
    });
  }
}
