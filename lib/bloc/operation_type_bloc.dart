import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
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
            event.startDate, event.materialCode, event.plant, event.batchFG);
        emit(OperationTypeLoaded(operationType: operationType));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(OperationTypeError(e.error!.message!.value!));
        } else {
          emit(const OperationTypeError('Server Error'));
        }
      }
    });
  }
}
