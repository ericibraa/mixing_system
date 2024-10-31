import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/repository/operation_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'operation_event.dart';
part 'operation_state.dart';

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  final OperationRepository _operationalRepository = OperationRepository();
  OperationBloc() : super(OperationInitial()) {
    on<SendDataOperation>((event, emit) async {
      emit(OperationLoading());
      try {
        final operation = await _operationalRepository.fetchoperation(
            event.routingNo, event.operationType, event.operationApps);
        emit(OperationLoaded(operation));
      } catch (e) {
        emit(OperationError());
      }
    });
  }
}
