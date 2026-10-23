import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/operation.dart';
import 'package:dumping_system/repository/operation_confirmation_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'operation_confirmation_event.dart';
part 'operation_confirmation_state.dart';

class OperationConfirmationBloc
    extends Bloc<OperationConfirmationEvent, OperationConfirmationState> {
  final OperationConfirmationRepository _operationConfirmationRepository =
      OperationConfirmationRepository();
  OperationConfirmationBloc() : super(OperationConfirmationInitial()) {
    on<GetOperationConfirmation>((event, emit) async {
      emit(OperationConfirmationLoading());
      try {
        final operationConfirmation =
            await _operationConfirmationRepository.fetchOperationConfirmation(
                event.routingNo, event.operationType, event.operationApps);
        emit(OperationConfirmationSuccess(operationConfirmation));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(OperationConfirmationError(e.error!.message!.value!));
        } else {
          emit(const OperationConfirmationError('Server Error'));
        }
      }
    });
  }
}
