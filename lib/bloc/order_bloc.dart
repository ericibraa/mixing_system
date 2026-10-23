import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/models/response/order.dart';
import 'package:dumping_system/repository/order_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository = OrderRepository();
  OrderBloc() : super(OrderInitial()) {
    on<SendDataOrder>((event, emit) async {
      emit(OrderLoading());
      try {
        final order = await _orderRepository.fetchorder(
            event.startDate,
            event.materialCode,
            event.plant,
            event.operationType,
            event.batchFG);
        emit(OrderLoaded(order));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(OrderError(e.error!.message!.value!));
        } else {
          emit(const OrderError('Server Error'));
        }
      }
    });
  }
}
