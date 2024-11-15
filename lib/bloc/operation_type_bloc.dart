import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/operation_type.dart';
import 'package:dumping_system/repository/operation_type_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'operation_type_event.dart';
part 'operation_type_state.dart';

class OperationTypeBloc extends Bloc<OperationTypeEvent, OperationTypeState> {
  final OperationTypeRepository _operationTypeRepository =
      OperationTypeRepository();
  OperationTypeBloc() : super(OperationTypeInitial()) {
    on<SendDataOperationType>((event, emit) async {
      emit(OperationTypeLoading());
      try {
        final operationType = await _operationTypeRepository.fetchoperationtype(
            event.startDate, event.materialCode, event.plant);
        emit(OperationTypeLoaded(operationType: operationType));
      } catch (e) {
        emit(OperationTypeError());
      }
    });
  }
}
